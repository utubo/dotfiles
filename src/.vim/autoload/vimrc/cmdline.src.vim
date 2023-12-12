vim9script

# `s:///g`を補完 {{{
export def CmdlineAutoSlash(c: string): string
	if getcmdtype() !=# ':'
		return c
	endif
	const cl = getcmdline()
	if getcmdpos() !=# cl->len() + 1 || cl =~# '\s'
		return c
	endif
	const e = cl[-1]
	# :s///g
	if e ==# 's'
		return $"{c}{c}{c}g\<Left>\<Left>\<Left>"
	endif
	# :g!//
	if e ==# 'g' && c ==# '!'
		return "!//\<Left>"
	endif
	# :g//
	if e ==# 'g' || e ==# 'v'
		return $"{c}{c}\<Left>"
	endif
	return c
enddef
#}}}

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

# 端末でAltキー使う {{{
g:alt_flg = false
def AltKey()
	g:alt_flg = true
	Each h,j,k,l cmap {} <ScriptCmd>g:alt_flg = false<Cr><A-{}>
	timer_start(10, (t: number) => {
		Each h,j,k,l cunmap {}
		if g:alt_flg
			feedkeys("\<ESC>", 'nit')
		endif
	})
enddef
cnoremap <script> <ESC> <ScriptCmd>AltKey()<CR>
#}}}

export def ApplySettings()
	cnoremap <A-h> <Left>
	cnoremap <A-p> <Up>
	cnoremap <A-n> <Down>
	cnoremap <A-l> <Right>
	cnoremap <expr> <C-r><C-r> trim(@")->substitute('\n', ' \| ', 'g')
	cnoremap <expr> <C-r><C-e> escape(@", '~^$.*?/\[]')->substitute('\n', '\\n', 'g')
	cnoremap <expr> <Space> MyAbbrev()
	Each /,#,! cnoremap <script> <expr> {} vimrc#cmdline#CmdlineAutoSlash('{}')
	command! -nargs=1 -complete=file MoveFile vimrc#cmdline#MoveFile(<f-args>)
enddef

