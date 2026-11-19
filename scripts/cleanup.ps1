$ErrorActionPreference = 'Stop'
$compose = Join-Path $PSScriptRoot '..\configs\docker-compose.yml'

# Keep named volumes: accounts, credentials, artifacts and analysis are preserved.
docker compose -f $compose down
if ($LASTEXITCODE -ne 0) { throw 'Could not stop the lab containers.' }
Write-Host 'Containers stopped. Named volumes and lab data are preserved.'
