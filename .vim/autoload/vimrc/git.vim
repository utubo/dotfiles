vim9script
def A(j: any, s: any)
echow 'OK.'
enddef
def B(j: any, s: any)
sil! GitGutter
echow 'OK.'
enddef
def C(j: any, s: any)
echow s
enddef
def D(a: string, L: func = A)
echow a
job_start(a, {
out_cb: C,
err_cb: C,
exit_cb: L,
})
enddef
def E(a: string): list<string>
var b = []
var c = job_start(a, {
out_cb: (j, s) => {
b->add(s)
}
})
while job_status(c) ==# 'run'
sleep 10m
endwhile
return b
enddef
export def Add(a: string)
const b = getcwd()
try
chdir(expand('%:p:h'))
echoh MoreMsg
ec 'git add --dry-run ' .. a
const c = E('git add --dry-run ' .. a)
if !!v:shell_error
echoh ErrorMsg
ec c
return
endif
if !c
ec 'Nothing specified, nothing added.'
return
endif
for d in c
exe 'echoh' (d =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
ec d
endfor
echoh Question
const e = input('execute ? (Y/n) > ', 'y')
if e ==# 'y' || e ==# "\r"
echoh Normal
D('git add ' .. a)
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
return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '✅test:', '⏪revert:', '🔀merge', '🔧chore:', '🎉release:', '💔Broke:']
enddef
export def Commit(a: string)
D($'git commit -m "{a}"', B)
enddef
export def Amend(a: string)
D($'git commit --amend -m "{a}"')
enddef
export def GetLastCommitMessage(): string
return E($'git log -1 --pretty=%B')[0]
enddef
export def Push(a: string)
D($'git push {a}', B)
enddef
export def TagPush(a: string)
D($'git tag {shellescape(a)}', (j, s) => {
D($'git push origin {shellescape(a)}')
})
enddef
export def ShowMenu()
popselect#Popup([
{ shortcut: 'u', label: 'Git pull' },
{ shortcut: 'a', label: 'GitAdd -A' },
{ shortcut: 'c', label: 'GitCommit', feedkeys: "GitCommit \<Tab>" },
{ shortcut: 'A', label: 'Amend', feedkeys: "call vimrc#git#SetCmdlineForAmend()\<CR>" },
{ shortcut: 'p', label: 'GitPush', feedkeys: 'GitPush' },
{ shortcut: 't', label: 'GitTagPush', feedkeys: 'GitTagPush ' },
{ shortcut: 'l', label: 'Git log' },
{ shortcut: 's', label: 'Git status Sb' },
{ shortcut: 'v', label: 'Gvdiffsplit' },
{ shortcut: 'd', label: 'Gdiffsplit' },
{ shortcut: 'C', label: 'Git checkout %' },
], {
oncomplete: (item) => {
if item->has_key('feedkeys')
feedkeys($":\<C-u>{item.feedkeys}")
else
feedkeys($":\<C-u>{item.label}\<CR>")
endif
},
filter_focused: false,
title: 'Git',
})
enddef
com! -nargs=* GitAdd vimrc#git#Add(<q-args>)
com! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitCommit vimrc#git#Commit(<q-args>)
com! -nargs=1 -complete=customlist,vimrc#git#ConventionalCommits GitAmend vimrc#git#Amend(<q-args>)
com! -nargs=* GitPush vimrc#git#Push(<q-args>)
com! -nargs=1 GitTagPush vimrc#git#TagPush(<q-args>)
