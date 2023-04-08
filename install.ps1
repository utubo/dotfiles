if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.gitignore_global -Path ~/.gitignore_global
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.gvimrc -Path ~/.gvimrc
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vimrc -Path ~/.vimrc
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vsnip -Path ~/.vsnip
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.zlogin -Path ~/.zlogin
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.zlogout -Path ~/.zlogout
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.zshrc -Path ~/.zshrc
mkdir -p ~/vimfiles
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/after -Path ~/vimfiles/after

git config --global core.excludesfile ~/.gitignore_global

