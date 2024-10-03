vim9script
export def EchoYankText()
const a = get(g:, 'echo_yank_text_title', 'yanked: ')
const b = {
"\<Tab>": get(g:, 'echo_yank_text_tab', '›'),
"\<CR>": get(g:, 'echo_yank_text_cr', '↵')
}
const d = {
"\<Tab>": 'MoreMsg',
"\<CR>": 'MoreMsg'
}
const e = winwidth(0) - 1
if e <= strdisplaywidth(a)
return
endif
echoh WarningMsg
ec a
var w = 0
for c in @"[0 : winwidth(0)]->substitute('\n', "\<CR>", 'g')
var f = get(b, c, c)
w += strdisplaywidth(f)
if e <= w
echoh MoreMsg
echon '>'
echoh MsgArea
return
endif
exe 'echohl' get(d, c, 'MsgArea')
echon f
endfor
echoh MsgArea
enddef
