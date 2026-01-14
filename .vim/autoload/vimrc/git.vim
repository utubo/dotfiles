vim9script
def A(j: any, s: any)
enddef
def B(j: any, s: any)
echow s
enddef
def C(j: any, s: any)
sil! GitGutter
enddef
def D(a: string, L: func = B, M: func = A)
echow a
job_start(a, {
out_cb: L,
err_cb: L,
exit_cb: M,
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
return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '✅test:', '⏪revert:', '🔀merge', '🔧chore:', '🎉release:', '💔Broke:']
enddef
export def Commit(a: string)
D($'git commit -m "{a}"', B, C)
enddef
export def Amend(a: string)
D($'git commit --amend -m "{a}"')
enddef
export def GetLastCommitMessage(): string
return E($'git log -1 --pretty=%B')[0]
enddef
export def Push(a: string)
D($'git push {a}', B, C)
enddef
export def TagPush(a: string)
D($'git tag {shellescape(a)}', B, (j, s) => {
D($'git push origin {shellescape(a)}')
})
enddef
