$ErrorActionPreference = "Stop"
$ComposeFile = Join-Path $PSScriptRoot "compose.yml"
$EnvFile = Join-Path $PSScriptRoot ".env"
$EnvExample = Join-Path $PSScriptRoot ".env.example"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "未找到 docker 命令。请先安装并启动 Docker Desktop。"
}

try {
    docker info *> $null
} catch {
    throw "Docker Engine 当前不可用。请打开 Docker Desktop，等待状态变为 Running。"
}

if (-not (Test-Path $EnvFile)) {
    Copy-Item $EnvExample $EnvFile
    Write-Host "已创建 $EnvFile" -ForegroundColor Yellow
    Write-Host "请先编辑 .env 中的密码，然后重新运行本脚本。" -ForegroundColor Yellow
    exit 1
}

Push-Location $PSScriptRoot
try {
    docker compose --env-file $EnvFile -f $ComposeFile up -d
    docker compose --env-file $EnvFile -f $ComposeFile ps
    Write-Host "基础中间件启动命令已执行。接下来运行 .\check-infra.ps1。" -ForegroundColor Green
} finally {
    Pop-Location
}

