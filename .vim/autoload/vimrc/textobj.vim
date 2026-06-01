vim9script
packadd vim-textobj-user
textobj#user#plugin('line', {
'-': {
'select-a-function': 'vimrc#textobj#CurrentLineA',
'select-a': 'al',
'select-i-function': 'vimrc#textobj#CurrentLineI',
'select-i': 'il',
},
})
export def CurrentLineA(): list<any>
normal! 0
const a = getpos('.')
normal! $
const b = getpos('.')
return ['v', a, b]
enddef
export def CurrentLineI(): list<any>
normal! ^
const a = getpos('.')
normal! g_
const b = getpos('.')
const c = getline('.')[a[2] - 1] !~# '\s'
return c ? ['v', a, b] : 0
enddef
export def LazyLoad()
enddef
