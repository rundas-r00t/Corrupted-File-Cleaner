# Define the search path --update this to where you want to scan
$SearchPath = "C:\path\to\folders"

# Define the output file --update this to where you want the strings.txt file to live
$OutputFile = "C:\strings.txt"

# Clear the output file if it exists
if (Test-Path $OutputFile) {
    Clear-Content $OutputFile
}

# Recursively get all files
Get-ChildItem -Path $SearchPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {

    try {
        # Stream the file line by line
        Get-Content -Path $_.FullName -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_ -match "@") {
                # Append match immediately
                Add-Content -Path $OutputFile -Value "$($_)" -Encoding utf8
            }
        }
    } catch {
        Write-Host "Skipping file due to error: $($_.FullName)"
    }
}
