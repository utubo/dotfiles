vim9script noclear

# repos {{{
def GhRepoListChangePage(op: any)
	var p = str2nr($'{b:repo_list.param.page}')
	if op ==# '+'
		p += 1
	elseif p < 2
		return
	else
		p -= 1
	endif
	b:repo_list.param.page = $'{p}'

	const cmd = printf(
		'e gh://%s/repos?%s',
		b:repo_list.owner,
		gh#http#encode_param(b:repo_list.param)
	)
	gh#gh#delete_buffer(b:, 'gh_repo_list_bufid')
	execute(cmd)
enddef
if !exists('*GhRepoListChangePage')
	g:GhRepoListChangePage = (op: any) => {
		GhRepoListChangePage(op)
	}
endif

export def ReposKeymap()
	nnoremap <buffer> i <ScriptCmd>execute 'edit!' ['gh:/', getline('.')->matchstr('\S\+'), 'issues']->join('/')<CR>
	gh#map#add('gh-buffer-repo-list', 'nnoremap', '<C-h>', '<ScriptCmd>call g:GhRepoListChangePage("-")<CR>')
	gh#map#add('gh-buffer-repo-list', 'nnoremap', '<C-l>', '<ScriptCmd>call g:GhRepoListChangePage("+")<CR>')
enddef
# }}}

# issues {{{
export def OpenCurrentIssues()
	try
		const url = g:System('git remote get-url origin')
		const ownerAndRepo = matchlist(url, '^https://github.com/\(.*\)\.git')[1]
		if !!ownerAndRepo
			execute $'new gh://{ownerAndRepo}/issues'
		endif
	catch
		echo v:exception
	endtry
enddef

export def IssuesKeymap()
	nnoremap <buffer> <CR> <ScriptCmd>execute 'new' [expand('%'), getline('.')->matchstr('[0-9]\+'), 'comments']->join('/')<CR>
	nnoremap <buffer> r <ScriptCmd>execute 'edit!' expand('%:h:h') .. '/repos'<CR>
enddef
# }}}

# issue-comments {{{
export def IssueCommentsKeymap()
	nnoremap <buffer> <CR> <ScriptCmd>execute 'bo vsplit' [expand('%'), getline('.')->matchstr('[0-9]\+')]->join('/')<CR><Cmd>setlocal wrap<CR>
enddef
# }}}

