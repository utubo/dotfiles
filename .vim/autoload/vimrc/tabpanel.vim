vim9script
export def Toggle(n: number = 0)
&showtabpanel = n ?? !&showtabpanel ? 2 : 0
enddef
export def IsVisible(): bool
return &showtabpanel ==# 2 || &showtabpanel ==# 1 && 1 < tabpagenr('$')
enddef
export def ProjectName()
const a = ['.git', 'package.json', '.svn', 'go.mod', 'Cargo.toml']
const b = getcwd()
var c = "\ueb46"
var d = ''
for m in a
d = finddir(m, b .. ';')
if !!d
d = d->fnamemodify(':h')
break
endif
endfor
if empty(d)
c = "\uea83"
d = b
endif
g:tabpanel_projectname = c .. fnamemodify(d, ':t')
enddef
