$ErrorActionPreference = "Stop"
$ComposeFile = Join-Path $PSScriptRoot "compose.yml"
$EnvFile = Join-Path $PSScriptRoot ".env"

Push-Location $PSScriptRoot
try {
    docker compose --env-file $EnvFile -f $ComposeFile stop
    docker compose --env-file $EnvFile -f $ComposeFile ps
    Write-Host "容器已停止，数据卷仍保留。" -ForegroundColor Green
} finally {
    Pop-Location
}

