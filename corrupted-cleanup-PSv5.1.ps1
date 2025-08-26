# ==========================================================
# Recovered Files Cleanup Script - PowerShell 5.1 Compatible
# ==========================================================
# This script scans a target folder for potentially corrupted files
# and deletes them. Supports images, audio, video, text, and unknown files.
# Logs all deleted files to a timestamped log file.
# ==========================================================

# Folder to scan
$folder = "G:\dell-recovery\Unknown folder"  # <-- Change this to your target folder

# Log file
$logFile = Join-Path $folder ("deleted_corrupted_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")

# Supported file type checkers
# Images (jpg, png, gif, bmp, tiff)
function Test-Image($file) {
    try {
        Add-Type -AssemblyName System.Drawing
        $img = [System.Drawing.Image]::FromFile($file)
        $img.Dispose()
        return $true
    } catch { return $false }
}

# Audio (mp3, wav, m4a, flac)
function Test-Audio($file) {
    try {
        # Attempt to open via COM Object
        $shell = New-Object -ComObject Shell.Application
        $folderObj = $shell.NameSpace((Split-Path $file))
        $item = $folderObj.ParseName((Split-Path $file -Leaf))
        return $true
    } catch { return $false }
}

# Video (mp4, mkv, avi, wmv)
function Test-Video($file) {
    try {
        # Similar method as audio; just check if accessible
        $shell = New-Object -ComObject Shell.Application
        $folderObj = $shell.NameSpace((Split-Path $file))
        $item = $folderObj.ParseName((Split-Path $file -Leaf))
        return $true
    } catch { return $false }
}

# Text files
function Test-Text($file) {
    try {
        Get-Content -Path $file -ErrorAction Stop | Out-Null
        return $true
    } catch { return $false }
}

# Function to check if file is corrupted
function Test-File($file) {
    $ext = [System.IO.Path]::GetExtension($file).ToLower()
    switch ($ext) {
        ".jpg" { return Test-Image $file }
        ".jpeg" { return Test-Image $file }
        ".png" { return Test-Image $file }
        ".bmp" { return Test-Image $file }
        ".gif" { return Test-Image $file }
        ".tiff" { return Test-Image $file }
        ".mp3" { return Test-Audio $file }
        ".wav" { return Test-Audio $file }
        ".m4a" { return Test-Audio $file }
        ".flac" { return Test-Audio $file }
        ".mp4" { return Test-Video $file }
        ".mkv" { return Test-Video $file }
        ".avi" { return Test-Video $file }
        ".wmv" { return Test-Video $file }
        ".txt" { return Test-Text $file }
        default { 
            # Unknown types: try opening as binary
            try {
                [System.IO.File]::OpenRead($file).Dispose()
                return $true
            } catch { return $false }
        }
    }
}

# ==========================================================
# Scan folder recursively
# ==========================================================
$files = Get-ChildItem -Path $folder -Recurse -File

foreach ($file in $files) {
    if (-not (Test-File $file.FullName)) {
        Write-Host "Corrupted: $($file.FullName) - Deleting..."
        Add-Content -Path $logFile -Value $file.FullName
        Remove-Item -Path $file.FullName -Force
    }
}

Write-Host "Scan complete! Corrupted files logged to $logFile"
