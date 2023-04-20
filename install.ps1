if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.gitignore_global -Path ~/.gitignore_global
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.gvimrc -Path ~/_gvimrc
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vimrc -Path ~/_vimrc
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vsnip -Path ~/.vsnip
mkdir -p ~/vimfiles
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/after -Path ~/vimfiles/after
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/autoload -Path ~/vimfiles/autoload

git config --global core.excludesfile ~/.gitignore_global

