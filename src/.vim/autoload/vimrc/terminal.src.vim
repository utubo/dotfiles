vim9script

export def ApplySettings()
	tnoremap <C-w>; <C-w>:
	tnoremap <C-w><C-w> <C-w>w
	tnoremap <C-w><C-q> exit<CR>
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

