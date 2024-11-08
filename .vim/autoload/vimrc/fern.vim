vim9script
export def LazyLoad(a: string)
Enable g:fern#default_hidden
g:fern#renderer = "nerdfont"
au vimrc FileType fern {
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> <F1> <C-o><Cmd>if &ft ==# 'fern'<Bar>normal<Space><F1><Bar>endif<CR>
setl numberwidth=1
setl number
nn <buffer> 0 <Plug>(fern-action-leave)
for i in range(2, 19)
exe $'nmap <buffer> <silent> {i} :<C-u>{i}<CR><CR>'
endfor
}
sil! unlet g:loaded_fern
packadd fern.vim
packadd fern-git-status.vim
packadd fern-renderer-nerdfont.vim
packadd fern-hijack.vim
packadd nerdfont.vim
exe 'Fern' a
enddef
