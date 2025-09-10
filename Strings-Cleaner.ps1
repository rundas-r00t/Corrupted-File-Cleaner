### this will hopefully take the strings.txt file from the strings-scanner.ps1 script and take out any non-printable characters and other garbage data, and give us a clean email list

# Input and output
$InputFile = "c:\strings.txt"
$OutputFile = "c:\strings_clean.txt"

# Clear output if exists
if (Test-Path $OutputFile) { Clear-Content $OutputFile }

# Regex to match:
# 1. email only: something@something.something
# 2. email:password (allow anything after colon)
$EmailPattern = '^[\w\.-]+@[\w\.-]+\.\w+(:.*)?$'

# Buffer settings
$BufferSize = 50000
$Buffer = New-Object System.Collections.Generic.List[string]

# Stream the file line by line
$reader = [System.IO.StreamReader]::new($InputFile)
while (($line = $reader.ReadLine()) -ne $null) {
    if ($line -match $EmailPattern) {
        $Buffer.Add($line)
        if ($Buffer.Count -ge $BufferSize) {
            [System.IO.File]::AppendAllLines($OutputFile, $Buffer)
            $Buffer.Clear()
        }
    }
}
$reader.Close()

# Final flush
if ($Buffer.Count -gt 0) {
    [System.IO.File]::AppendAllLines($OutputFile, $Buffer)
}
