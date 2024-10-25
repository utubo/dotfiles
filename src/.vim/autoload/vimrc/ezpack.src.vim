vim9script
packadd vim-ezpack

# start
command! -nargs=* EzpackS execute $'Ezpack {<q-args>}'
# opt
command! -nargs=* EzpackO execute $'Ezpack {<q-args>} <opt>'
# lazy
command! -nargs=* EzpackL execute $'Ezpack {<q-args>} <lazy>'

EzpackInit
EzpackL airblade/vim-gitgutter
EzpackO cohama/lexima.vim
EzpackS delphinus/vim-auto-cursorline
EzpackO easymotion/vim-easymotion
EzpackL girishji/vimcomplete
# Ezpack girishji/autosuggest.vim ちょっとWindowsで動きが怪しい
# Ezpack github/copilot.vim #重い
EzpackL hrsh7th/vim-vsnip
EzpackL hrsh7th/vim-vsnip-integ
EzpackS itchyny/calendar.vim
EzpackS kana/vim-textobj-user
EzpackS kana/vim-smartword
EzpackS KentoOgata/vim-vimscript-gd
EzpackS LeafCage/vimhelpgenerator
EzpackS luochen1990/rainbow
EzpackS machakann/vim-sandwich
EzpackS mattn/vim-notification
EzpackL matze/vim-move
EzpackS michaeljsmith/vim-indent-object
EzpackS MTDL9/vim-log-highlighting
EzpackL obcat/vim-hitspop
EzpackS obcat/vim-sclow
EzpackL osyo-manga/vim-textobj-multiblock
EzpackL skanehira/gh.vim
EzpackS thinca/vim-portal
EzpackS thinca/vim-themis
EzpackL tpope/vim-fugitive
EzpackS tyru/capture.vim
EzpackL tyru/caw.vim
EzpackO yegappan/lsp
EzpackL yegappan/mru
EzpackS yuki-yano/dedent-yank.vim
EzpackS vim-jp/vital.vim
# Fern
EzpackO lambdalisue/fern.vim
EzpackO lambdalisue/fern-git-status.vim
EzpackO lambdalisue/fern-renderer-nerdfont.vim
EzpackO lambdalisue/fern-hijack.vim
EzpackO lambdalisue/nerdfont.vim
# 👀様子見中
EzpackO ctrlpvim/ctrlp.vim
EzpackO mattn/ctrlp-matchfuzzy
EzpackL sheerun/vim-polyglot
EzpackS tani/vim-typo
# 🐶🍚
EzpackS utubo/vim-altkey-in-term
EzpackS utubo/vim-colorscheme-girly
EzpackS utubo/vim-colorscheme-softgreen
EzpackO utubo/vim-ezpack
EzpackL utubo/vim-hlpairs
EzpackS utubo/vim-minviml
EzpackS utubo/vim-registers-lite
EzpackS utubo/vim-reformatdate
EzpackS utubo/vim-skipslash
EzpackS utubo/vim-yomigana
EzpackS utubo/vim-vim9skk
EzpackS utubo/vim-zenmode
# 🐶🍚様子見中
EzpackL utubo/jumpcursor.vim
EzpackL utubo/vim-ddgv
EzpackL utubo/vim-portal-aim
EzpackL utubo/vim-shrink
EzpackL utubo/vim-tablist
EzpackL utubo/vim-tabpopupmenu
EzpackL utubo/vim-textobj-twochars
# 🐶✋🍚
# Ezpack utubo/vim-cmdheight0

export def Install()
  ezpack#Install()
enddef

export def CleanUp()
  ezpack#CleanUp()
enddef
