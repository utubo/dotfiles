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

def System(cmd: list<string>, Cb: func = OK)
	echow cmd->join(' ')
	job_start(cmd, {
		out_cb: EchoW,
		err_cb: EchoW,
		exit_cb: Cb,
	})
enddef

def SystemList(cmd: list<string>): list<string>
	var result = []
	# NOTE: use job_start() instead of system() for windows
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

export def Add(...args: list<string>)
	const current_dir = getcwd()
	try
		chdir(expand('%:p:h'))
		const dryrun = ['git', 'add', '--dry-run'] + args
		echoh MoreMsg
		echo dryrun->join(' ')
		const lines = SystemList(dryrun)
		if !!v:shell_error
			echoh ErrorMsg
			echo lines
			return
		endif
		if !lines
			echo 'Nothing specified, nothing added.'
			return
		endif
		for item in lines
			execute 'echoh' (item =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
			echo item
		endfor
		echoh Question
		const yn = input('execute ? (Y/n) > ', 'y')
		if yn ==# 'y' || yn ==# "\r"
			echoh Normal
			System(['git', 'add'] + args)
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
	return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '✅test:', '⏪revert:', '🔀merge', '🔧chore:', '🎉release:', '💔broke:']
enddef

export def Commit(msg: string)
	System(['git', 'commit', '-m', msg], RefreshSigns)
enddef

export def Amend(msg: string)
	System(['git', 'commit', '--amend', '-m', msg])
enddef

export def GetLastCommitMessage(): string
	return SystemList(['git', 'log', '-1', '--pretty=%B'])[0]
enddef

export def Push(...args: list<string>)
	System(['git', 'push', args], RefreshSigns)
enddef

export def TagPush(tagname: string)
	System(['git', 'tag', tagname], (j, s) => {
		System(['git', 'push', 'origin', tagname])
	})
enddef

export def SetCmdlineForAmend()
	au SafeState * ++once setcmdline($'GitAmend {GetLastCommitMessage()}')
enddef

export def Sync()
	System(['git', 'fetch', 'origin'], (j, s) => {
		System(['git', 'reset', '@{u}', '--hard'])
	})
enddef

export def ShowMenu()
	popselect#Popup([
		{ shortcut: 'u', label: 'Git pull' },
		{ shortcut: 'a', label: 'GitAdd -A' },
		{ shortcut: 'c', label: 'GitCommit', feedkeys: "GitCommit \<Tab>" },
		{ shortcut: 'A', label: 'Amend', feedkeys: "\<Cmd>call vimrc#git#SetCmdlineForAmend()\<CR>" },
		{ shortcut: 'p', label: 'GitPush origin HEAD', wantenter: true},
		{ shortcut: 't', label: 'GitTagPush', feedkeys: 'GitTagPush ' },
		{ shortcut: 'l', label: 'Git log' },
		{ shortcut: 's', label: 'Git status' },
		{ shortcut: 'v', label: 'Gvdiffsplit' },
		{ shortcut: 'd', label: 'Gdiffsplit' },
		{ shortcut: 'C', label: 'Git checkout %' },
		{ shortcut: 'S', label: 'Git restore -staged', feedkeys: 'Git restore -staged ' },
		{ shortcut: 'r', label: 'Git reset --soft', wantenter: true},
		{ shortcut: 'R', label: 'Git reset --hard', wantenter: true},
		{ shortcut: 'y', label: 'Sync', feedkeys: "\<Cmd>call vimrc#git#Sync()\<CR>\<CR>" },
	], {
		oncomplete: (item) => {
			if item->has_key('feedkeys')
				feedkeys($":\<C-u>{item.feedkeys}")
			elseif item->has_key('wantenter')
				feedkeys($":\<C-u>{item.label}")
			else
				feedkeys($":\<C-u>{item.label}\<CR>")
			endif
		},
		filter_focused: false,
		title: 'Git',
	})
enddef

# NOTE: ここに定義するとこのファイルが読み込まれるまで有効にならないけどまぁいいか
command! -nargs=* GitAdd vimrc#git#Add(<f-args>)
command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit vimrc#git#Commit(<q-args>)
command! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitAmend vimrc#git#Amend(<q-args>)
command! -nargs=* GitPush vimrc#git#Push(<f-args>)
command! -nargs=1 GitTagPush vimrc#git#TagPush(<q-args>)

