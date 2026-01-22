if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

New-Item -ItemType SymbolicLink -Value $PSScriptRoot/win/Microsoft.PowerShell_profile.ps1 -Path $PROFILE
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.gitignore_global -Path ~/.gitignore_global
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.gvimrc -Path ~/_gvimrc
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vimrc -Path ~/_vimrc
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vsnip -Path ~/.vsnip
mkdir -p ~/vimfiles
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/scripts.vim -Path ~/vimfiles/scripts.vim
# NOTE: ls to refresh symolic link to folders.
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/after -Path ~/vimfiles/after
ls ~/vimfiles/after
New-Item -ItemType SymbolicLink -Value $PSScriptRoot/.vim/autoload -Path ~/vimfiles/autoload
ls ~/vimfiles/autoload

git config --global core.excludesfile ~/.gitignore_global

# skk
cd ~
Invoke-WebRequest -Uri http://openlab.jp/skk/dic/SKK-JISYO.L.gz -OutFile SKK-JISYO.L.gz
$in=[System.IO.File]::OpenRead('SKK-JISYO.L.gz');$out=[System.IO.File]::Create('SKK-JISYO.L');[System.IO.Compression.GzipStream]::new($in,[System.IO.Compression.CompressionMode]::Decompress).CopyTo($out);$in.Close();$out.Close()
Invoke-WebRequest -Uri https://raw.githubusercontent.com/uasi/skk-emoji-jisyo/refs/heads/master/SKK-JISYO.emoji.utf8 -OutFile SKK-JISYO.emoji.utf8

# npm
winget install -e --id OpenJS.NodeJS.LTS
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

