#!bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)

ln -s ${SCRIPT_DIR}/.gitignore_global ~
ln -s ${SCRIPT_DIR}/.gvimrc ~
ln -s ${SCRIPT_DIR}/.vimrc ~
ln -s ${SCRIPT_DIR}/.vsnip ~
ln -s ${SCRIPT_DIR}/.zlogin ~
ln -s ${SCRIPT_DIR}/.zlogout ~
ln -s ${SCRIPT_DIR}/.zshrc ~
mkdir -p ~/.vim
ln -s ${SCRIPT_DIR}/.vim/after ~/.vim
ln -s ${SCRIPT_DIR}/.vim/autoload ~/.vim
ln -s ${SCRIPT_DIR}/.vim/scripts.vim ~/.vim

git config --global core.excludesfile ~/.gitignore_global

# skk
cd ~
wget http://openlab.jp/skk/dic/SKK-JISYO.L.gz
gunzip -f SKK-JISYO.L.gz

# nodejs
if command -v npm &> /dev/null; then
	: # OK
else
	if command -v apt &> /dev/null; then
		sudo apt install -y nodejs
	elif command -v yum &> /dev/null; then
		sudo yum install -y nodejs
	elif command -v apk &> /dev/null; then
		sudo apk install -y nodejs
	else
		echo "nodejsをインストールできませんでした。lspが動かないかも" >&2
		exit 0
	fi
fi
sudo npm install -g npm

# node_modules
sudo npm install -g typescript-language-server
sudo npm install -g vim-language-server
sudo npm install -g vscode-html-languageserver-bin
sudo npm install -g vscode-json-languageserver

