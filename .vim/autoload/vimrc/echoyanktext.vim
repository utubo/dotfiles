vim9script
def A(a: string, b: number): string
if b <= 0
return ''
endif
return strdisplaywidth(a) <= b ? a : $'{a->matchstr($'.*\%<{b + 1}v')}>'
enddef
export def EchoYankText()
const a = 'yanked: '
const b = @"[0 : winwidth(0)]
->substitute('\t', '›', 'g')
->substitute('\n', '↵', 'g')
echoh WarningMsg
ec 'yanked: '
for c in b->A(winwidth(0) - a->len())
if c ==# '›' || c ==# '↵'
echoh MoreMsg
else
echoh MsgArea
endif
echon c
endfor
echoh MsgArea
enddef
