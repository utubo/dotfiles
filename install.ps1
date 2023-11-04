if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.gitignore_global -Path ~/.gitignore_global
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.gvimrc -Path ~/_gvimrc
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vimrc -Path ~/_vimrc
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vsnip -Path ~/.vsnip
mkdir -p ~/vimfiles
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/after -Path ~/vimfiles/after
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/autoload -Path ~/vimfiles/autoload
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/scripts.vim -Path ~/vimfiles/scripts.vim

git config --global core.excludesfile ~/.gitignore_global

# choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# npm
choco install -y --force nodejs-lts
npm install -g npm
$node_modules = (npm prefix) + "AppData\Roaming\npm"
$systemPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$systemPath += ";" + $node_modules
[System.Environment]::SetEnvironmentVariable("Path", $systemPath, "Machine")

# node_modules
npm install -g typescript-language-server
npm install -g vim-language-server
npm install -g vscode-html-languageserver-bin
npm install -g vscode-json-languageserver

