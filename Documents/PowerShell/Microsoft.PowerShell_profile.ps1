
. (Join-Path (Split-Path $PROFILE -Parent) "commands\1pass.ps1")
Invoke-Expression (&starship init powershell)

