$folder = "<your-file-path-here>"
$logFile = Join-Path $folder "deleted_jpgs.txt"

# Clear old log if it exists
if (Test-Path $logFile) {
    Clear-Content $logFile
}

Add-Type -AssemblyName System.Drawing

Get-ChildItem -Path $folder -Filter *.jpg | ForEach-Object {
    try {
        $img = [System.Drawing.Image]::FromFile($_.FullName)
        $img.Dispose()
    }
    catch {
        # If it's corrupted, delete and log
        $_.FullName | Out-File -FilePath $logFile -Append
        Remove-Item $_.FullName -Force
        Write-Host "Deleted corrupted file: $($_.FullName)"
    }
}

