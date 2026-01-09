vim9script
def A(a: string)
for l in g:SystemList(a)
echow l
endfor
enddef
export def Add(a: string)
const b = getcwd()
try
chdir(expand('%:p:h'))
echoh MoreMsg
ec 'git add --dry-run ' .. a
const c = g:System('git add --dry-run ' .. a)
if !!v:shell_error
echoh ErrorMsg
ec c
return
endif
if !c
ec 'Nothing specified, nothing added.'
return
endif
for d in split(c, '\n')
exe 'echoh' (d =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
ec d
endfor
echoh Question
const e = input('execute ? (Y/n) > ', 'y')
if e ==# 'y' || e ==# "\r"
echoh Normal
g:System('git add ' .. a)
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
return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '⏪revert:', '✅test:', '🔧chore:', '🎉release:', '💔Broke:']
enddef
export def Commit(a: string)
A($'git commit -m {shellescape(a)}')
enddef
export def Amend(a: string)
A($'git commit --amend -m {shellescape(a)}')
enddef
export def GetLastCommitMessage(): string
return g:System($'git log -1 --pretty=%B')->trim()
enddef
export def Push(a: string)
A($'git push {a}')
enddef
export def TagPush(a: string)
A($'git tag {shellescape(a)}')
A($'git push origin {shellescape(a)}')
enddef
