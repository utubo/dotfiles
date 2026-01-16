vim9script
def A()
for a in ['()', '{}', '""', "''", '``']
lexima#add_rule({ char: a[0], input_after: a[1], mode: 'c' })
lexima#add_rule({ char: a[1], at: '\%#' .. a[1], leave: 1, mode: 'c' })
endfor
lexima#add_rule({ char: "'", at: '[a-zA-Z]\%#''\@!', mode: 'c' })
enddef
export def LazyLoad()
Enable g:lexima_no_default_rules
g:lexima_map_escape = ''
lexima#set_default_rules()
lexima#add_rule({ char: '(', at: '\\\%#', input_after: '\)', mode: 'ic' })
lexima#add_rule({ char: '{', at: '\\\%#', input_after: '\}', mode: 'ic' })
lexima#add_rule({ char: ')', at: '\%#\\)', leave: 2, mode: 'ic' })
lexima#add_rule({ char: '}', at: '\%#\\}', leave: 2, mode: 'ic' })
lexima#add_rule({ char: '\', at: '\%#\\[)}]', leave: 1, mode: 'ic' })
if mode() ==# 'c'
A()
else
au vimrc ModeChanged *:c* ++once A()
endif
enddef
