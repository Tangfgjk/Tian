$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$sqlDirectory = Join-Path $projectRoot "sql\test"
$envFile = Join-Path $PSScriptRoot ".env"
$composeFile = Join-Path $PSScriptRoot "compose.yml"

if (-not (Test-Path $envFile)) {
    throw "未找到 .env 文件：$envFile"
}

if (-not (Test-Path $sqlDirectory)) {
    throw "未找到 SQL 目录：$sqlDirectory"
}

$passwordLine = Get-Content $envFile |
    Where-Object { $_ -match '^\s*MYSQL_ROOT_PASSWORD=' } |
    Select-Object -First 1

if (-not $passwordLine) {
    throw ".env 中未找到 MYSQL_ROOT_PASSWORD"
}

$mysqlPassword = (($passwordLine -split '=', 2)[1]).Trim()

if ([string]::IsNullOrWhiteSpace($mysqlPassword)) {
    throw "MYSQL_ROOT_PASSWORD 不能为空"
}

$containerId = (docker compose --env-file $envFile -f $composeFile ps -q mysql | Out-String).Trim()
if (-not $containerId) {
    throw "MySQL 容器未运行。请先执行 start-infra.ps1"
}

$sqlFiles = Get-ChildItem `
    -Path $sqlDirectory `
    -Filter "*.sql" `
    -File |
    Sort-Object Name

if ($sqlFiles.Count -eq 0) {
    throw "sql\test 目录中没有 SQL 文件"
}

Write-Host "即将创建并导入 $($sqlFiles.Count) 个业务数据库。" -ForegroundColor Yellow
Write-Host "SQL 文件将先复制进容器，避免 Windows PowerShell 改变 UTF-8 编码。" -ForegroundColor Yellow

$confirmation = Read-Host "输入 IMPORT 继续"

if ($confirmation -ne "IMPORT") {
    Write-Host "操作已取消。"
    exit 0
}

foreach ($file in $sqlFiles) {
    $dbName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    if ($dbName -notmatch '^tj_[a-z0-9_]+$') {
        throw "不安全的数据库名称：$dbName"
    }

    Write-Host ""
    Write-Host "处理：$($file.Name) -> $dbName" -ForegroundColor Cyan

    $createDatabaseSql = @"
CREATE DATABASE IF NOT EXISTS $dbName
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
"@

    $createDatabaseSql |
        docker exec `
            -i `
            -e "MYSQL_PWD=$mysqlPassword" `
            tianji-mysql `
            mysql -uroot --default-character-set=utf8mb4

    if ($LASTEXITCODE -ne 0) {
        throw "创建数据库失败：$dbName"
    }

    $containerSqlPath = "/tmp/$($file.Name)"

    docker cp `
        $file.FullName `
        "tianji-mysql:$containerSqlPath"

    if ($LASTEXITCODE -ne 0) {
        throw "复制 SQL 文件失败：$($file.Name)"
    }

    $importCommand = "mysql -uroot --default-character-set=utf8mb4 $dbName < $containerSqlPath"

    docker exec `
        -e "MYSQL_PWD=$mysqlPassword" `
        tianji-mysql `
        sh -c $importCommand

    if ($LASTEXITCODE -ne 0) {
        throw "导入失败：$($file.Name)"
    }

    docker exec tianji-mysql rm -f $containerSqlPath | Out-Null

    Write-Host "导入完成：$dbName" -ForegroundColor Green
}

Write-Host ""
Write-Host "所有业务数据库导入完成。" -ForegroundColor Green

Write-Host ""
Write-Host "当前 tj_ 数据库：" -ForegroundColor Cyan

docker exec `
    -e "MYSQL_PWD=$mysqlPassword" `
    tianji-mysql `
    mysql -uroot -N -e "SHOW DATABASES LIKE 'tj\_%';"
