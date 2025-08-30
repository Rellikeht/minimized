Set-ExecutionPolicy Unrestricted -Scope Process
$PROFDIR = "$(Split-Path $PROFILE)"
mkdir "$PROFDIR"
cp Microsoft.PowerShell_profile.ps1 "$PROFDIR"
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
Set-ExecutionPolicy Unrestricted -File "$PROFILE"
