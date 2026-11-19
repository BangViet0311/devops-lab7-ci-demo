$ErrorActionPreference = 'Stop'
$compose = Join-Path $PSScriptRoot '..\configs\docker-compose.yml'
$failed = $false

docker compose -f $compose ps
if ($LASTEXITCODE -ne 0) { throw 'Cannot query Docker Compose.' }

foreach ($service in @(
    @{ Name = 'Jenkins'; Url = 'http://localhost:8080/login' }
    @{ Name = 'Nexus'; Url = 'http://localhost:8081/' }
    @{ Name = 'SonarQube'; Url = 'http://localhost:9000/api/system/status' }
)) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 30
        if ($service.Name -eq 'SonarQube') {
            $status = ($response.Content | ConvertFrom-Json).status
            if ($status -ne 'UP') { throw "SonarQube status: $status" }
        }
        Write-Host "OK: $($service.Name)"
    }
    catch {
        $failed = $true
        Write-Warning "$($service.Name): $($_.Exception.Message)"
    }
}

if ($failed) { throw 'Some services are not ready. Inspect docker compose logs.' }
Write-Host 'All service endpoints are reachable. This does not verify pipeline results.'
