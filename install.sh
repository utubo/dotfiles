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

# npm
npm install -g npm

# node_modules
npm install -g typescript-language-server
npm install -g vim-language-server
npm install -g vscode-html-languageserver-bin
npm install -g vscode-json-languageserver

