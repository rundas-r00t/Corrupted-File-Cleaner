# Define search path and output file
$SearchPath = "c:\path\to\folder"
$OutputFile = "c:\strings.txt"

# Clear the output file if it exists
if (Test-Path $OutputFile) { Clear-Content $OutputFile }

# Buffer settings
$BufferSize = 50000   # Larger buffer for fewer writes
$Buffer = New-Object System.Collections.Generic.List[string]

# Recursively enumerate files
Get-ChildItem -Path $SearchPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $reader = [System.IO.StreamReader]::new($_.FullName)
        while (($line = $reader.ReadLine()) -ne $null) {
            if ($line.Contains("@")) {
                $Buffer.Add($line)
                if ($Buffer.Count -ge $BufferSize) {
                    [System.IO.File]::AppendAllLines($OutputFile, $Buffer)
                    $Buffer.Clear()
                }
            }
        }
        $reader.Close()
    } catch {
        Write-Host "Skipping file: $($_.FullName)"
    }
}

# Final flush
if ($Buffer.Count -gt 0) {
    [System.IO.File]::AppendAllLines($OutputFile, $Buffer)
}
