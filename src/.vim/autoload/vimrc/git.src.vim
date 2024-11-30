vim9script

export def Add(args: string)
	const current_dir = getcwd()
	try
		chdir(expand('%:p:h'))
		echoh MoreMsg
		echo 'git add --dry-run ' .. args
		const list = system('git add --dry-run ' .. args)
		if !!v:shell_error
			echoh ErrorMsg
			echo list
			return
		endif
		if !list
			echo 'none.'
			return
		endif
		for item in split(list, '\n')
			execute 'echoh' (item =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
			echo item
		endfor
		echoh Question
		if input('execute ? (y/n) > ', 'y') ==# 'y'
			system('git add ' .. args)
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
	echo system($'git commit -m {shellescape(msg)}')
enddef

export def Amend(msg: string)
	echo system($'git commit --amend -m {shellescape(msg)}')
enddef

export def GetLastCommitMessage(): string
	return system($'git log -1 --pretty=%B')->trim()
enddef

export def TagPush(tagname: string)
	echo system($'git tag {shellescape(tagname)}')
	echo system($'git push origin {shellescape(tagname)}')
enddef

# 以下はvimrcで定義する
# command! -nargs=* GitAdd vimrc#git#Add(<q-args>)
# command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit vimrc#git#Commit(<q-args>)
# command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitAmend vimrc#git#Amend(<q-args>)
# command! -nargs=1 GitTagPush vimrc#git#TagPush(<q-args>)

