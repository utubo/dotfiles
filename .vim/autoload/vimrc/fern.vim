vim9script
export def LazyLoad(a: string)
Enable g:fern#default_hidden
g:fern#renderer = "nerdfont"
au vimrc FileType fern {
Enable b:auto_cursorline_disabled
setl cursorline
nn <buffer> <F1> <C-o>
nn <buffer> p <Plug>(fern-action-leave)
}
packadd fern.vim
packadd fern-git-status.vim
packadd fern-renderer-nerdfont.vim
packadd fern-hijack.vim
packadd nerdfont.vim
exe 'Fern' a
enddef
