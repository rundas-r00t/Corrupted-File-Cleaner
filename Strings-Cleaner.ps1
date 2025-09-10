### this will hopefully take the strings.txt file from the strings-scanner.ps1 script and take out any non-printable characters and other garbage data, and give us a clean email list
###updated version looks for ; and replaces with : to keep the user:pass format
# Input and output files
$InputFile  = "c:\strings.txt"
$OutputFile = "c:\strings_clean.txt"

# Clear output if it exists
if (Test-Path $OutputFile) { Clear-Content $OutputFile }

# Regex to match:
# 1. Email only: something@something.something
# 2. Email:password (allow anything after colon or semicolon)
$EmailPattern = '^[\w\.-]+@[\w\.-]+\.\w+([:;].*)?$'

# Buffer settings
$BufferSize = 50000
$Buffer = New-Object System.Collections.Generic.List[string]

# Stream the file line by line
$reader = [System.IO.StreamReader]::new($InputFile)
while (($line = $reader.ReadLine()) -ne $null) {

    # Replace semicolons with colons
    $line = $line.Replace(';', ':')

    # Only keep lines matching the email pattern
    if ($line -match $EmailPattern) {
        $Buffer.Add($line)

        # Flush buffer to disk when full
        if ($Buffer.Count -ge $BufferSize) {
            [System.IO.File]::AppendAllLines($OutputFile, $Buffer)
            $Buffer.Clear()
        }
    }
}

# Final flush for leftover lines
if ($Buffer.Count -gt 0) {
    [System.IO.File]::AppendAllLines($OutputFile, $Buffer)
}

$reader.Close()
