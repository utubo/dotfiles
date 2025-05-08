vim9script

export def LazyLoad()
	Enable  g:ctrlp_use_caching
	Disable g:ctrlp_clear_cache_on_exit
	g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
	g:ctrlp_cmd = 'CtrlPMixed'
	g:ctrlp_working_path_mode = 'ra'
	packadd ctrlp.vim
	packadd ctrlp-matchfuzzy
enddef
