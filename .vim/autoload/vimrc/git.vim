vim9script
def Nop(j: any, s: any)
enddef
def EchoW(j: any, s: any)
echow s
enddef
def RefreshSigns(j: any, s: any)
sil! GitGutter
enddef
def A(a: string, L: func = EchoW, M: func = Nop)
var d = job_start(a, {
out_cb: L,
exit_cb: M,
})
enddef
def B(a: string): list<string>
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
const c = B('git add --dry-run ' .. a)
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
A('git add ' .. a)
ec 'done.'
else
echoh Normal
redraw
ec 'canceled.'
endif
finally
echoh Normal
chdir(b)
endtry
enddef
export def ConventionalCommits(a: any, l: string, p: number): list<string>
return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '⏪revert:', '✅test:', '🔧chore:', '🎉release:', '💔Broke:']
enddef
export def Commit(a: string)
A($'git commit -m {shellescape(a)}', EchoW, RefreshSigns)
enddef
export def Amend(a: string)
A($'git commit --amend -m {shellescape(a)}')
enddef
export def GetLastCommitMessage(): string
return B($'git log -1 --pretty=%B')[0]
enddef
export def Push(a: string)
A($'git push {a}', EchoW, RefreshSigns)
enddef
export def TagPush(a: string)
A($'git tag {shellescape(a)}', (j, s) => {
A($'git push origin {shellescape(a)}')
})
enddef
