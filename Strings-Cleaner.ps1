### this will hopefully take the strings.txt file from the strings-scanner.ps1 script and take out any non-printable characters and other garbage data, and give us a clean email list

# Input and output files
$InputFile  = "c:\strings.txt"
$OutputFile = "c:\strings_clean.txt"

# Delete old output if it exists
if (Test-Path $OutputFile) { Remove-Item $OutputFile }

$reader = [System.IO.StreamReader]::new($InputFile, [System.Text.Encoding]::UTF8)
$writer = [System.IO.StreamWriter]::new($OutputFile, $false, [System.Text.Encoding]::UTF8)

$lineCount = 0
$flushInterval = 100000

try {
    while (($line = $reader.ReadLine()) -ne $null) {
        # Trim once
        $line = $line.Trim()

        # Replace semicolons with colons
        if ($line.Contains(';')) {
            $line = $line.Replace(';', ':')
        }

        # Remove spaces (faster than regex)
        if ($line.Contains(' ')) {
            $line = $line.Replace(' ', '')
        }

        # Keep only if contains '@'
        if ($line.Contains('@')) {
            $writer.WriteLine($line)
        }

        $lineCount++

        # Flush every 100k lines
        if ($lineCount % $flushInterval -eq 0) {
            $writer.Flush()
        }
    }
}
finally {
    $writer.Flush()
    $writer.Dispose()
    $reader.Dispose()
}
