$ErrorActionPreference = "Continue"
$ComposeFile = Join-Path $PSScriptRoot "compose.yml"
$EnvFile = Join-Path $PSScriptRoot ".env"

function Read-EnvValue([string]$Key, [int]$Default) {
    if (-not (Test-Path $EnvFile)) { return $Default }
    $line = Get-Content $EnvFile | Where-Object { $_ -match "^\s*${Key}=" } | Select-Object -First 1
    if (-not $line) { return $Default }
    $value = (($line -split '=', 2)[1]).Trim()
    if ($value -match '^[0-9]+$') { return [int]$value }
    return $Default
}

function Test-Port([string]$Name, [int]$Port) {
    $ok = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($ok) {
        Write-Host ("[OK] {0} 127.0.0.1:{1}" -f $Name, $Port) -ForegroundColor Green
    } else {
        Write-Host ("[FAIL] {0} 127.0.0.1:{1}" -f $Name, $Port) -ForegroundColor Red
    }
}

$mysqlPort  = Read-EnvValue "MYSQL_PORT" 3306
$redisPort  = Read-EnvValue "REDIS_PORT" 6379
$nacosPort  = Read-EnvValue "NACOS_HTTP_PORT" 8848
$amqpPort   = Read-EnvValue "RABBITMQ_AMQP_PORT" 5672
$mgmtPort   = Read-EnvValue "RABBITMQ_MANAGEMENT_PORT" 15672

Push-Location $PSScriptRoot
try {
    docker compose --env-file $EnvFile -f $ComposeFile ps
    Write-Host ""

    Test-Port "MySQL" $mysqlPort
    Test-Port "Redis" $redisPort
    Test-Port "Nacos HTTP" $nacosPort
    Test-Port "RabbitMQ AMQP" $amqpPort
    Test-Port "RabbitMQ Management" $mgmtPort

    Write-Host ""
    docker compose --env-file $EnvFile -f $ComposeFile exec -T mysql sh -c 'mysqladmin ping -h 127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD" --silent'
    docker compose --env-file $EnvFile -f $ComposeFile exec -T redis sh -c 'redis-cli -a "$REDIS_PASSWORD" ping'
    docker compose --env-file $EnvFile -f $ComposeFile exec -T rabbitmq rabbitmq-diagnostics -q ping

    try {
        $r = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:${nacosPort}/nacos/" -TimeoutSec 10
        Write-Host ("[OK] Nacos Console HTTP {0}" -f $r.StatusCode) -ForegroundColor Green
    } catch {
        Write-Host "[WARN] Nacos 控制台尚未就绪，请查看日志：docker compose -f docker-local/compose.yml logs -f nacos" -ForegroundColor Yellow
    }
} finally {
    Pop-Location
}
