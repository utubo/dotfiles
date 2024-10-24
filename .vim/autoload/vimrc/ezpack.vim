vim9script
packadd vim-ezpack
EzpackInit
Ezpack airblade/vim-gitgutter <on> SafeStateAgain *
Ezpack cohama/lexima.vim <opt>
Ezpack delphinus/vim-auto-cursorline
Ezpack easymotion/vim-easymotion <opt>
Ezpack girishji/vimcomplete
Ezpack hrsh7th/vim-vsnip <on> SafeStateAgain *
Ezpack hrsh7th/vim-vsnip-integ <on> SafeStateAgain *
Ezpack itchyny/calendar.vim
Ezpack kana/vim-textobj-user
Ezpack kana/vim-smartword
Ezpack KentoOgata/vim-vimscript-gd
Ezpack LeafCage/vimhelpgenerator
Ezpack luochen1990/rainbow
Ezpack machakann/vim-sandwich
Ezpack mattn/vim-notification
Ezpack matze/vim-move
Ezpack michaeljsmith/vim-indent-object
Ezpack MTDL9/vim-log-highlighting
Ezpack obcat/vim-hitspop
Ezpack obcat/vim-sclow
Ezpack osyo-manga/vim-textobj-multiblock
Ezpack skanehira/gh.vim
Ezpack thinca/vim-portal
Ezpack thinca/vim-themis
Ezpack tpope/vim-fugitive <on> SafeStateAgain *
Ezpack tyru/capture.vim
Ezpack tyru/caw.vim <on> SafeStateAgain *
Ezpack yegappan/lsp <opt>
Ezpack yegappan/mru
Ezpack yuki-yano/dedent-yank.vim
Ezpack vim-jp/vital.vim
Ezpack lambdalisue/fern.vim <opt>
Ezpack lambdalisue/fern-git-status.vim <opt>
Ezpack lambdalisue/fern-renderer-nerdfont.vim <opt>
Ezpack lambdalisue/fern-hijack.vim <opt>
Ezpack lambdalisue/nerdfont.vim <opt>
Ezpack ctrlpvim/ctrlp.vim
Ezpack mattn/ctrlp-matchfuzzy
Ezpack sheerun/vim-polyglot <on> SafeStateAgain *
Ezpack tani/vim-typo
Ezpack utubo/vim-altkey-in-term
Ezpack utubo/vim-colorscheme-girly
Ezpack utubo/vim-colorscheme-softgreen
Ezpack utubo/vim-ezpack <opt>
Ezpack utubo/vim-hlpairs
Ezpack utubo/vim-minviml
Ezpack utubo/vim-registers-lite
Ezpack utubo/vim-reformatdate
Ezpack utubo/vim-skipslash
Ezpack utubo/vim-yomigana
Ezpack utubo/vim-vim9skk
Ezpack utubo/vim-zenmode
Ezpack utubo/jumpcursor.vim
Ezpack utubo/vim-ddgv
Ezpack utubo/vim-portal-aim
Ezpack utubo/vim-shrink
Ezpack utubo/vim-tablist
Ezpack utubo/vim-tabpopupmenu
Ezpack utubo/vim-textobj-twochars
export def Install()
ezpack#Install()
enddef
export def CleanUp()
ezpack#CleanUp()
enddef
