vim9script
set enc=utf-8
scripte utf-8
aug gvimrc
au!
aug END
set textwidth=0
set renderoptions=type:directx,renmode:6
set guifont=Cica:h13
def A(d: number)
var f = split(&guifont, ':h')
&guifont = f[0] .. ':h' .. (str2nr(f[1]) + d)
enddef
nn <silent> <M-C-k> <Cmd>call <SID>A(v:count1)<CR>
nn <silent> <M-C-j> <Cmd>call <SID>A(-v:count1)<CR>
nn <silent> <C-ScrollWheelUp> <Cmd>call <SID>A(v:count1)<CR>
nn <silent> <C-ScrollWheelDown> <Cmd>call <SID>A(-v:count1)<CR>
nn <silent> <Esc> <Cmd>set go-=m<Bar>set go-=T<CR>
nn <silent> <M-m> <Cmd>if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>
nn <silent> <M-t> <Cmd>if &go=~#'T'<Bar>set go-=T<Bar>else<Bar>set go+=T<Bar>endif<CR>
set go-=m
set go-=T
g:tabline_mod_sign = '✏'
g:tabline_git_sign = '🐙'
g:tabline_dir_sign = '📂'
g:tabline_term_sign = '⚡'
g:tabline_max_len = 40
set guitablabel=%{vimrc#tabline#MyTablabel()}
g:save_window_file = expand('~/.vimwinpos')
def B()
var a = [
'set background=' .. &bg,
'colorscheme ' .. g:colors_name,
'set columns=' .. &columns,
'set lines=' .. &lines,
'set guifont=' .. &guifont,
'winpos ' .. getwinposx() .. ' ' .. getwinposy(),
]
writefile(a, g:save_window_file)
enddef
au gvimrc VimLeavePre * B()
if filereadable(g:save_window_file)
exe 'source' g:save_window_file
endif
SclowDisable
if has('win32')
no <silent> <M-Space> <Cmd>simalt ~<CR>
nn <S-F2> :<C-u>!winscp_upload.bat <C-r>=expand("%:p")<CR>
endif
