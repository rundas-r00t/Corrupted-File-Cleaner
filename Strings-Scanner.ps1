# Define search path and output file 
$SearchPath = "c:\path\to\folder" 
$OutputFile = "C:\strings.txt" 

# Clear the output file if it exists
if (Test-Path $OutputFile) { Clear-Content $OutputFile } 

# Buffer settings ..trying to speed this up b/c is so slow for large datasets
$BufferSize = 10000 # Number of matches before flushing to disk
$Buffer = @()

# Recursively enumerate files
Get-ChildItem -Path $SearchPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { 

try { 
# Stream file line by line

    Get-Content -Path $_.FullName -ReadCount 1000 -ErrorAction SilentlyContinue | ForEach-Object {
    
        foreach ($line in $_) {
            if ($line -like "*@*") {
                $Buffer += $line if ($Buffer.Count -ge $BufferSize) { 
# Flush buffer to disk 

                [System.IO.File]::AppendAllLines($OutputFile, $Buffer) $Buffer = @() # Reset buffer
                }
            } 
        }
    }
} catch { 
    Write-Host "Skipping file: $($_.FullName)" 
        }
    } 

# Final flush for leftovers 
if ($Buffer.Count -gt 0) { [System.IO.File]::AppendAllLines($OutputFile, $Buffer) 
}
