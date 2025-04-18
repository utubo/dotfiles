vim9script
packadd vim-ezpack
com! -nargs=* EzpackS execute $'Ezpack {<q-args>}'
com! -nargs=* EzpackO execute $'Ezpack <opt> {<q-args>}'
com! -nargs=* EzpackL execute $'Ezpack <lazy> {<q-args>}'
EzpackInit
EzpackS vim-jp/vital.vim
EzpackS obcat/vim-sclow
EzpackS utubo/vim-colorscheme-girly
EzpackS utubo/vim-colorscheme-softgreen
EzpackS utubo/vim-zenmode
EzpackL airblade/vim-gitgutter
EzpackO cohama/lexima.vim
EzpackL delphinus/vim-auto-cursorline
EzpackO easymotion/vim-easymotion
EzpackL girishji/vimcomplete
EzpackL hrsh7th/vim-vsnip
EzpackL hrsh7th/vim-vsnip-integ
EzpackL itchyny/calendar.vim
EzpackO kana/vim-textobj-user
EzpackL kana/vim-smartword
EzpackL LeafCage/vimhelpgenerator
EzpackL luochen1990/rainbow
EzpackO machakann/vim-sandwich
EzpackO mattn/vim-notification
EzpackL matze/vim-move
EzpackL michaeljsmith/vim-indent-object
Ezpack MTDL9/vim-log-highlighting <on> Filetype log
EzpackL obcat/vim-hitspop
EzpackL osyo-manga/vim-textobj-multiblock
EzpackL rhysd/vim-gfm-syntax
EzpackL PProvost/vim-ps1
EzpackL skanehira/gh.vim
EzpackL thinca/vim-portal
EzpackL thinca/vim-themis
EzpackL tpope/vim-fugitive
EzpackL tyru/capture.vim
EzpackL tyru/caw.vim
EzpackO yegappan/lsp
Ezpack yegappan/mru <cmd> MRUToggle,MRU
EzpackL yuki-yano/dedent-yank.vim
EzpackO lambdalisue/fern.vim
EzpackO lambdalisue/fern-git-status.vim
EzpackO lambdalisue/fern-renderer-nerdfont.vim
EzpackO lambdalisue/fern-hijack.vim
EzpackO lambdalisue/nerdfont.vim
EzpackO ctrlpvim/ctrlp.vim
EzpackO mattn/ctrlp-matchfuzzy
EzpackL sheerun/vim-polyglot
EzpackO utubo/cmdline.vim <branch> develop
EzpackO utubo/vim-ezpack
EzpackL utubo/vim-headtail
EzpackL utubo/vim-hlpairs
EzpackL utubo/vim-minviml
EzpackO utubo/vim-reformatdate
EzpackL utubo/vim-registers-lite
Ezpack utubo/vim-skipslash <on> ModeChanged *:c
EzpackL utubo/vim-yomigana
Ezpack utubo/vim-vim9skk <on> ModeChanged *:[ic]
EzpackL utubo/jumpcursor.vim
Ezpack utubo/vim-ddgv <cmd> DDGV
EzpackL utubo/vim-portal-aim
EzpackL utubo/vim-shrink
EzpackL utubo/vim-textobj-twochars
EzpackO utubo/vim-cmdheight0
EzpackO utubo/vim-tablist
EzpackO utubo/vim-tabpopupmenu
EzpackO utubo/vim-altkey-in-term
export def Install()
ezpack#Install()
enddef
export def CleanUp()
ezpack#CleanUp()
enddef
