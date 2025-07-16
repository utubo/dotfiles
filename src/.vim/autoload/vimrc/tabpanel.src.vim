vim9script

export def Toggle(n: number = 0)
	&showtabpanel = n ?? !&showtabpanel ? 2 : 0
	&ruler = !!&showtabpanel
enddef

export def IsVisible(): bool
	return &showtabpanel ==# 2 || &showtabpanel ==# 1 && 1 < tabpagenr('$')
enddef
