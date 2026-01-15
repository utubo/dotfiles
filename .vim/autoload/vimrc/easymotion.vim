vim9script
export def LazyLoad()
Enable g:EasyMotion_smartcase
Enable g:EasyMotion_use_migemo
Enable g:EasyMotion_enter_jump_first
Disable g:EasyMotion_verbose
Disable g:EasyMotion_do_mapping
Disable g:EasyMotion_startofline
g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
g:EasyMotion_prompt = 'EasyMotion: '
no s <ScriptCmd>silent doautocmd User EasyMotionPromptPre<CR><Plug>(easymotion-s)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
packadd vim-easymotion
enddef
