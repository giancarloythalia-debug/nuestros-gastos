$ErrorActionPreference = "Stop"
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlPath = Join-Path $base "index.html"
$gastosPath = Join-Path $base "gastos.html"
$backupPath = Join-Path $base "backup.json"

# Check for local backup.json first (from the app's export button)
if (Test-Path $backupPath) {
    Write-Host "Usando backup.json local..." -ForegroundColor Cyan
    try {
        $json = Get-Content -LiteralPath $backupPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not $json.profiles) { throw "backup.json no tiene profiles" }
        Write-Host "OK: $($json.profiles.PSObject.Properties.Name -join ', '), updatedAt $($json.updatedAt)" -ForegroundColor Green
    } catch {
        Write-Host "Error en backup.json: $_" -ForegroundColor Red
        Write-Host " Abortando para no borrar datos." -ForegroundColor Yellow
        exit 1
    }
} else {
    # Fallback: fetch from Firebase
    $fbUrl = "https://nuestros-gatos-default-rtdb.firebaseio.com/gastos/state.json"
    Write-Host "Sin backup.json, descargando de Firebase..." -ForegroundColor Cyan
    try {
        $json = Invoke-RestMethod -Uri $fbUrl -TimeoutSec 15
        if (-not $json.profiles) {
            Write-Host "Firebase vacio o sin datos validos. Abortando." -ForegroundColor Red
            exit 1
        }
        Write-Host "OK: $($json.profiles.PSObject.Properties.Name -join ', '), updatedAt $($json.updatedAt)" -ForegroundColor Green
    } catch {
        Write-Host "Error al conectar con Firebase: $_" -ForegroundColor Red
        Write-Host " Abortando para no borrar datos." -ForegroundColor Yellow
        exit 1
    }
}

# Read current HTML
$html = [System.IO.File]::ReadAllText($htmlPath, (New-Object System.Text.UTF8Encoding($false)))

# Embed the data
$jsonStr = $json | ConvertTo-Json -Depth 50 -Compress
$html = $html -replace 'const EMBEDDED_DATA = \{.*?\};/\*EMBED\*/', "const EMBEDDED_DATA = $jsonStr;/*EMBED*/"

# Write back (UTF8 without BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($htmlPath, $html, $utf8NoBom)

# Sync gastos.html
$bytes = [System.IO.File]::ReadAllBytes($htmlPath)
[System.IO.File]::WriteAllBytes($gastosPath, $bytes)

Write-Host "index.html y gastos.html actualizados." -ForegroundColor Green
Write-Host "Listo para git add + commit + push" -ForegroundColor Cyan
