Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "wsl.exe ~ -d Ubuntu -e emacs", 0, False