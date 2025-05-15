vim9script

export def ApplySettings()
	tnoremap <C-w>; <C-w>:
	tnoremap <C-w><C-w> <C-w>w
	tnoremap <C-w><C-q> exit<CR>
	au vimrc BufEnter * NotifyOnlyTerminal()
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

def IfOnly(): bool
   const bufs = tabpagenr()->tabpagebuflist()
	if bufs->len() !=# 1
		return false
	endif
	if getbufvar(bufs[0], '&buftype') !=# 'terminal'
		return false
	endif
	return true
enddef

var notify_winid = 0
def NotifyOnlyTerminal()
	const b = IfOnly()
	if !b
		if !!notify_winid
			popup_close(notify_winid)
			notify_winid = 0
		endif
	else
		if !notify_winid
			notify_winid = popup_create('vim teminal', {
				col: &columns,
				line: 1,
				pos: 'topright',
			})
		endif
	endif
enddef

