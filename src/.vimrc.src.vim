vim9script noclear
set encoding=utf-8
scriptencoding utf-8

# ------------------------------------------------------
# 基本設定 {{{
set fileencodings=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp
set noexpandtab
set tabstop=3 # 意外とありな気がしてきた…
set shiftwidth=0
set softtabstop=0
set autoindent
set smartindent
set breakindent
set backspace=indent,start,eol
set nf=alpha,hex
set virtualedit=block
set list
set listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:%
set fillchars=
set cmdheight=1
set noshowcmd
set noshowmode
set display=lastline
set ambiwidth=double
set belloff=all
set ttimeoutlen=50
set wildmenu
set wildcharm=<Tab>
set autochdir
set backupskip=/var/tmp/*
set undodir=~/.vim/undo
set undofile
set updatetime=2000
set incsearch
set hlsearch

augroup vimrc
	# 新しい自由
	au!
augroup End
#}}} -------------------------------------------------------

# ------------------------------------------------------
# ユーティリティ {{{
const rtproot = has('win32') ? '~/vimfiles' : '~/.vim'
const has_deno = executable('deno')

# こんな感じ
#   Each nmap,xmap j gj
#   → nmap j gj | xmap j gj
# 先頭以外に差し込んだりネストしたい場合はこう
#   Each j,k Each nmap,xmap {1} {0} g{0}
#   → nmap j gj | xmap j gj | nmap k gk | xmap k gk
# ※これ使うよりべたで書いたほうが起動は速い
var nestOfEach = 0
def Each(qargs: string)
	const [items, args] = qargs->split('^\S*\zs')
	nestOfEach += 1
	for i in items->split(',')
		var a = args->substitute('{0\?}', i, 'g')
		if a ==# args
			a = $'{i} {a}'
		endif
		execute a->substitute($"\{{nestOfEach}\}", '{}', 'g')
	endfor
	nestOfEach -= 1
enddef
command! -nargs=* Each Each(<q-args>)

# その他
command! -nargs=1 -complete=var Enable  <args> = 1
command! -nargs=1 -complete=var Disable <args> = 0

def BufIsSmth(): bool
	return &modified || ! empty(bufname())
enddef

def g:IndentStr(expr: any): string
	return matchstr(getline(expr), '^\s*')
enddef

def StayCurPos(expr: string)
	const len = getline('.')->len()
	var cur = getcurpos()
	execute expr
	cur[2] += getline('.')->len() - len
	setpos('.', cur)
enddef

# <Cmd>でdefを実行したときのビジュアルモードの範囲(行)
def! g:VFirstLast(): list<number>
	return [line('.'), line('v')]->sort('n')
enddef

def! g:VRange(): list<number>
	const a = g:VFirstLast()
	return range(a[0], a[1])
enddef
#}}} -------------------------------------------------------

# ------------------------------------------------------
# プラグイン {{{

# jetpack {{{
const jetpackfile = expand( $'{rtproot}/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim')
const has_jetpack = filereadable(jetpackfile)
if ! has_jetpack
	const jetpackurl = 'https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim'
	system($'curl -fsSLo {jetpackfile} --create-dirs {jetpackurl}')
endif

packadd vim-jetpack
jetpack#begin()
Jetpack 'tani/vim-jetpack', { 'opt': 1 }
Jetpack 'airblade/vim-gitgutter'
Jetpack 'cohama/lexima.vim' # 括弧補完
Jetpack 'delphinus/vim-auto-cursorline'
Jetpack 'easymotion/vim-easymotion'
Jetpack 'girishji/vimcomplete'
#Jetpack 'girishji/autosuggest.vim' ちょっとWindowsで動きが怪しい
#Jetpack 'github/copilot.vim' #重い
Jetpack 'hrsh7th/vim-vsnip'
Jetpack 'hrsh7th/vim-vsnip-integ'
Jetpack 'itchyny/calendar.vim'
Jetpack 'kana/vim-textobj-user'
Jetpack 'kana/vim-smartword'
Jetpack 'KentoOgata/vim-vimscript-gd'
Jetpack 'LeafCage/vimhelpgenerator'
Jetpack 'luochen1990/rainbow' # 虹色括弧
Jetpack 'machakann/vim-sandwich'
Jetpack 'mattn/vim-notification'
Jetpack 'matze/vim-move' # 行移動
Jetpack 'michaeljsmith/vim-indent-object'
Jetpack 'MTDL9/vim-log-highlighting'
Jetpack 'obcat/vim-hitspop'
Jetpack 'obcat/vim-sclow' # スクロールバー
Jetpack 'osyo-manga/vim-textobj-multiblock'
Jetpack 'skanehira/gh.vim'
Jetpack 'thinca/vim-portal'
Jetpack 'thinca/vim-themis'
Jetpack 'tpope/vim-fugitive' # Gdiffとか
Jetpack 'tyru/capture.vim' # 実行結果をバッファにキャプチャ
Jetpack 'tyru/caw.vim' # コメント化
Jetpack 'yegappan/lsp'
Jetpack 'yegappan/mru'
Jetpack 'yuki-yano/dedent-yank.vim' # yankするときにインデントを除去
Jetpack 'vim-jp/vital.vim'
# Fern
Jetpack 'lambdalisue/fern.vim'
Jetpack 'lambdalisue/fern-git-status.vim'
Jetpack 'lambdalisue/fern-renderer-nerdfont.vim'
Jetpack 'lambdalisue/fern-hijack.vim'
Jetpack 'lambdalisue/nerdfont.vim'
# 👀様子見中
Jetpack 'ctrlpvim/ctrlp.vim'
Jetpack 'mattn/ctrlp-matchfuzzy'
Jetpack 'sheerun/vim-polyglot' # いろんなシンタックスハイライト
Jetpack 'tani/vim-typo'
# 🐶🍚
Jetpack 'utubo/vim-altkey-in-term'
Jetpack 'utubo/vim-colorscheme-girly'
Jetpack 'utubo/vim-colorscheme-softgreen'
Jetpack 'utubo/vim-hlpairs'
Jetpack 'utubo/vim-minviml'
Jetpack 'utubo/vim-registers-lite'
Jetpack 'utubo/vim-reformatdate'
Jetpack 'utubo/vim-skipslash'
Jetpack 'utubo/vim-yomigana'
Jetpack 'utubo/vim-vim9skk'
Jetpack 'utubo/vim-zenmode'
# 🐶🍚様子見中
Jetpack 'utubo/jumpcursor.vim'
Jetpack 'utubo/vim-ddgv'
Jetpack 'utubo/vim-portal-aim'
Jetpack 'utubo/vim-shrink'
Jetpack 'utubo/vim-tablist'
Jetpack 'utubo/vim-tabpopupmenu'
Jetpack 'utubo/vim-textobj-twochars'
# 🐶✋🍚
#Jetpack 'utubo/vim-cmdheight0'

if has_deno
	Jetpack 'vim-denops/denops.vim'
endif
jetpack#end()
if ! has_jetpack
	jetpack#sync()
endif
#}}}

# zenmode {{{
g:zenmode = {}
au vimrc User Vim9skkModeChanged zenmode#Invalidate()
#}}}

# easymotion {{{
Enable  g:EasyMotion_smartcase
Enable  g:EasyMotion_use_migemo
Enable  g:EasyMotion_enter_jump_first
Disable g:EasyMotion_verbose
Disable g:EasyMotion_do_mapping
g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ;'
g:EasyMotion_prompt = 'EasyMotion: '
noremap s <Plug>(easymotion-s)
#}}}

# fern {{{
Enable g:fern#default_hidden
g:fern#renderer = "nerdfont"
au vimrc FileType fern {
	Enable b:auto_cursorline_disabled
	setlocal cursorline
	nnoremap <buffer> <F1> <Cmd>:q!<CR>
	nnoremap <buffer> p <Plug>(fern-action-leave)
}
nnoremap <expr> <F1> $"\<Cmd>Fern . -reveal=% -opener={!bufname() && !&mod ? 'edit' : 'split'}\<CR>"
#}}}

# Git {{{
def GitAdd(args: string)
	const current_dir = getcwd()
	try
		chdir(expand('%:p:h'))
		echoh MoreMsg
		echo 'git add --dry-run ' .. args
		const list = system('git add --dry-run ' .. args)
		if !!v:shell_error
			echoh ErrorMsg
			echo list
			return
		endif
		if !list
			echo 'none.'
			return
		endif
		for item in split(list, '\n')
			execute 'echoh' (item =~# '^remove' ? 'DiffDelete' : 'DiffAdd')
			echo item
		endfor
		echoh Question
		if input('execute ? (y/n) > ', 'y') ==# 'y'
			system('git add ' .. args)
		endif
	finally
		echoh Normal
		chdir(current_dir)
	endtry
enddef
command! -nargs=* GitAdd GitAdd(<q-args>)
def! g:ConventionalCommits(a: any, l: string, p: number): list<string>
	return ['✨feat:', '🐞fix:', '📝docs:', '🔨refactor:', '🎨style:', '⏪revert:', '✅test:', '🔧chore:', '🎉release:']
enddef
command! -nargs=1 -complete=customlist,g:ConventionalCommits GitCommit Git commit -m <q-args>
def GitTagPush(tagname: string)
	echo system($"git tag '{tagname}'")
	echo system($"git push origin '{tagname}'")
enddef
command! -nargs=1 GitTagPush GitTagPush(<q-args>)
nnoremap <Space>ga <Cmd>GitAdd -A<CR>
nnoremap <Space>gA :<C-u>Git add %
nnoremap <Space>gc :<C-u>GitCommit<Space><Tab>
nnoremap <Space>gp :<C-u>Git push<End>
nnoremap <Space>gs <Cmd>Git status -sb<CR>
nnoremap <Space>gv <Cmd>Gvdiffsplit<CR>
nnoremap <Space>gd <Cmd>Gdiffsplit<CR>
nnoremap <Space>gl <Cmd>Git pull<CR>
nnoremap <Space>gt :<C-u>GitTagPush<Space>
nnoremap <Space>gC :<C-u>Git checkout %
#}}}

# gh {{{
# ftpluginにすると定義がバラバラになって見通し悪くなるかな
au vimrc FileType gh-repos {
	nnoremap <buffer> i <ScriptCmd>execute 'edit!' ['gh:/', getline('.')->matchstr('\S\+'), 'issues']->join('/')<CR>
}
au vimrc FileType gh-issues {
	nnoremap <buffer> <CR> <ScriptCmd>execute 'new' [expand('%'), getline('.')->matchstr('[0-9]\+'), 'comments']->join('/')<CR>
	nnoremap <buffer> r <ScriptCmd>execute 'edit!' expand('%:h:h') .. '/repos'<CR>
}
au vimrc FileType gh-issue-comments {
	nnoremap <buffer> <CR> <ScriptCmd>execute 'bo vsplit' [expand('%'), getline('.')->matchstr('[0-9]\+')]->join('/')<CR><Cmd>setlocal wrap<CR>
}
nnoremap <Space>gh <Cmd>tabe gh://utubo/repos<CR>
# }}}

# lexima {{{
#Enable g:lexima_accept_pum_with_enter
Enable g:lexima_no_default_rules
lexima#set_default_rules()
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : (lexima#expand('<CR>', 'i') .. "\<ScriptCmd>doau User InputCR\<CR>")

# 正規表現の括弧 `\(\)`と`\{\}`
def g:SetupLexima(timer: number)
	lexima#add_rule({ char: '(', at: '\\\%#', input_after: '\)', mode: 'ic' })
	lexima#add_rule({ char: '{', at: '\\\%#', input_after: '\}', mode: 'ic' })
	lexima#add_rule({ char: ')', at: '\%#\\)', leave: 2, mode: 'ic' })
	lexima#add_rule({ char: '}', at: '\%#\\}', leave: 2, mode: 'ic' })
	lexima#add_rule({ char: '\', at: '\%#\\[)}]', leave: 1, mode: 'ic' })
	# cmdlineでの括弧
	au vimrc ModeChanged *:c* ++once {
		for pair in ['()', '{}', '""', "''", '``']
			lexima#add_rule({ char: pair[0], input_after: pair[1], mode: 'c' })
			lexima#add_rule({ char: pair[1], at: '\%#' .. pair[1], leave: 1, mode: 'c' })
		endfor
		# `I'm`を入力できるようにするルール
		lexima#add_rule({ char: "'", at: '[a-zA-Z]\%#''\@!', mode: 'c' })
	}
enddef
timer_start(1000, g:SetupLexima)
# }}}

# LSP {{{
# minviml:fixed=lspOptions,lspServers
var lspOptions = {
	diagSignErrorText: '🐞',
	diagSignHintText: '💡',
	diagSignInfoText: '💠',
	diagSignWarningText: '🐝',
	showDiagWithVirtualText: true,
	diagVirtualTextAlign: 'after',
}
const commandExt = has('win32') ? '.cmd' : ''
var lspServers = [{
	name: 'typescriptlang',
	filetype: ['javascript', 'typescript'],
	path: $'typescript-language-server{commandExt}',
	args: ['--stdio'],
}, {
	name: 'vimlang',
	filetype: ['vim'],
	path: $'vim-language-server{commandExt}',
	args: ['--stdio'],
}, {
	name: 'htmllang',
	filetype: ['html'],
	path: $'html-languageserver{commandExt}',
	args: ['--stdio'],
}, {
	name: 'jsonlang',
	filetype: ['json'],
	path: $'vscode-json-languageserver{commandExt}',
	args: ['--stdio'],
}]
au vimrc VimEnter * call LspOptionsSet(lspOptions)
au vimrc VimEnter * call LspAddServer(lspServers)
nnoremap [l <Cmd>LspDiagPrev<CR>
nnoremap ]l <Cmd>LspDiagNext<CR>
#}}}

# MRU {{{
nnoremap <F2> <Cmd>MRUToggle<CR>
g:MRU_Exclude_Files = has('win32') ? $'{$TEMP}\\.*' : '^/tmp/.*\|^/var/tmp/.*'
# MRUに関してのその他の設定は.vim/after/ftplugin/mru.src.vimで指定している
#}}}

# Portal {{{
nnoremap <Leader>a <Cmd>PortalAim<CR>
nnoremap <Leader>b <Cmd>PortalAim blue<CR>
nnoremap <Leader>o <Cmd>PortalAim orange<CR>
nnoremap <Leader>r <Cmd>PortalReset<CR>
#}}}

# sandwich {{{
Enable g:sandwich_no_default_key_mappings
Enable g:operator_sandwich_no_default_key_mappings
Each nmap,xmap S <ScriptCmd>vimrc#sandwich#ApplySettings('S')<CR>
#}}}

# vim9skk {{{
g:vim9skk = {
	keymap: {
		toggle: ['<C-j>', ';j'],
		midasi: [':', 'Q'],
	}
}
g:vim9skk_mode = '' # statuslineでエラーにならないように念の為設定しておく
nnoremap ;j i<Plug>(vim9skk-enable)
# 見出しモードでスタートする
au vimrc User Vim9skkEnter feedkeys('Q')
# AZIKライクな設定とか
au vimrc User Vim9skkInitPre vimrc#vim9skk#ApplySettings()
#}}}

# textobj-user {{{
Each onoremap,xnoremap ab <Plug>(textobj-multiblock-a)
Each onoremap,xnoremap ib <Plug>(textobj-multiblock-i)
g:textobj_multiblock_blocks = [
	[ "(", ")" ],
	[ "[", "]" ],
	[ "{", "}" ],
	[ '<', '>' ],
	[ '"', '"', 1 ],
	[ "'", "'", 1 ],
	[ ">", "<", 1 ],
	[ "「", "」", 1 ],
]
call textobj#user#plugin('nonwhitespace', {
	'-': { 'pattern': '\S\+', 'select': ['a<Space>', 'i<Space>'], }
})
#}}}

# 補完 {{{
def SkipParen(): string
	const c = matchstr(getline('.'), '.', col('.') - 1)
	# 閉じ括弧の間にTAB文字を入れることはないだろう…
	if !c || stridx(')]}>"''`」', c) ==# -1
		return "\<Tab>"
	else
		return  "\<C-o>a"
	endif
enddef
Each imap,smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-n>' : SkipParen()
Each imap,smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
# Copilotは様子見
#g:copilot_no_tab_map = true
#imap <silent> <script> <expr> ;c copilot#Accept("\<CR>")
#au vimrc VimEnter * Copilot disable
#}}}

# 🐶🍚 {{{
g:skipslash_autocomplete = 1
g:loaded_matchparen = 1
g:loaded_matchit = 1
nnoremap % <ScriptCmd>hlpairs#Jump()<CR>
nnoremap ]% <ScriptCmd>hlpairs#Jump('f')<CR>
nnoremap [% <ScriptCmd>hlpairs#Jump('b')<CR>
nnoremap <Leader>% <ScriptCmd>hlpairs#HighlightOuter()<CR>
nnoremap <Space>% <ScriptCmd>hlpairs#ReturnCursor()<CR>
nnoremap <Space>t <ScriptCmd>tabpopupmenu#popup()<CR>
nnoremap <Space>T <ScriptCmd>tablist#Show()<CR>
Each nnoremap,tnoremap <silent> <C-w><C-s> <Plug>(shrink-height)<C-w>w
Each nnoremap,tnoremap <silent> <C-w><C-h> <Plug>(shrink-width)<C-w>w
noremap <Space>s <Plug>(jumpcursor-jump)
au vimrc VimEnter * hlpairs#TextObjUserMap('%')
# }}}

# その他 {{{
Enable g:rainbow_active
Enable  g:ctrlp_use_caching
Disable g:ctrlp_clear_cache_on_exit
g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}
g:ctrlp_cmd = 'CtrlPMixed'
g:auto_cursorline_wait_ms = &updatetime
Each w,b,e,ge nnoremap {0} <Plug>(smartword-{0})
nnoremap [c <Plug>(GitGutterPrevHunk)
nnoremap ]c <Plug>(GitGutterNextHunk)
Each nnoremap,xnoremap <Space>c <Plug>(caw:hatpos:toggle)
#}}}

# 開発用 {{{
g:vimhelpgenerator_version = ''
g:vimhelpgenerator_author = 'Author  : utubo'
g:vimhelpgenerator_defaultlanguage = 'en'
g:vimhelpgenerator_uri = 'https://github.com/utubo/'
#}}}

filetype plugin indent on
#}}} -------------------------------------------------------

# ------------------------------------------------------
# コピペ寄せ集め色々 {{{
au vimrc InsertLeave * set nopaste
au vimrc BufReadPost *.log* normal! G
xnoremap * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
# https://github.com/astrorobot110/myvimrc/blob/master/vimrc
set matchpairs+=（:）,「:」,『:』,【:】,［:］,＜:＞
# https://github.com/Omochice/dotfiles
Each i,a,A nnoremap <expr> {0} !empty(getline('.')) ? '{0}' : '"_cc'
# すごい
# https://zenn.dev/mattn/articles/83c2d4c7645faa
Each +,-,>,< Each nmap,tmap <C-w>{0} <C-w>{0}<SID>ws
Each +,-,>,< Each nnoremap,tnoremap <script> <SID>ws{0} <C-w>{0}<SID>ws
Each nmap,tmap <SID>ws <Nop>
# 感謝
# https://zenn.dev/vim_jp/articles/43d021f461f3a4
nnoremap <A-J> <Cmd>copy.<CR>
nnoremap <A-K> <Cmd>copy-1<CR>
xnoremap <A-J> :copy'<-1<CR>gv
xnoremap <A-K> :copy'>+0<CR>gv

#}}} -------------------------------------------------------

# ------------------------------------------------------
# タブ幅やタブ展開を自動設定 {{{
def SetupTabstop()
	const limit = 100
	const org = getpos('.')
	cursor(1, 1)
	if !!search('^\t', 'nc', limit)
		setlocal noexpandtab
		setlocal tabstop=3 # 意外とありな気がしてきた…
	elseif !!search('^  \S', 'nc', limit)
		setlocal expandtab
		setlocal tabstop=2
	elseif !!search('^    \S', 'nc', limit)
		setlocal expandtab
		setlocal tabstop=4
	endif
	&shiftwidth = &tabstop
	&softtabstop = &tabstop
	setpos('.', org)
enddef
au vimrc BufReadPost * SetupTabstop()
#}}} -------------------------------------------------------

# ------------------------------------------------------
# vimgrep {{{
command! -nargs=+ -complete=dir VimGrep vimrc#myutil#VimGrep(<f-args>)
au vimrc WinEnter * if winnr('$') ==# 1 && &buftype ==# 'quickfix' | q | endif
#}}} -------------------------------------------------------

# ------------------------------------------------------
# diff {{{
set splitright
set fillchars+=diff:\ # 削除行は空白文字で埋める
# diffモードを自動でoff https://hail2u.net/blog/software/vim-turn-off-diff-mode-automatically.html
au vimrc WinEnter * if (winnr('$') ==# 1) && !!getbufvar(winbufnr(0), '&diff') | diffoff | endif
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 日付関係 {{{
g:reformatdate_extend_names = [{
	a: ['日', '月', '火', '水', '木', '金', '土'],
	A: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
}]
g:reformatdate_extend_formats = ['%m/%d(%a)']
reformatdate#init()
inoremap <expr> <F5> strftime('%Y/%m/%d')
cnoremap <expr> <F5> strftime('%Y%m%d')
nnoremap <F5> <ScriptCmd>reformatdate#reformat(localtime())<CR>
nnoremap <C-a> <ScriptCmd>reformatdate#inc(v:count)<CR>
nnoremap <C-x> <ScriptCmd>reformatdate#dec(v:count)<CR>
nnoremap <Space><F5> /\d\{4\}\/\d\d\/\d\d<CR>
#}}} -------------------------------------------------------

# ------------------------------------------------------
# スマホ用 {{{
# - キーが小さいので押しにくいものはSpaceへマッピング
# - スマホでのコーディングは基本的にバグ取り
# スタックトレースからyankしてソースの該当箇所を探すのを補助
nnoremap <Space>e G?\cErr\\|Exception<CR>
nnoremap <expr> <Space>f $'{(getreg('"') =~ '^\d\+$' ? ':' : '/')}{getreg('"')}<CR>'
# スマホだと:と/とファンクションキーが遠いので…
nmap <Space>. :
nmap <Space>, /
nmap g<Space> g;
for i in range(1, 10)
	execute $'nmap <Space>{i % 10} <F{i}>'
endfor
nmap <Space><Space>1 <F11>
nmap <Space><Space>2 <F12>
# その他
nnoremap <Space>a A
nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap <Space>y yiw
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 折り畳み {{{
# こんなかんじでインデントに合わせて表示📁 {{{
def! g:MyFoldText(): string
	const src = getline(v:foldstart)
	const indent = repeat(' ', indent(v:foldstart))
	if &foldmethod ==# 'indent'
		return $'{indent}📁 {v:foldend - v:foldstart + 1}lines'
	else
		const text = src->substitute(matchstr(&foldmarker, '^[^,]*'), '', '')->trim()
		return $'{indent}{text} 📁'
	endif
enddef
set foldtext=g:MyFoldText()
set fillchars+=fold:\ # 折り畳み時の「-」は半角空白
au vimrc ColorScheme * {
	hi! link Folded Delimiter
	hi! link ALEVirtualTextWarning ALEWarningSign
	hi! link ALEVirtualTextError ALEErrorSign
}
#}}}
# その他折りたたみ関係 {{{
set foldmethod=marker
au vimrc FileType markdown,yaml setlocal foldlevelstart=99 foldmethod=indent
au vimrc BufReadPost * :silent! normal! zO
nnoremap <expr> h (col('.') ==# 1 && 0 < foldlevel('.') ? 'zc' : 'h')
nnoremap Z<Tab> <Cmd>set foldmethod=indent<CR>
nnoremap Z{ <Cmd>set foldmethod=marker<CR>
nnoremap Zy <Cmd>set foldmethod=syntax<CR>
xnoremap zf <ScriptCmd>vimrc#myutil#Zf()<CR>
nnoremap zd <ScriptCmd>vimrc#myutil#Zd()<CR>
nnoremap <silent> g; g;zO
#}}}
#}}} -------------------------------------------------------

# ------------------------------------------------------
# バッファ操作 {{{
nnoremap gn <Cmd>bnext<CR>
nnoremap gp <Cmd>bprevious<CR>
g:recentBufnr = 0
au vimrc BufLeave * g:recentBufnr = bufnr()
nnoremap <expr> gr $"\<Cmd>b{g:recentBufnr}\<CR>"

# 複数開いているときだけ自作buflineを表示する
var bufitems = []
def RefreshBufList()
	bufitems = []
	for ls in execute('ls')->split("\n")
		const m = ls->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" \+line [0-9]\+')
		if !m->empty()
			var b = {
				nr: m[1],
				name: m[2][2] =~# '[RF?]' ? '[Term]' : m[3]->pathshorten(),
				current: m[2][0] ==# '%',
			}
			bufitems += [b]
			b.width = strdisplaywidth($' {b.nr}{b.name} ')
		endif
	endfor
	EchoBufLine()
	g:zenmode.preventEcho = bufitems->len() > 1
enddef
def EchoBufLine()
	if bufitems->len() <= 1
		return
	endif
	if mode() ==# 'c'
		return
	endif
	redraw
	var s = 0
	var e = 0
	var w = 0
	var hasNext = false
	var hasPrev = false
	var containCurrent = false
	for b in bufitems
		w += b.width
		if &columns - 5 < w
			if containCurrent
				e -= 1
				hasNext = true
				break
			endif
			s += 1
			hasPrev = true
		endif
		if b.current
			containCurrent = true
		endif
		e += 1
	endfor
	w = getwininfo(win_getid(1))[0].textoff
	echohl TablineFill
	echon repeat(' ', w)
	if hasPrev
		echohl Tabline
		echon '< '
		w += 2
	endif
	for b in bufitems[s : e]
		w += b.width
		if b.current
			echohl TablineSel
		else
			echohl Tabline
		endif
		echon $'{b.nr} {b.name} '
	endfor
	if hasNext
		echohl Tabline
		echon '>'
		w += 1
	endif
	const pad = &columns - 1 - w
	if 0 < pad
		echohl TablineFill
		echon repeat(' ', &columns - 1 - w)
	endif
	echohl Normal
enddef
au vimrc BufAdd,BufEnter,BufDelete,BufWipeout * au vimrc SafeStateAgain * ++once RefreshBufList()
au vimrc CursorMoved * EchoBufLine()
#}}}

# ------------------------------------------------------
# Tabline {{{
set tabline=%!vimrc#tabline#MyTabline()
set guitablabel=%{vimrc#tabline#MyTablabel()}
#}}}

# ------------------------------------------------------
# セミコロン {{{
# インサートモードでも使うプレフィックス
# `;m`ちょっと押しにくいな…`;f`はどうかな？
Each map,map! ;m <SID>(cancel)
Each map,map! ;f <SID>(cancel)
inoremap <SID>(cancel) <Esc>`^
Each noremap,cnoremap <SID>(cancel) <Esc>
cnoremap ;n <CR>
Each nnoremap,inoremap ;n <Cmd>update<CR><Esc>
inoremap ;v ;<CR>
inoremap ;w <C-o>e<C-o>a
inoremap ;k 「」<C-g>U<Left>
inoremap ;l <C-g>R<Right>
inoremap ;u <Esc>u
nnoremap ;r "
nnoremap ;rr "0p
Each nnoremap,inoremap ;<Tab> <ScriptCmd>StayCurPos('normal! >>')<CR>
Each nnoremap,inoremap ;<S-Tab> <ScriptCmd>StayCurPos('normal! <<')<CR>
nnoremap <Space>; ;
# `;h`+`h`連打で<BS>
map! <script> <SID>bs_ <Nop>
map! <script> ;h <SID>bs_h
noremap! <script> <SID>bs_h <BS><SID>bs_
# }}}

# ------------------------------------------------------
# ビジュアルモードあれこれ {{{
xnoremap u <ScriptCmd>undo\|normal! gv<CR>
xnoremap <C-R> <ScriptCmd>redo\|normal! gv<CR>
xnoremap <Tab> <ScriptCmd>StayCurPos('normal! >gv')<CR>
xnoremap <S-Tab> <ScriptCmd>StayCurPos('normal! <gv')<CR>
const vmode = ['v', 'V', "\<C-v>", "\<ESC>"] # minviml:fixed=vmode
xnoremap <script> <expr> v vmode[vmode->index(mode()) + 1]
#}}}

# ------------------------------------------------------
# コマンドモードあれこれ {{{
Each nnoremap,xnoremap / <Cmd>noh<CR>/
Each nnoremap,xnoremap ? <Cmd>noh<CR>?
# 考え中
Each nnoremap,xnoremap ;c :
Each nnoremap,xnoremap ;s <Cmd>noh<CR>/
Each nnoremap,xnoremap + :
Each nnoremap,xnoremap , :
Each nnoremap,xnoremap <Space><Space>, ,
# その他の設定
au vimrc CmdlineEnter * ++once vimrc#cmdline#ApplySettings()
#}}}

# ------------------------------------------------------
# terminalとか {{{
# `SH`で開く
if has('win32')
	command! Powershell :bo terminal ++close pwsh
	nnoremap SH <Cmd>Powershell<CR>
	nnoremap <S-F1> <Cmd>silent !start explorer %:p:h<CR>
else
	nnoremap SH <Cmd>bo terminal<CR>
endif
# `drop`コマンドでterminalからvimで開く
def g:Tapi_drop(bufnr: number, arglist: list<string>)
	 vimrc#terminal#Tapi_drop(bufnr, arglist)
enddef
# その他の設定
au vimrc TerminalOpen * ++once vimrc#terminal#ApplySettings()

#}}} -------------------------------------------------------

# ------------------------------------------------------
# バッファの情報を色付きで表示 {{{
def ShowBufInfo(event: string = '')
	if &ft ==# 'qf'
		return
	endif

	var isReadPost = event ==# 'BufReadPost'
	if isReadPost && !filereadable(expand('%'))
		# プラグインとかが一時的なbufnameを付与して開いた場合は無視する
		return
	endif

	var msg = []
	add(msg, ['Title', $'"{bufname()}"'])
	add(msg, ['Normal', ' '])
	if &modified
		add(msg, ['Delimiter', '[+]'])
		add(msg, ['Normal', ' '])
	endif
	if !isReadPost && !filereadable(expand('%'))
		add(msg, ['Tag', '[New]'])
		add(msg, ['Normal', ' '])
	endif
	if &readonly
		add(msg, ['WarningMsg', '[RO]'])
		add(msg, ['Normal', ' '])
	endif
	const w = wordcount()
	if isReadPost || w.bytes !=# 0
		add(msg, ['Constant', printf('%dL, %dB', w.bytes ==# 0 ? 0 : line('$'), w.bytes)])
		add(msg, ['Normal', ' '])
	endif
	add(msg, ['MoreMsg', &ff])
	add(msg, ['Normal', ' '])
	const enc = empty(&fenc) ? &encoding : &fenc
	add(msg, [enc ==# 'utf-8' ? 'MoreMsg' : 'WarningMsg', enc])
	add(msg, ['Normal', ' '])
	add(msg, ['MoreMsg', &ft])
	var msglen = 0
	const maxlen = &columns - 2
	for i in reverse(range(0, len(msg) - 1))
		var s = msg[i][1]
		var d = strdisplaywidth(s)
		msglen += d
		if maxlen < msglen
			const l = maxlen - msglen + d
			while !empty(s) && l < strdisplaywidth(s)
				s = s[1 :]
			endwhile
			msg[i][1] = s
			msg = msg[i : ]
			insert(msg, ['SpecialKey', '<'], 0)
			break
		endif
	endfor
	redraw
	echo ''
	for m in msg
		execute 'echohl' m[0]
		echon m[1]
	endfor
	echohl Normal
enddef

# Zenモードで位置が分からなくなるのでPOPUPで現在位置を表示
def PopupCursorPos()
	popup_create($' {line(".")}:{col(".")} ', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor+1',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef

nnoremap <script> <C-g> <ScriptCmd>ShowBufInfo()<CR><scriptCmd>PopupCursorPos()<CR>
au vimrc BufNewFile,BufReadPost,BufWritePost * ShowBufInfo('BufNewFile')
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 閉じる {{{
def QuitWin(expr: string)
	if winnr() ==# winnr(expr)
		return
	endif
	execute 'wincmd' expr
	if mode() ==# 't'
		quit!
	else
		confirm quit
	endif
enddef
Each h,j,k,l nnoremap q{0} <ScriptCmd>QuitWin('{0}')<CR>
nnoremap q <Nop>
nnoremap Q q
# 閉じる
nnoremap <expr> qq $"\<Cmd>confirm {winnr('$') ==# 1 && execute('ls')->split("\n")->len() !=# 1 ? 'bd' : 'q'}\<CR>"
# ウィンドウ
nnoremap qa <Cmd>confirm qa<CR>
nnoremap qOw <Cmd>confirm only<CR>
# タブ
nnoremap qt <Cmd>confirm tabclose +<CR>
nnoremap qT <Cmd>confirm tabclose -<CR>
nnoremap q# <Cmd>confirm tabclose #<CR>
nnoremap qOt <Cmd>confirm tabonly<CR>
# バッファ
nnoremap qb <Cmd>confirm bd<CR>
nnoremap qn <Cmd>bn<CR><Cmd>confirm bd<CR>
nnoremap qp <Cmd>bp<CR><Cmd>confirm bd<CR>
nnoremap <expr> qo $"\<Cmd>vim9cmd confirm bd {range(1, last_buffer_nr())->filter((i, b) => b !=# bufnr() && buflisted(b))->join()}\<CR>"
# デフォルト動作を保持
nnoremap q: q:
nnoremap q/ q/
nnoremap q? q?
# 開きなおす
nnoremap qQ <Cmd>e #<1<CR>
#}}} -------------------------------------------------------

# ------------------------------------------------------
# vimrc、plugin、colorscheme作成用 {{{
# カーソル行を実行するやつ
cnoremap <script> <expr> <SID>(exec_line) $'{getline('.')->substitute('^[ \t"#:]\+', '', '')}<CR>'
nnoremap <script> g: :<C-u><SID>(exec_line)
nnoremap <script> g9 :<C-u>vim9cmd <SID>(exec_line)
xnoremap g: "vy:<C-u><C-r>=@v<CR><CR>
xnoremap g9 "vy:<C-u>vim9cmd <C-r>=@v<CR><CR>
# カーソル位置のハイライトを確認するやつ
nnoremap <expr> <Space>hl $'<Cmd>hi {synID(line('.'), col('.'), 1)->synIDattr('name')->substitute('^$', 'Normal', '')}<CR>'
# 他の定義は.vim/after/ftplugin/vim.vim
#}}}

# ------------------------------------------------------
# その他細々したの {{{
if has('clipboard')
	au vimrc FocusGained * @" = @+
	au vimrc FocusLost   * @+ = @"
endif

# カーソルの形
if has('vim_starting')
	&t_SI = "\e[6 q"
	&t_EI = "\e[2 q"
	&t_SR = "\e[4 q"
endif

nnoremap <F11> <ScriptCmd>vimrc#myutil#ToggleNumber()<CR>
nnoremap <F12> <Cmd>set wrap!<CR>

nnoremap gs :<C-u>%s///g<Left><Left><Left>
nnoremap gS :<C-u>%s/<C-r>=escape(expand('<cword>'), '^$.*?/\[]')<CR>//g<Left><Left>
xnoremap gs :s///g<Left><Left><Left>
xnoremap gS "vy:<C-u>%s/<C-r>=substitute(escape(@v,'^$.*?/\[]'),"\n",'\\n','g')<CR>//g<Left><Left>

nnoremap <CR> j0
nnoremap Y y$
nnoremap <Space>p $p
nnoremap <Space>P ^P
nnoremap <expr> j (getline('.')->match('\S') + 1 ==# col('.')) ? '+' : 'j'
nnoremap <expr> k (getline('.')->match('\S') + 1 ==# col('.')) ? '-' : 'k'

# `T`多少潰しても大丈夫だろう…
nnoremap TE :<C-u>tabe<Space>
nnoremap TN <Cmd>tabnew<CR>
nnoremap TD <Cmd>tabe ./<CR>
nnoremap TT <Cmd>tabnext #<CR>

onoremap <expr> } $"\<Esc>m`0{v:count1}{v:operator}\}"
onoremap <expr> { $"\<Esc>m`V{v:count1}\{{v:operator}"

xnoremap <expr> h mode() ==# 'V' ? '<Esc>h' : 'h'
xnoremap <expr> l mode() ==# 'V' ? '<Esc>l' : 'l'
xnoremap J j
xnoremap K k
xnoremap p P
xnoremap P p

inoremap ｋｊ <Esc>`^
inoremap 「 「」<C-g>U<Left>
inoremap 「」 「」<C-g>U<Left>
inoremap （ ()<C-g>U<Left>
inoremap （） ()<C-g>U<Left>

# US配列→「"」押しにくい、JIS配列→「'」押しにくい
# デフォルトのMはあまり使わないかなぁ…
nnoremap ' "
nnoremap m '
nnoremap M m
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 様子見中 使わなそうなら削除する {{{
au vimrc User InputCR feedkeys("\<C-g>u", 'n')

nnoremap <Space>n <Cmd>nohlsearch<CR>
au vimrc CursorHold * feedkeys(' n') # nohはauで動かない(:help noh)

# CSVとかのヘッダを固定表示する。ファンクションキーじゃなくてコマンド定義すればいいかな…
nnoremap <silent> <F10> <ESC>1<C-w>s:1<CR><C-w>w
xnoremap <F10> <ESC>1<C-w>s<C-w>w

# ここまで読(y)んだ
nnoremap <F9> my
nnoremap <Space><F9> 'y

# syntax固有の追加強調 {{{
def ClearMySyntax()
	for id in get(w:, 'my_syntax', [])
		silent! matchdelete(id)
	endfor
	w:my_syntax = []
enddef
def AddMySyntax(group: string, pattern: string)
	w:my_syntax->add(matchadd(group, pattern))
enddef
au vimrc Syntax * ClearMySyntax()
# やりがちなミスにハイライトを付ける
au vimrc Syntax javascript {
	AddMySyntax('SpellRare', '\s[=!]=\s')
}
au vimrc Syntax vim {
	AddMySyntax('SpellRare', '\s[=!]=\s')
	AddMySyntax('SpellBad', '\s[=!]==\s')
	AddMySyntax('SpellBad', '\s\~[=!][=#]\?\s')
	AddMySyntax('SpellRare', '\<normal!\@!')
}
#}}}

# yankした文字をecho {{{
set report=9999
# 他のプラグインと競合するのでタイマーで遅延させる
def g:EchoYankText(t: number)
	vimrc#echoyanktext#EchoYankText()
enddef
au vimrc TextYankPost * timer_start(1, g:EchoYankText)
#
#}}}
# 選択中の文字数をポップアップ {{{
def PopupVisualLength()
	normal! "vygv
	var text = @v->substitute('\n', '', 'g')
	popup_create($'{strlen(text)}chars', {
		pos: 'botleft',
		line: 'cursor-1',
		col: 'cursor+1',
		moved: 'any',
		padding: [1, 1, 1, 1],
	})
enddef
xnoremap <C-g> <ScriptCmd>PopupVisualLength()<CR>
#}}}

# `:%g!/re/d` の結果を新規ウインドウに表示
# (Buffer Regular Expression Print)
command! -nargs=1 Brep vimrc#myutil#Brep(<q-args>, <q-mods>)

# <C-f>と<C-b>、CTRLおしっぱがつらいので…
Each f,b nmap <C-{0}> <C-{0}><SID>(hold-ctrl)
Each f,b nnoremap <script> <SID>(hold-ctrl){0} <C-{0}><SID>(hold-ctrl)
nmap <SID>(hold-ctrl) <Nop>

# 🐶🍚
onoremap A <Plug>(textobj-twochars-a)
onoremap I <Plug>(textobj-twochars-i)

#noremap <F1> <Cmd>smile<CR>
#}}} -------------------------------------------------------

# ------------------------------------------------------
# † あともう1回「これ使ってないな…」と思ったときに消す {{{

# どっちも<C-w>w。左手オンリーと右手オンリーのマッピング
nnoremap <Space>w <C-w>w
nnoremap <Space>o <C-w>w
nnoremap <Space>d "_d

# <Tab>でtsvとかcsvとかhtmlの次の項目に移動
nnoremap <Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'e')<CR>
nnoremap <S-Tab> <Cmd>call search('\(^\\|\t\\|, *\)\S\?', 'be')<CR>
au vimrc FileType html,xml,svg {
	nnoremap <buffer> <silent> <Tab> <Cmd>call search('>')<CR><Cmd>call search('\S')<CR>
	nnoremap <buffer> <silent> <S-Tab> <Cmd>call search('>', 'b')<CR><Cmd>call search('>', 'b')<CR><Cmd>call search('\S')<CR>
}

# タブは卒業！
nnoremap <Space><Tab>u <Cmd>call vimrc#recentlytabs#ReopenRecentlyTab()<CR>
nnoremap <Space><Tab>l <Cmd>call vimrc#recentlytabs#ShowMostRecentlyClosedTabs()<CR>

#}}} -------------------------------------------------------

# ------------------------------------------------------
# デフォルトマッピングデー {{{
if strftime('%d') ==# '91'
	au vimrc VimEnter * {
		notification#show("✨ Today, Let's enjoy the default key mapping ! ✨")
		mapclear
		imapclear
		xmapclear
		cmapclear
		omapclear
		tmapclear
		# CursorHoldでfeedkyesしているので…
		nnoremap <Space>n <Nop>
	}
endif
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 色 {{{
nnoremap <expr> ZB $"<Cmd>set background={&background ==# 'dark' ? 'light' : 'dark'}<CR>"
au vimrc ColorSchemePre * {
	g:rcsv_colorpairs = [
		['105', '#9999ee'], ['117', '#99ccee'], ['120', '#99ee99'],
		['228', '#eeee99'], ['212', '#ee99cc'], ['177', '#cc99ee']
	]
}

def GetAttr(id: number, name: string): string
	const v = synIDattr(id, name)->matchstr(has('gui') ? '.*[^0-9].*' : '^[0-9]\+$')
	return !v ? 'NONE' : v
enddef

def GetHl(name: string): any
	const id = hlID(name)->synIDtrans()
	return { fg: GetAttr(id, 'fg'), bg: GetAttr(id, 'bg') }
enddef

def MyHighlight()
	hi! link CmdHeight0Horiz MoreMsg
	const x = has('gui') ? 'gui' : 'cterm'
	const signBg = GetHl('LineNr').bg
	execute $'hi LspDiagSignErrorText   {x}bg={signBg} {x}fg={GetHl("ErrorMsg").fg}'
	execute $'hi LspDiagSignHintText    {x}bg={signBg} {x}fg={GetHl("Question").fg}'
	execute $'hi LspDiagSignInfoText    {x}bg={signBg} {x}fg={GetHl("Pmenu").fg}'
	execute $'hi LspDiagSignWarningText {x}bg={signBg} {x}fg={GetHl("WarningMsg").fg}'
enddef

au vimrc VimEnter,ColorScheme * MyHighlight()

# 好みでハイライト
# vimrc再読み込みでクリア&再設定されないけど面倒だからヨシ
def MyMatches()
	if exists('w:my_matches') && !empty(getmatches())
		return
	endif
	w:my_matches = 1
	matchadd('String', '「[^」]*」')
	matchadd('Label', '^\s*■.*$')
	matchadd('Delimiter', 'WARN\|注意\|注:\|[★※][^\s()（）]*')
	matchadd('Todo', 'TODO')
	matchadd('Error', 'ERROR')
	matchadd('Delimiter', '- \[ \]')
	matchadd('SpellRare', '[ａ-ｚＡ-Ｚ０-９（）｛｝]')
	# 全角空白と半角幅の円記号
	matchadd('SpellBad', '[　¥]')
	# 稀によくtypoする単語(気づいたら追加する)
	matchadd('SpellBad', 'stlye')
enddef
au vimrc VimEnter,WinEnter * MyMatches()

# 文末空白(&listが有効のときだけSpellBadで目立たせる)
def HiTail()
	if &list && !exists('w:hi_tail')
		w:hi_tail = matchadd('SpellBad', '\s\+$')
	elseif !&list && exists('w:hi_tail')
		# calendar.vim等で見づらくなるのでその対応
		matchdelete(w:hi_tail)
		unlet w:hi_tail
	endif
enddef
au vimrc OptionSet list silent! HiTail()
# matchaddはウィンドウ単位だが、`setlocal list`を考慮してBuf...イベントで実行する
au vimrc BufNew,BufReadPost * silent! HiTail()

silent! syntax enable
set t_Co=256
set background=light
silent! colorscheme girly
#}}} -------------------------------------------------------

# ------------------------------------------------------
# 終わりに {{{
if '~/.vimrc_local'->expand()->filereadable()
	source ~/.vimrc_local
endif

def OpenLastfile()
	var lastfile = get(v:oldfiles, 0, '')->expand()
	if lastfile->filereadable()
		execute 'edit' lastfile
	endif
enddef
au vimrc VimEnter * ++nested if !BufIsSmth() | OpenLastfile() | endif
#}}}

# ------------------------------------------------------
# メモ {{{
# <F1> fern <S-F1>でフォルダを開く(win32)
# <F2> MRU
# <F3>
# <F4>
# <F5> 日付関係
# <F6>
# <F7>
# <F8>
# <F9> ここまでよんだ
# <F10> ヘッダ行を表示(あんまり使わない)
# <F11> 行番号表示切替
# <F12> 折り返し表示切替
#}}} -------------------------------------------------------

