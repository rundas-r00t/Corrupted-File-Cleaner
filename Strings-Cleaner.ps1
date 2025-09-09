### this will hopefully take the strings.txt file from the strings-scanner.ps1 script and take out any non-printable characters and other garbage data, and give us a clean email list

# Input and output
$InputFile = "c:\strings.txt"
$OutputFile = "c:\strings_clean.txt"

# Regex to match:
# 1. email only: something@something.something
# 2. email:password (allow anything after colon)
$EmailPattern = '^[\w\.-]+@[\w\.-]+\.\w+(:.*)?$'

# Clear output if exists
if (Test-Path $OutputFile) { Clear-Content $OutputFile }

# Process line by line
Get-Content $InputFile -ReadCount 1000 | ForEach-Object {
    foreach ($line in $_) {
        if ($line -match $EmailPattern) {
            Add-Content -Path $OutputFile -Value $line
        }
    }
}
