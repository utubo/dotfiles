vim9script

export def Toggle(n: number = 0)
	&showtabpanel = n ?? !&showtabpanel ? 2 : 0
enddef

export def IsVisible(): bool
	return &showtabpanel ==# 2 || &showtabpanel ==# 1 && 1 < tabpagenr('$')
enddef

export def ProjectName()
	const rootmakers = ['.git', 'package.json', '.svn', 'go.mod', 'Cargo.toml']
	const dir = getcwd()
	var icon = "\ueb46"
	var root = ''
	for m in rootmakers
		if isdirectory(m)
			root = dir
			break
		endif
		root = finddir(m, dir .. ';')
		if !!root
			root = root->fnamemodify(':h')
			break
		endif
	endfor
	if empty(root)
		icon = "\uea83"
		root = dir
	endif
	g:tabpanel_projectname = icon .. fnamemodify(root, ':t')
enddef
