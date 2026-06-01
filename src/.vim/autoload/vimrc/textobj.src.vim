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
  const head_pos = getpos('.')
  normal! $
  const tail_pos = getpos('.')
  return ['v', head_pos, tail_pos]
enddef

export def CurrentLineI(): list<any>
  normal! ^
  const head_pos = getpos('.')
  normal! g_
  const tail_pos = getpos('.')
  const non_blank_char_exists_p = getline('.')[head_pos[2] - 1] !~# '\s'
  return
  \ non_blank_char_exists_p
  \ ? ['v', head_pos, tail_pos]
  \ : 0
enddef

export def LazyLoad()
enddef
