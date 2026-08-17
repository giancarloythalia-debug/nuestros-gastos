# servidor.ps1 - Mini servidor local para la app (solo uso en tu PC)
# Inicia via 'Iniciar App.bat'. No es necesario subirlo a GitHub.
$ErrorActionPreference = 'SilentlyContinue'
$port = 8787
$root = $PSScriptRoot

$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $port)
try {
  $listener.Start()
} catch {
  Write-Host "El puerto $port ya esta en uso. Cierra la ventana anterior o cambia el puerto."
  Start-Sleep -Seconds 3
  exit
}

Write-Host ""
Write-Host "======================================"
Write-Host "  App de gastos de pareja"
Write-Host "  Abriendo: http://localhost:$port/"
Write-Host "  Para detener, cierra esta ventana."
Write-Host "======================================"
Write-Host ""

Start-Process "http://localhost:$port/"

while ($true) {
  $client = $null
  try {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::ASCII)
    $requestLine = $reader.ReadLine()
    if ($requestLine -eq $null) { continue }

    $parts = $requestLine -split ' '
    $path = ''
    if ($parts.Length -gt 1) {
      $path = $parts[1]
      $q = $path.IndexOf('?')
      if ($q -ge 0) { $path = $path.Substring(0, $q) }
      try { $path = [System.Uri]::UnescapeDataString($path) } catch {}
    }
    if ($path -eq '' -or $path -eq '/') { $path = '/index.html' }
    $rel = $path.TrimStart('/').Replace('/', '\')
    $full = [System.IO.Path]::GetFullPath((Join-Path $root $rel))

    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $full) -and -not (Get-Item -LiteralPath $full).PSIsContainer) {
      $bytes = [System.IO.File]::ReadAllBytes($full)
      $ext = [System.IO.Path]::GetExtension($full).ToLower()
      $mime = switch ($ext) {
        '.html' { 'text/html' }
        '.json' { 'application/json' }
        '.css'  { 'text/css' }
        '.js'   { 'application/javascript' }
        default { 'application/octet-stream' }
      }
      $head = "HTTP/1.1 200 OK`r`nContent-Type: $mime`r`nCache-Control: no-store`r`nContent-Length: $($bytes.Length)`r`nConnection: close`r`n`r`n"
      $hb = [System.Text.Encoding]::ASCII.GetBytes($head)
      $stream.Write($hb, 0, $hb.Length)
      $stream.Write($bytes, 0, $bytes.Length)
    } else {
      $head = "HTTP/1.1 404 Not Found`r`nContent-Length: 0`r`nConnection: close`r`n`r`n"
      $hb = [System.Text.Encoding]::ASCII.GetBytes($head)
      $stream.Write($hb, 0, $hb.Length)
    }
  } catch {
    # cliente desconectado u otro error: continuar sirviendo
  } finally {
    if ($client -ne $null) { try { $client.Close() } catch {} }
  }
}
