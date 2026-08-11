param(
    [string]$NacosUrl = "http://127.0.0.1:8848",
    [string]$DiscoveryNamespaceId = "f923fb34-cb0a-4c06-8fca-ad61ea61a3f0"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ConfigDir = Join-Path $RepoRoot "nacos\DEFAULT_GROUP"

if (-not (Test-Path $ConfigDir)) {
    throw "未找到 $ConfigDir。请把 docker-local 文件夹放到 online-mooc 仓库根目录。"
}

try {
    Invoke-WebRequest -UseBasicParsing -Uri "$NacosUrl/nacos/" -TimeoutSec 10 | Out-Null
} catch {
    throw "Nacos 尚未就绪：$NacosUrl。请先启动容器并查看 nacos 日志。"
}

# 项目 bootstrap-local.yml 中把服务发现 namespace 固定为此 ID。
# 尝试创建同 ID 的命名空间；已存在或接口行为不同时仅给出提示，不阻断配置导入。
try {
    $nsBody = @{
        customNamespaceId = $DiscoveryNamespaceId
        namespaceName = "tianji-local"
        namespaceDesc = "天机学堂本地学习环境"
    }
    $nsResult = Invoke-RestMethod -Method Post -Uri "$NacosUrl/nacos/v1/console/namespaces" -ContentType "application/x-www-form-urlencoded" -Body $nsBody
    Write-Host "已尝试创建服务发现命名空间：$DiscoveryNamespaceId" -ForegroundColor Green
} catch {
    Write-Host "命名空间可能已存在，或当前 Nacos 不允许通过该接口创建。请在控制台中确认 ID：$DiscoveryNamespaceId" -ForegroundColor Yellow
}

$Files = Get-ChildItem -Path $ConfigDir -File | Where-Object { $_.Extension -in ".yaml", ".yml", ".properties" } | Sort-Object Name
if ($Files.Count -eq 0) {
    throw "未找到可导入的 Nacos 配置文件。"
}

foreach ($file in $Files) {
    $type = if ($file.Extension -in ".yaml", ".yml") { "yaml" } else { "properties" }
    $body = @{
        dataId = $file.Name
        group = "DEFAULT_GROUP"
        content = Get-Content -Raw -Encoding UTF8 $file.FullName
        type = $type
    }
    $result = Invoke-RestMethod -Method Post -Uri "$NacosUrl/nacos/v1/cs/configs" -ContentType "application/x-www-form-urlencoded" -Body $body
    if ($result -eq $true -or $result -eq "true") {
        Write-Host ("[OK] {0}" -f $file.Name) -ForegroundColor Green
    } else {
        Write-Host ("[WARN] {0} 返回：{1}" -f $file.Name, $result) -ForegroundColor Yellow
    }
}

Write-Host "Nacos 配置已导入 public 命名空间 / DEFAULT_GROUP。" -ForegroundColor Green
Write-Host "请打开 $NacosUrl/nacos/，确认配置列表和 tianji-local 命名空间。" -ForegroundColor Green

