vim9script

# ファイルを移動して保存 {{{
export def MoveFile(newname: string)
	const oldpath = expand('%')
	const newpath = expand(newname)
	if ! empty(oldpath) && filereadable(oldpath)
		if filereadable(newpath)
			echoh Error
			echo $'file "{newname}" already exists.'
			echoh None
			return
		endif
		rename(oldpath, newpath)
	endif
	execute 'saveas!' newpath
	# 開き直してMRUに登録
	edit
enddef
#}}}

# cnoreabbrevちょっと改良 {{{
def MyAbbrev(): string
	return {
		cs: "\<C-u>colorscheme ",
		sb: "\<C-u>set background=\<Tab>",
		mv: "\<C-u>MoveFile ",
	}->get(getcmdline(), ' ')
enddef
#}}}

export def ApplySettings()
	cnoremap jj <CR>
	cnoremap jk <C-c>
	cnoremap <A-h> <Left>
	cnoremap <A-j> <Up>
	cnoremap <A-k> <Down>
	cnoremap <A-l> <Right>
	cnoremap ;r <C-r>
	cnoremap <expr> ;rr trim(@")->substitute('\n', ' \| ', 'g')
	cnoremap <expr> ;re escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
	cnoremap <expr> <Space> MyAbbrev()
	command! -nargs=1 -complete=file MoveFile vimrc#cmdline#MoveFile(<f-args>)
enddef

