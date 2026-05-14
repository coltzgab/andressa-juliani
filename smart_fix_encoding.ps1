$files = Get-ChildItem *.html
foreach ($f in $files) {
    Write-Host "Analyzing $($f.Name)..."
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    
    # Use UTF8 encoding that throws on invalid sequences
    $utf8Encoding = New-Object System.Text.UTF8Encoding($false, $true)
    $isUtf8 = $true
    $text = ""
    try {
        $text = $utf8Encoding.GetString($bytes)
    } catch {
        $isUtf8 = $false
    }
    
    if ($isUtf8) {
        # If it's valid UTF-8, check if it's double-encoded
        # Common double-encoding pattern: C3 83 (Ã) followed by a byte that's a Latin-1 version of a UTF-8 start byte
        if ($text -match "Ã[§©¡³º­ª¶]") {
            Write-Host "  Detected Double Encoding. Fixing..."
            $latin1Bytes = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes($text)
            $fixedText = [System.Text.Encoding]::UTF8.GetString($latin1Bytes)
            [System.IO.File]::WriteAllText($f.FullName, $fixedText, [System.Text.Encoding]::UTF8)
            Write-Host "  Fixed Double Encoding."
        } else {
            Write-Host "  Seems OK (UTF-8)."
        }
    } else {
        # If not valid UTF-8, assume Latin-1 and convert
        Write-Host "  Detected Latin-1. Converting to UTF-8..."
        $text = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::GetEncoding("iso-8859-1"))
        [System.IO.File]::WriteAllText($f.FullName, $text, [System.Text.Encoding]::UTF8)
        Write-Host "  Converted Latin-1 to UTF-8."
    }
}
Write-Host "All done!"
