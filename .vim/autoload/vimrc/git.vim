vim9script
def A(j: any, s: any)
echow 'OK.'
enddef
def B(j: any, s: any)
sil! GitGutter
echow 'OK.'
enddef
def C(a: any, b: any)
echow b
enddef
def D(a: list<string>, L: func = A)
echow a->join(' ')
job_start(a, {
out_cb: C,
err_cb: C,
exit_cb: L,
})
enddef
def E(a: list<string>): list<string>
var b = []
var c = job_start(a, {
out_cb: (ch, msg) => {
b->add(msg)
}
})
while job_status(c) ==# 'run'
sleep 10m
endwhile
return b
enddef
export def Add(...a: list<string>)
const b = getcwd()
try
chdir(expand('%:p:h'))
const c = ['git', 'add', '--dry-run'] + a
echoh MoreMsg
ec c->join(' ')
const d = E(c)
if !!v:shell_error
echoh ErrorMsg
ec d
return
endif
if !d
ec 'Nothing specified, nothing added.'
return
endif
for e in d
exe 'echoh' (e =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
ec e
endfor
echoh Question
const f = input('execute ? (Y/n) > ', 'y')
if f ==# 'y' || f ==# "\r"
echoh Normal
D(['git', 'add'] + a)
redraw
else
echoh Normal
redraw
echow 'Canceled.'
endif
finally
echoh Normal
chdir(b)
endtry
enddef
export def ConventionalCommits(a: any, l: string, p: number): list<string>
return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '✅test:', '⏪revert:', '🔀merge', '🔧chore:', '🎉release:', '💔broke:']
enddef
export def Commit(a: string)
D(['git', 'commit', '-m', a], B)
enddef
export def Amend(a: string)
D(['git', 'commit', '--amend', '-m', a])
enddef
export def GetLastCommitMessage(): string
return E(['git', 'log', '-1', '--pretty=%B'])[0]
enddef
export def Push(...a: list<string>)
D(['git', 'push'] + a, B)
enddef
export def TagPush(a: string)
D(['git', 'tag', a], (j, s) => {
D(['git', 'push', 'origin', a])
})
enddef
export def SetCmdlineForAmend()
au SafeState * ++once setcmdline($'GitAmend {GetLastCommitMessage()}')
enddef
export def Sync()
D(['git', 'fetch', 'origin'], (j, s) => {
D(['git', 'reset', '@{u}', '--hard'])
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
com! -nargs=* GitAdd vimrc#git#Add(<f-args>)
com! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit vimrc#git#Commit(<q-args>)
com! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitAmend vimrc#git#Amend(<q-args>)
com! -nargs=* GitPush vimrc#git#Push(<f-args>)
com! -nargs=1 GitTagPush vimrc#git#TagPush(<q-args>)
