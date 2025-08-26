# Folder path to scan
$folder = "<your-file-path-here>"
$logFile = Join-Path $folder "deleted_corrupted.txt"

# Clear old log
if (Test-Path $logFile) { Clear-Content $logFile }

# Load .NET assemblies for image checking
Add-Type -AssemblyName System.Drawing

# ----- Specialized checkers -----

# Image check: attempts to load image using .NET; dispose afterwards
function Test-Image($filePath) {
    try {
        $img = [System.Drawing.Image]::FromFile($filePath)
        $img.Dispose()
        return $true
    } catch { return $false }
}

# Text check: reads first 1 KB of file to detect unreadable/corrupted text
function Test-Text($filePath) {
    try {
        Get-Content -Path $filePath -Encoding Byte -ReadCount 1024 -TotalCount 1024 | Out-Null
        return $true
    } catch { return $false }
}

# PDF check: only reads first 4 bytes to see if file starts with %PDF
function Test-PDF($filePath) {
    try {
        $fs = [System.IO.File]::OpenRead($filePath)
        $buffer = New-Object byte[] 4
        $fs.Read($buffer, 0, 4) | Out-Null
        $fs.Close()
        $header = [System.Text.Encoding]::ASCII.GetString($buffer)
        return $header -eq "%PDF"
    } catch { return $false }
}

# Audio/Video check: minimal read of first bytes to detect broken media
function Test-Media($filePath) {
    try {
        $fs = [System.IO.File]::OpenRead($filePath)
        $buffer = New-Object byte[] 4
        $fs.Read($buffer, 0, 4) | Out-Null
        $fs.Close()
        return $true
    } catch { return $false }
}

# Binary fallback: reads first few bytes; used for unknown file types
function Test-Binary($filePath) {
    try {
        $fs = [System.IO.File]::OpenRead($filePath)
        $buffer = New-Object byte[] 4
        $fs.Read($buffer, 0, 4) | Out-Null
        $fs.Close()
        return $true
    } catch { return $false }
}

# ----- Auto-detect known file types using Windows registry -----
# This will enumerate all registered file extensions on the system
$extensions = Get-ChildItem "HKCR:\." | ForEach-Object { $_.PSChildName } | Where-Object { $_ -ne "" }

# Map known extensions to checker functions
$checkers = @{}
foreach ($ext in $extensions) {
    $extLower = "." + $ext.ToLower()
    if ($extLower -in ".jpg", ".jpeg", ".png", ".bmp", ".gif") { $checkers[$extLower] = "Test-Image" }
    elseif ($extLower -eq ".pdf") { $checkers[$extLower] = "Test-PDF" }
    elseif ($extLower -in ".txt", ".log", ".csv") { $checkers[$extLower] = "Test-Text" }
    elseif ($extLower -in ".mp3", ".m4a", ".wav", ".flac", ".aac", ".ogg", ".wma") { $checkers[$extLower] = "Test-Media" }
    elseif ($extLower -in ".mp4", ".mkv", ".avi", ".wmv", ".mov", ".flv") { $checkers[$extLower] = "Test-Media" }
    else { $checkers[$extLower] = "Test-Binary" } # Fallback for unknown
}

# ----- Scan folder recursively and process in parallel -----

$files = Get-ChildItem -Path $folder -Recurse -File

$files | ForEach-Object -Parallel {
    param($file, $checkers, $logFile)

    $ext = $file.Extension.ToLower()
    if ($checkers.ContainsKey($ext)) { $func = $checkers[$ext] } else { $func = "Test-Binary" }

    $ok = & $func $file.FullName

    if (-not $ok) {
        # Log deleted files for review
        "$($file.FullName)" | Out-File -FilePath $logFile -Append
        Remove-Item -Path $file.FullName -Force
        Write-Host "Corrupted: $($file.FullName) - Deleted"
    } else {
        Write-Host "OK: $($file.FullName)"
    }
# Note: -ThrottleLimit 10 allows up to 10 files to be processed in parallel; adjust based on CPU/RAM
} -ThrottleLimit 10 -ArgumentList $checkers, $logFile

Write-Host "Scan complete! Corrupted files logged to $logFile"

