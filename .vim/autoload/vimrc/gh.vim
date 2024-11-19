vim9script noclear
def A(a: any)
var p = str2nr($'{b:repo_list.param.page}')
if a ==# '+'
p += 1
elseif p < 2
return
else
p -= 1
endif
b:repo_list.param.page = $'{p}'
const c = printf(
'e gh://%s/repos?%s',
b:repo_list.owner,
gh#http#encode_param(b:repo_list.param)
)
gh#gh#delete_buffer(b:, 'gh_repo_list_bufid')
execute(c)
enddef
if !exists('*GhRepoListChangePage')
g:GhRepoListChangePage = (op: any) => {
A(op)
}
endif
export def ReposKeymap()
nn <buffer> i <ScriptCmd>execute 'edit!' ['gh:/', getline('.')->matchstr('\S\+'), 'issues']->join('/')<CR>
gh#map#add('gh-buffer-repo-list', 'nnoremap', '<C-h>', '<ScriptCmd>call g:GhRepoListChangePage("-")<CR>')
gh#map#add('gh-buffer-repo-list', 'nnoremap', '<C-l>', '<ScriptCmd>call g:GhRepoListChangePage("+")<CR>')
enddef
export def IssuesKeymap()
nn <buffer> <CR> <ScriptCmd>execute 'new' [expand('%'), getline('.')->matchstr('[0-9]\+'), 'comments']->join('/')<CR>
nn <buffer> r <ScriptCmd>execute 'edit!' expand('%:h:h') .. '/repos'<CR>
enddef
export def IssueCommentsKeymap()
nn <buffer> <CR> <ScriptCmd>execute 'bo vsplit' [expand('%'), getline('.')->matchstr('[0-9]\+')]->join('/')<CR><Cmd>setlocal wrap<CR>
enddef
