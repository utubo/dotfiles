vim9script

def OK(j: any, s: any)
	echow 'OK.'
enddef

def RefreshSigns(j: any, s: any)
	silent! GitGutter
	echow 'OK.'
enddef

def EchoW(j: any, s: any)
	echow s
enddef

def System(cmd: string, Cb: func = OK)
	echow cmd
	job_start(cmd, {
		out_cb: EchoW,
		err_cb: EchoW,
		exit_cb: Cb,
	})
enddef

def SystemList(cmd: string): list<string>
	var result = []
	# NOTE: use job_start() instead system() for windows
	var job = job_start(cmd, {
		out_cb: (j, s) => {
			result->add(s)
		}
	})
	while job_status(job) ==# 'run'
		sleep 10m
	endwhile
	return result
enddef

export def Add(args: string)
	const current_dir = getcwd()
	try
		chdir(expand('%:p:h'))
		echoh MoreMsg
		echo 'git add --dry-run ' .. args
		const list = SystemList('git add --dry-run ' .. args)
		if !!v:shell_error
			echoh ErrorMsg
			echo list
			return
		endif
		if !list
			echo 'Nothing specified, nothing added.'
			return
		endif
		for item in list
			execute 'echoh' (item =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
			echo item
		endfor
		echoh Question
		const yn = input('execute ? (Y/n) > ', 'y')
		if yn ==# 'y' || yn ==# "\r"
			echoh Normal
			System('git add ' .. args)
			redraw
		else
			echoh Normal
			redraw
			echow 'Canceled.'
		endif
	finally
		echoh Normal
		chdir(current_dir)
	endtry
enddef

export def ConventionalCommits(a: any, l: string, p: number): list<string>
	return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '✅test:', '⏪revert:', '🔀merge', '🔧chore:', '🎉release:', '💔Broke:']
enddef

export def Commit(msg: string)
	System($'git commit -m "{msg}"', RefreshSigns)
enddef

export def Amend(msg: string)
	System($'git commit --amend -m "{msg}"')
enddef

export def GetLastCommitMessage(): string
	return SystemList($'git log -1 --pretty=%B')[0]
enddef

export def Push(args: string)
	System($'git push {args}', RefreshSigns)
enddef

export def TagPush(tagname: string)
	System($'git tag {shellescape(tagname)}', (j, s) => {
		System($'git push origin {shellescape(tagname)}')
	})
enddef

# 以下はvimrcで定義する
# command! -nargs=* GitAdd vimrc#git#Add(<q-args>)
# command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit vimrc#git#Commit(<q-args>)
# command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitAmend vimrc#git#Amend(<q-args>)
# command! -nargs=1 GitTagPush vimrc#git#TagPush(<q-args>)

