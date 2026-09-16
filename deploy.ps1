[CmdletBinding()]
param(
    [string]$SaPassword = "InterviewDemo!2026"
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$container = 'interview-data-warehouse'
$sqlcmd = '/opt/mssql-tools18/bin/sqlcmd'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker Desktop is required. Install it, start it, then rerun this command.'
}

Push-Location $root
try {
    $env:SA_PASSWORD = $SaPassword
    docker compose up -d
    if ($LASTEXITCODE -ne 0) { throw 'Docker Compose could not start SQL Server.' }

    Write-Host 'Waiting for SQL Server to accept connections...'
    $ready = $false
    for ($attempt = 1; $attempt -le 30; $attempt++) {
        docker exec $container $sqlcmd -C -S localhost -U sa -P $SaPassword -Q 'SELECT 1' 2>$null
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 2
    }
    if (-not $ready) { throw 'SQL Server did not become ready within 60 seconds.' }

    docker cp "$root\scripts" "${container}:/workspace"
    if ($LASTEXITCODE -ne 0) { throw 'Could not copy deployment scripts into the SQL Server container.' }

    $scripts = @('init_database.sql', 'bronze/ddl_bronze.sql', 'silver/ddl_silver.sql', 'bronze/proc_load_bronze.sql', 'silver/proc_load_silver.sql', 'gold/ddl_gold.sql')
    foreach ($script in $scripts) {
        Write-Host "Applying $script"
        $databaseArgs = if ($script -eq 'init_database.sql') { @() } else { @('-d', 'DataWarehouse') }
        docker exec $container $sqlcmd -b -C -S localhost -U sa -P $SaPassword @databaseArgs -i "/workspace/scripts/$script"
        if ($LASTEXITCODE -ne 0) { throw "Failed while applying $script" }
    }

    docker exec $container $sqlcmd -b -C -S localhost -U sa -P $SaPassword -d DataWarehouse -Q 'EXEC bronze.load_bronze; EXEC silver.load_silver;'
    if ($LASTEXITCODE -ne 0) { throw 'The ETL load failed.' }
    docker exec $container $sqlcmd -b -C -S localhost -U sa -P $SaPassword -d DataWarehouse -i /workspace/scripts/tests/quality_checks_silver.sql
    if ($LASTEXITCODE -ne 0) { throw 'Silver quality-check script failed to execute.' }
    docker exec $container $sqlcmd -b -C -S localhost -U sa -P $SaPassword -d DataWarehouse -i /workspace/scripts/tests/quality_checks_gold.sql
    if ($LASTEXITCODE -ne 0) { throw 'Gold quality-check script failed to execute.' }

    Write-Host ''
    Write-Host 'Deployment complete. Connect with Server=localhost,1433; Database=DataWarehouse; User=sa.' -ForegroundColor Green
}
finally { Pop-Location }
