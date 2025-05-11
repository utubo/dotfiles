vim9script
packadd vim-ezpack

# start(default)
command! -nargs=* EzpackS execute $'Ezpack {<q-args>}'
# opt
command! -nargs=* EzpackO execute $'Ezpack <opt> {<q-args>}'
# lazy
command! -nargs=* EzpackL execute $'Ezpack <lazy> {<q-args>}'

EzpackInit

# 初期表示で使うプラグイン
EzpackS vim-jp/vital.vim
EzpackS utubo/vim-colorscheme-girly # うちのvimが一番kawaii!
EzpackS utubo/vim-colorscheme-softgreen # 緑がかって目に優しめを目指しました
EzpackS utubo/vim-zenmode # cmdheight=0エミュレータ(statuslineも非表示)

# あとは全部opt行き
EzpackL airblade/vim-gitgutter # gitの差分を表示する
EzpackO cohama/lexima.vim
# EzpackO easymotion/vim-easymotion
EzpackO utubo/vim-easymotion <branch> develop
EzpackL girishji/vimcomplete
EzpackL hrsh7th/vim-vsnip
EzpackL hrsh7th/vim-vsnip-integ
EzpackL itchyny/calendar.vim
EzpackO kana/vim-textobj-user
EzpackL kana/vim-smartword # wとかのモーションをいい感じにする
EzpackO lambdalisue/nerdfont.vim
EzpackL LeafCage/vimhelpgenerator
EzpackL luochen1990/rainbow
EzpackO machakann/vim-sandwich
EzpackL matze/vim-move
EzpackL michaeljsmith/vim-indent-object
Ezpack  MTDL9/vim-log-highlighting <on> Filetype log
EzpackL obcat/vim-hitspop
EzpackL osyo-manga/vim-textobj-multiblock
EzpackL rhysd/vim-gfm-syntax # コードブロックにも対応したmarkdownのハイライト
EzpackL PProvost/vim-ps1 # Powershellのシンタックスハイライト
EzpackL skanehira/gh.vim
EzpackL thinca/vim-portal
EzpackL thinca/vim-themis
EzpackL tpope/vim-fugitive # `:Git`コマンド
EzpackL tyru/capture.vim
EzpackL tyru/caw.vim
EzpackO yegappan/lsp
EzpackL yuki-yano/dedent-yank.vim # yankするときにインデントを削除

# 様子見中
EzpackL sheerun/vim-polyglot       # 色んなファイルタイプに対応

# 復活させるかも
# EzpackL girishji/autosuggest.vim # うちのWindows環境で動きが怪しい
# EzpackL github/copilot.vim
# Ezpack  yegappan/mru <cmd> MRUToggle,MRU
# EzpackL tani/vim-typo            # おま環でOmniSyntaxListが何故か重い
# EzpackS obcat/vim-sclow          # 調査中
# EzpackO Shougo/cmdline.vim
# EzpackO utubo/cmdline.vim <branch> develop
# EzpackO lambdalisue/fern.vim
# EzpackO lambdalisue/fern-git-status.vim
# EzpackO lambdalisue/fern-renderer-nerdfont.vim
# EzpackO lambdalisue/fern-hijack.vim
# EzpackO ctrlpvim/ctrlp.vim
# EzpackO mattn/ctrlp-matchfuzzy

# 🐶🍚
EzpackO utubo/vim-ezpack           # 自作プラグインマネージャ
EzpackL utubo/vim-headtail         # Textobjの先頭や末尾に移動
EzpackL utubo/vim-hlpairs          # 括弧をハイライト強化版
EzpackL utubo/vim-minviml          # vimscriptをminify
EzpackO utubo/vim-popselect        # ポップアップで色々開くやつ
EzpackO utubo/vim-reformatdate     # <C-a>で日付と曜日をインクリメントとか
EzpackL utubo/vim-registers-lite   # registers.nvimライクなプラグイン
Ezpack  utubo/vim-skipslash <on> ModeChanged *:c # `:%s/foo/bar/`のとき<Tab>でfooからbarへ移動
EzpackL utubo/vim-yomigana         # 漢字やひらがなをカタカナに変換したり
Ezpack  utubo/vim-vim9skk <on> ModeChanged *:[ic] # vim9scriptで作ったskk

# 🐶💬🍚作ったけど使用頻度が低い
Ezpack  utubo/vim-ddgv <cmd> DDGV  # duckduckGo検索
EzpackL utubo/vim-portal-aim       # vim-portalを狙った場所に撃てるようにする
EzpackL utubo/vim-shrink           # ウィンドウ移動時にいい感じにサイズ縮小
EzpackL utubo/vim-textobj-twochars # 指定した2つの文字で挟まれるtextobj

# 🐶✋🍚作ったけど使わなくなった。optに入れておいて修正したいときに手でpackaddする
EzpackO utubo/vim-cmdheight0       # cmdheight=0エミュレータ(statuslineに対応)
EzpackO utubo/jumpcursor.vim       # jumpcursorのvim対応版
EzpackO utubo/vim-tablist          # タブ一覧を表示する
EzpackO utubo/vim-tabpopupmenu     # タブ操作関係のメニュー
EzpackO utubo/vim-altkey-in-term   # `<Esc>k`を`<A-k>`に(クライアントの設定でAltをそのまま送ればいいので不要)

export def Install()
  ezpack#Install()
enddef

export def CleanUp()
  ezpack#CleanUp()
enddef
