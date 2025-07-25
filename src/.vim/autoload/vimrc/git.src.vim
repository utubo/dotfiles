vim9script

export def Add(args: string)
	const current_dir = getcwd()
	try
		chdir(expand('%:p:h'))
		echoh MoreMsg
		echo 'git add --dry-run ' .. args
		const list = g:System('git add --dry-run ' .. args)
		if !!v:shell_error
			echoh ErrorMsg
			echo list
			return
		endif
		if !list
			echo 'Nothing specified, nothing added.'
			return
		endif
		for item in split(list, '\n')
			execute 'echoh' (item =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
			echo item
		endfor
		echoh Question
		const yn = input('execute ? (Y/n) > ', 'y')
		if yn ==# 'y' || yn ==# "\r"
			echoh Normal
			g:System('git add ' .. args)
			redraw
			echo 'done.'
		else
			echoh Normal
			redraw
			echo 'canceled.'
		endif
	finally
		echoh Normal
		chdir(current_dir)
	endtry
enddef

export def ConventionalCommits(a: any, l: string, p: number): list<string>
	return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '⏪revert:', '✅test:', '🔧chore:', '🎉release:', '💔Broke:']
enddef

export def Commit(msg: string)
	echo g:System($'git commit -m {shellescape(msg)}')
enddef

export def Amend(msg: string)
	echo g:System($'git commit --amend -m {shellescape(msg)}')
enddef

export def GetLastCommitMessage(): string
	return g:System($'git log -1 --pretty=%B')->trim()
enddef

export def TagPush(tagname: string)
	echo g:System($'git tag {shellescape(tagname)}')
	echo g:System($'git push origin {shellescape(tagname)}')
enddef

# 以下はvimrcで定義する
# command! -nargs=* GitAdd vimrc#git#Add(<q-args>)
# command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit vimrc#git#Commit(<q-args>)
# command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitAmend vimrc#git#Amend(<q-args>)
# command! -nargs=1 GitTagPush vimrc#git#TagPush(<q-args>)

