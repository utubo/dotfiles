vim9script

def TruncToDisplayWidth(str: string, width: number): string
	if width <= 0
		return ''
	endif
	return strdisplaywidth(str) <= width ? str : $'{str->matchstr($'.*\%<{width + 1}v')}>'
enddef

export def EchoYankText()
	const title = 'yanked: '
	const  text = @"[0 : winwidth(0)]
		->substitute('\t', '›', 'g')
		->substitute('\n', '↵', 'g')
	echoh WarningMsg
	echo 'yanked: '
	for c in text->TruncToDisplayWidth(winwidth(0) - title->len())
		if c ==# '›' || c ==# '↵'
			echoh MoreMsg
		else
			echoh MsgArea
		endif
		echon c
	endfor
	echoh MsgArea
enddef
