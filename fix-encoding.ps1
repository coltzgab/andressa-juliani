$dir = "c:\Users\andre\Downloads\andressa-juliani-main\andressa-juliani-main"
$htmlFiles = Get-ChildItem -Path $dir -Filter "*.html"

foreach ($file in $htmlFiles) {
    $path = $file.FullName
    Write-Host "Processing: $($file.Name)"
    
    $bytes = [System.IO.File]::ReadAllBytes($path)
    
    # Skip BOM if present
    $start = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $start = 3
    }
    
    $contentBytes = New-Object byte[] ($bytes.Length - $start)
    [Array]::Copy($bytes, $start, $contentBytes, 0, $contentBytes.Length)
    
    # Decode as UTF-8
    $text = [System.Text.Encoding]::UTF8.GetString($contentBytes)
    
    # Check for double-encoded marker: 0xC3 (which is the byte for the first part of double-encoded chars)
    # In UTF-8, double-encoded Portuguese chars start with C3 83 (which decodes to the string char U+00C3)
    $hasDoubleEncoding = $false
    for ($i = 0; $i -lt $contentBytes.Length - 1; $i++) {
        if ($contentBytes[$i] -eq 0xC3 -and $contentBytes[$i+1] -eq 0x83) {
            $hasDoubleEncoding = $true
            break
        }
    }
    
    if ($hasDoubleEncoding) {
        Write-Host "  Double-encoded - FIXING..."
        
        # Reverse: UTF-8 decode -> Latin-1 bytes -> UTF-8 decode
        $latin1Bytes = [System.Text.Encoding]::GetEncoding(1252).GetBytes($text)
        $fixedText = [System.Text.Encoding]::UTF8.GetString($latin1Bytes)
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($path, $fixedText, $utf8NoBom)
        Write-Host "  FIXED!"
    } else {
        Write-Host "  OK"
    }
}

Write-Host "Done!"
