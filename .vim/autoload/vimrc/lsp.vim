vim9script
if exists('g:vimrc_lsp_lazyloaded')
finish
endif
g:vimrc_lsp_lazyloaded = 1
packadd lsp
var k = {
diagSignErrorText: '🐞',
diagSignHintText: '💡',
diagSignInfoText: '💠',
diagSignWarningText: '🐝',
showDiagWithVirtualText: true,
diagVirtualTextAlign: 'after',
}
const m = has('win32') ? '.cmd' : ''
var n = [{
name: 'typescriptlang',
filetype: ['javascript', 'typescript'],
path: $'typescript-language-server{m}',
args: ['--stdio'],
}, {
name: 'vimlang',
filetype: ['vim'],
path: $'vim-language-server{m}',
args: ['--stdio'],
}, {
name: 'htmllang',
filetype: ['html'],
path: $'html-languageserver{m}',
args: ['--stdio'],
}, {
name: 'jsonlang',
filetype: ['json'],
path: $'vscode-json-languageserver{m}',
args: ['--stdio'],
}]
g:LspOptionsSet(k)
g:LspAddServer(n)
nn [l <Cmd>LspDiagPrev<CR>
nn ]l <Cmd>LspDiagNext<CR>
export def LazyLoad()
enddef
