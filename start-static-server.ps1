$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Web

$Root = $PSScriptRoot
$Port = if ($args.Count -gt 0) { [int]$args[0] } else { 8000 }
$Listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
$Listener.Start()

while ($true) {
  $client = $Listener.AcceptTcpClient()
  try {
    $stream = $client.GetStream()
    $buffer = New-Object byte[] 8192
    $read = $stream.Read($buffer, 0, $buffer.Length)
    if ($read -le 0) { continue }

    $request = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
    $firstLine = ($request -split "`r?`n")[0]
    $parts = $firstLine -split ' '
    $urlPath = if ($parts.Length -ge 2) { $parts[1] } else { '/' }
    $pathOnly = ($urlPath -split '\?')[0]
    $relative = [System.Web.HttpUtility]::UrlDecode($pathOnly.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($relative)) { $relative = 'index.html' }

    $fullPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($Root, $relative))
    $status = '200 OK'
    $contentType = 'application/octet-stream'
    $bytes = $null

    if (-not $fullPath.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
      $status = '403 Forbidden'
      $contentType = 'text/plain; charset=utf-8'
      $bytes = [System.Text.Encoding]::UTF8.GetBytes('Forbidden')
    } else {
      if ([System.IO.Directory]::Exists($fullPath)) {
        $fullPath = [System.IO.Path]::Combine($fullPath, 'index.html')
      }

      if (-not [System.IO.File]::Exists($fullPath)) {
        $status = '404 Not Found'
        $contentType = 'text/plain; charset=utf-8'
        $bytes = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
      } else {
        $extension = [System.IO.Path]::GetExtension($fullPath).ToLowerInvariant()
        $types = @{
          '.html' = 'text/html; charset=utf-8'
          '.css' = 'text/css; charset=utf-8'
          '.js' = 'application/javascript; charset=utf-8'
          '.png' = 'image/png'
          '.jpg' = 'image/jpeg'
          '.jpeg' = 'image/jpeg'
          '.svg' = 'image/svg+xml'
          '.webp' = 'image/webp'
          '.gif' = 'image/gif'
        }
        if ($types.ContainsKey($extension)) { $contentType = $types[$extension] }
        $bytes = [System.IO.File]::ReadAllBytes($fullPath)
      }
    }

    $header = "HTTP/1.1 $status`r`nContent-Type: $contentType`r`nContent-Length: $($bytes.Length)`r`nConnection: close`r`n`r`n"
    $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
    $stream.Write($headerBytes, 0, $headerBytes.Length)
    $stream.Write($bytes, 0, $bytes.Length)
  } catch {
    # Keep serving after a malformed request.
  } finally {
    $client.Close()
  }
}
