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
if input('execute ? (y/n) > ', 'y') ==# 'y'
system('git add ' .. a)
endif
finally
echoh Normal
chdir(b)
endtry
enddef
export def ConventionalCommits(a: any, l: string, p: number): list<string>
return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '⏪revert:', '✅test:', '🔧chore:', '🎉release:']
enddef
export def Commit(a: string)
system('git commit -m ' .. a)
enddef
export def TagPush(a: string)
ec system($"git tag '{a}'")
ec system($"git push origin '{a}'")
enddef
