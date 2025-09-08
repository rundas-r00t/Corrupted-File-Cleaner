# Requires PowerShell 7+
# Define search path and output file
$SearchPath = "c:\folder\path\here"
$OutputFile = "C:\strings.txt"

# Clear output file if it exists
if (Test-Path $OutputFile) {
    Clear-Content $OutputFile
}

# Get all files recursively
$Files = Get-ChildItem -Path $SearchPath -Recurse -File -ErrorAction SilentlyContinue

# Use parallel processing for large datasets
$Files | ForEach-Object -Parallel {

    param($OutputFile)  # Pass the output file path to the parallel script block

    try {
        $lineNum = 0
        # Stream each file line by line
        Get-Content -Path $_.FullName -ErrorAction SilentlyContinue | ForEach-Object {
            $lineNum++
            if ($_ -match "@") {
                # Append match with filename and line number
                $entry = "$($_.FullName):$lineNum - $_"
                # Use thread-safe file append
                [System.IO.File]::AppendAllText($OutputFile, $entry + [Environment]::NewLine)
            }
        }
    } catch {
        Write-Host "Skipping file due to error: $($_.FullName)"
    }

} -ThrottleLimit 8 -ArgumentList $OutputFile  # Adjust ThrottleLimit to match your CPU cores
