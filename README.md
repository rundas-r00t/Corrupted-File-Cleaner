# Corrupted-File-Cleaner
post-file recovery, powershell script to delete corrupted jpg's


After restoring deleted files via Recuva or similar, many restored files are still corrupted and cannot be opened. this takes up disk space. these various scripts scan the given folder for any files, tries to open them, and if it gets an error upon open, it deletes the file, while writing the filename to a log. this will let you know which files could not be fully restored to a readable state, while giving you back disk space. good for post-forensic file recovery cleanup.
