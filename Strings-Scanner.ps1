# Define the search path --update this to where you want to scan
$SearchPath = "C;\path\to\folders"

# Define the output file --update this to where you want the strings.txt file to live
$OutputFile = "C:\strings.txt"

# Clear the output file if it already exists
if (Test-Path $OutputFile) {
    Clear-Content $OutputFile
}

# Recursively search for lines containing '@' and append results to strings.txt
Get-ChildItem -Path $SearchPath -Recurse -File | 
    Select-String -Pattern "@" -SimpleMatch -ErrorAction SilentlyContinue |
    ForEach-Object { Add-Content -Path $OutputFile -Value $_.Line -Encoding utf8 }
