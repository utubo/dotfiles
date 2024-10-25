vim9script

export def LazyLoad()
	Enable  g:EasyMotion_smartcase
	Enable  g:EasyMotion_use_migemo
	Enable  g:EasyMotion_enter_jump_first
	Disable g:EasyMotion_verbose
	Disable g:EasyMotion_do_mapping
	g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
	g:EasyMotion_prompt = 'EasyMotion: '
	noremap s <Plug>(easymotion-s)
	packadd vim-easymotion
enddef
