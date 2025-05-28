vim9script
packadd vim-ezpack
EzpackInit
Ezpack vim-jp/vital.vim
Ezpack utubo/vim-colorscheme-girly
Ezpack utubo/vim-colorscheme-softgreen
Ezpack utubo/vim-zenmode
Ezpack utubo/vim-anypanel
EzpackLazyLoad
Ezpack LeafCage/vimhelpgenerator
Ezpack PProvost/vim-ps1
Ezpack girishji/vimcomplete
Ezpack hrsh7th/vim-vsnip
Ezpack hrsh7th/vim-vsnip-integ
Ezpack itchyny/calendar.vim
Ezpack kana/vim-smartword
Ezpack luochen1990/rainbow
Ezpack matze/vim-move
Ezpack michaeljsmith/vim-indent-object
Ezpack obcat/vim-hitspop
Ezpack osyo-manga/vim-textobj-multiblock
Ezpack rhysd/vim-gfm-syntax
Ezpack skanehira/gh.vim
Ezpack thinca/vim-portal
Ezpack thinca/vim-themis
Ezpack tpope/vim-fugitive
Ezpack tyru/capture.vim
Ezpack tyru/caw.vim
Ezpack yuki-yano/dedent-yank.vim
EzpackInstallToOpt
Ezpack MTDL9/vim-log-highlighting <on> Filetype log
Ezpack airblade/vim-gitgutter
Ezpack cohama/lexima.vim
Ezpack kana/vim-textobj-user
Ezpack lambdalisue/nerdfont.vim
Ezpack machakann/vim-sandwich
Ezpack utubo/vim-easymotion <branch> develop
Ezpack yegappan/lsp
EzpackLazyLoad
Ezpack sheerun/vim-polyglot
EzpackInstallToOpt
Ezpack utubo/vim-ezpack
Ezpack utubo/vim-popselect
Ezpack utubo/vim-reformatdate
Ezpack utubo/vim-skipslash <on> ModeChanged *:c
Ezpack utubo/vim-vim9skk <on> ModeChanged *:[ic]
EzpackLazyLoad
Ezpack utubo/vim-headtail
Ezpack utubo/vim-hlpairs
Ezpack utubo/vim-minviml
Ezpack utubo/vim-registers-lite
Ezpack utubo/vim-yomigana
EzpackInstallToOpt
Ezpack utubo/vim-ddgv <cmd> DDGV
EzpackLazyLoad
Ezpack utubo/vim-portal-aim
Ezpack utubo/vim-shrink
Ezpack utubo/vim-textobj-twochars
EzpackInstallToOpt
Ezpack utubo/vim-cmdheight0
Ezpack utubo/jumpcursor.vim
Ezpack utubo/vim-tablist
Ezpack utubo/vim-tabpopupmenu
Ezpack utubo/vim-altkey-in-term
export def Install()
ezpack#Install()
enddef
export def CleanUp()
ezpack#CleanUp()
enddef
