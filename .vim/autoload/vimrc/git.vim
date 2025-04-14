vim9script
export def Add(a: string)
const b = getcwd()
try
chdir(expand('%:p:h'))
echoh MoreMsg
ec 'git add --dry-run ' .. a
const c = system('git add --dry-run ' .. a)
if !!v:shell_error
echoh ErrorMsg
ec c
return
endif
if !c
ec 'none.'
return
endif
for d in split(c, '\n')
exe 'echoh' (d =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
ec d
endfor
echoh Question
ec 'execute ? (Y/n) > '
var e = nr2char(getchar())
if e ==# 'y' || e ==# "\r"
echoh Normal
system('git add ' .. a)
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
ec system($'git commit -m {shellescape(a)}')
enddef
export def Amend(a: string)
ec system($'git commit --amend -m {shellescape(a)}')
enddef
export def GetLastCommitMessage(): string
return system($'git log -1 --pretty=%B')->trim()
enddef
export def TagPush(a: string)
ec system($'git tag {shellescape(a)}')
ec system($'git push origin {shellescape(a)}')
enddef
