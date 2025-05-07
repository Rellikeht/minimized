# Choco setup
if (!$(Get-Command "choco.exe" -ErrorAction SilentlyContinue))
{ 
    Set-ExecutionPolicy Bypass -Scope Process
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}


# Choco settings
choco feature enable -n allowGlobalConfirmation

# packages
choco install neovide python git 7zip vifm fzf grep ripgrep
py -m pip install --upgrade pip
py -m pip install pynvim
