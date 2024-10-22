vim9script

command! -nargs=* Ezpack ezpack#Ezpack(<f-args>)

export def ListPlugins()
  ezpack#Init()

  Ezpack airblade/vim-gitgutter
  Ezpack cohama/lexima.vim # 括弧補完
  Ezpack delphinus/vim-auto-cursorline
  Ezpack easymotion/vim-easymotion
  Ezpack girishji/vimcomplete
  # Ezpack girishji/autosuggest.vim ちょっとWindowsで動きが怪しい
  # Ezpack github/copilot.vim #重い
  Ezpack hrsh7th/vim-vsnip
  Ezpack hrsh7th/vim-vsnip-integ
  Ezpack itchyny/calendar.vim
  Ezpack kana/vim-textobj-user
  Ezpack kana/vim-smartword
  Ezpack KentoOgata/vim-vimscript-gd
  Ezpack LeafCage/vimhelpgenerator
  Ezpack luochen1990/rainbow # 虹色括弧
  Ezpack machakann/vim-sandwich
  Ezpack mattn/vim-notification
  Ezpack matze/vim-move # 行移動
  Ezpack michaeljsmith/vim-indent-object
  Ezpack MTDL9/vim-log-highlighting
  Ezpack obcat/vim-hitspop
  Ezpack obcat/vim-sclow # スクロールバー
  Ezpack osyo-manga/vim-textobj-multiblock
  Ezpack skanehira/gh.vim
  Ezpack thinca/vim-portal
  Ezpack thinca/vim-themis
  Ezpack tpope/vim-fugitive # Gdiffとか
  Ezpack tyru/capture.vim # 実行結果をバッファにキャプチャ
  Ezpack tyru/caw.vim # コメント化
  Ezpack yegappan/lsp
  Ezpack yegappan/mru
  Ezpack yuki-yano/dedent-yank.vim # yankするときにインデントを除去
  Ezpack vim-jp/vital.vim
  # Fern
  Ezpack lambdalisue/fern.vim
  Ezpack lambdalisue/fern-git-status.vim
  Ezpack lambdalisue/fern-renderer-nerdfont.vim
  Ezpack lambdalisue/fern-hijack.vim
  Ezpack lambdalisue/nerdfont.vim
  # 👀様子見中
  Ezpack ctrlpvim/ctrlp.vim
  Ezpack mattn/ctrlp-matchfuzzy
  Ezpack sheerun/vim-polyglot # いろんなシンタックスハイライト
  Ezpack tani/vim-typo
  # 🐶🍚
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
  # 🐶🍚様子見中
  Ezpack utubo/jumpcursor.vim
  Ezpack utubo/vim-ddgv
  Ezpack utubo/vim-portal-aim
  Ezpack utubo/vim-shrink
  Ezpack utubo/vim-tablist
  Ezpack utubo/vim-tabpopupmenu
  Ezpack utubo/vim-textobj-twochars
  # 🐶✋🍚
  # Ezpack utubo/vim-cmdheight0
enddef

