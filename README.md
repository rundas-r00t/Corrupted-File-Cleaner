# Corrupted-File-Cleaner
post-file recovery, powershell script to delete corrupted files


After restoring deleted files via Recuva or similar, many restored files are still corrupted and cannot be opened. this takes up disk space. these various scripts scan the given folder for any files, tries to open them, and if it gets an error upon open, it deletes the file, while writing the filename to a log. this will let you know which files could not be fully restored to a readable state, while giving you back disk space. good for post-forensic file recovery cleanup.


* - for the JPG-Cleanup.ps1, it only looks for jpg's. edit the code to the correct file path you want to scan, prior to running the code. compatible with PS v5.1

* - for the recovered-files-cleanup.ps1, it looks for any file. edit the code to the correct file path you want to scan, prior to running the code. compatible with PS v7+

* - for the corrupted-cleanup-PSv5.1.ps1, it looks for any file. place the script into the folder you want to scan. it will scan that folder and subfolders. compatible with PS v5.1

* - for the strings-scanner.ps1, it looks for strings within files, and for any line that contains an '@' symbol (likely email address), it prints that line into strings.txt. scans recursively and appends to the strings.txt file.
