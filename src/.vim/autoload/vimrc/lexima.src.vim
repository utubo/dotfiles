vim9script

export def LazyLoad()
	packadd lexima.vim
	Enable g:lexima_no_default_rules
	g:lexima_map_escape = ''
	lexima#set_default_rules()
	# 正規表現の括弧 `\(\)`と`\{\}`
	lexima#add_rule({ char: '(', at: '\\\%#', input_after: '\)', mode: 'ic' })
	lexima#add_rule({ char: '{', at: '\\\%#', input_after: '\}', mode: 'ic' })
	lexima#add_rule({ char: ')', at: '\%#\\)', leave: 2, mode: 'ic' })
	lexima#add_rule({ char: '}', at: '\%#\\}', leave: 2, mode: 'ic' })
	lexima#add_rule({ char: '\', at: '\%#\\[)}]', leave: 1, mode: 'ic' })
	# cmdlineでの括弧
	au vimrc ModeChanged *:c* ++once {
		for pair in ['()', '{}', '""', "''", '``']
			lexima#add_rule({ char: pair[0], input_after: pair[1], mode: 'c' })
			lexima#add_rule({ char: pair[1], at: '\%#' .. pair[1], leave: 1, mode: 'c' })
		endfor
		# `I'm`を入力できるようにするルール
		lexima#add_rule({ char: "'", at: '[a-zA-Z]\%#''\@!', mode: 'c' })
	}
enddef

