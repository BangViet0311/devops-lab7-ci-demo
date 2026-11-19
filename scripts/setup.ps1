$ErrorActionPreference = 'Stop'
$compose = Join-Path $PSScriptRoot '..\configs\docker-compose.yml'

docker compose -f $compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Invalid Docker Compose configuration.' }

docker compose -f $compose up -d
if ($LASTEXITCODE -ne 0) { throw 'Could not start the lab containers.' }

Write-Host 'Allow a few minutes for startup, then run scripts\verify.ps1.'
Write-Host 'Jenkins: http://localhost:8080'
Write-Host 'Nexus: http://localhost:8081'
Write-Host 'SonarQube: http://localhost:9000'
