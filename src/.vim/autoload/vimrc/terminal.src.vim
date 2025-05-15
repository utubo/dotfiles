vim9script

export def ApplySettings()
	tnoremap <C-w>; <C-w>:
	tnoremap <C-w><C-w> <C-w>w
	tnoremap <C-w><C-q> exit<CR>
	au vimrc BufEnter * NotifyOnlyTerminalWindow()
enddef

# https://zenn.dev/vim_jp/articles/5fdad17d336c6d
# ・vim9scriptに変更
# ・`-t`でタブで開けるように改造
export def Tapi_drop(bufnr: number, arglist: list<string>)
	const cwd = arglist[0]
	var index = 1
	var opencmd = 'split'
	if arglist[1] ==# '-t'
		# -tオプションが指定された場合はタブで開く
		opencmd = 'tabe'
		index += 1
	endif
	var filepath = arglist[index]
	if !isabsolutepath(filepath)
		# 絶対パスでない時は絶対パスに変換する
		filepath = fnamemodify(cwd, ':p') .. filepath
	endif
	if bufwinnr(bufnr(filepath)) !=# -1
		# ファイルがすでに開かれていればそのウインドウに移動する
		opencmd = 'drop'
	endif
	execute opencmd fnameescape(filepath)
enddef

var notify_winid = 0
def NotifyOnlyTerminalWindow()
   const bufs = tabpagenr()->tabpagebuflist()
	if bufs->len() ==# 1 && bufs[0]->getbufvar('&buftype') ==# 'terminal'
		if !notify_winid
			const [row, col] = win_getid()->win_screenpos()
			const width = winwidth(0)
			notify_winid = popup_create(
				'vim teminal',
				{
					line: &lines,
					# Note: &colulmnsだとtabpageが左にあるときに見切れてしまう
					col: col + width - 1,
					pos: 'topright',
					fixed: true,
				},
			)
		endif
	else
		if !!notify_winid
			popup_close(notify_winid)
			notify_winid = 0
		endif
	endif
enddef

