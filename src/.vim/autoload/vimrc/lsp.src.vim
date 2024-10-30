vim9script

if exists('g:vimrc_lsp_lazyloaded')
	finish
endif
g:vimrc_lsp_lazyloaded = 1

packadd lsp

var lspOptions = {
	diagSignErrorText: '🐞',
	diagSignHintText: '💡',
	diagSignInfoText: '💠',
	diagSignWarningText: '🐝',
	showDiagWithVirtualText: true,
	diagVirtualTextAlign: 'after',
}
const commandExt = has('win32') ? '.cmd' : ''
var lspServers = [{
	name: 'typescriptlang',
	filetype: ['javascript', 'typescript'],
	path: $'typescript-language-server{commandExt}',
	args: ['--stdio'],
}, {
	name: 'vimlang',
	filetype: ['vim'],
	path: $'vim-language-server{commandExt}',
	args: ['--stdio'],
}, {
	name: 'htmllang',
	filetype: ['html'],
	path: $'html-languageserver{commandExt}',
	args: ['--stdio'],
}, {
	name: 'jsonlang',
	filetype: ['json'],
	path: $'vscode-json-languageserver{commandExt}',
	args: ['--stdio'],
}]
g:LspOptionsSet(lspOptions)
g:LspAddServer(lspServers)
nnoremap [l <Cmd>LspDiagPrev<CR>
nnoremap ]l <Cmd>LspDiagNext<CR>

export def LazyLoad()
	# nop
enddef
