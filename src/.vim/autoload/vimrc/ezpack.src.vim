vim9script
packadd vim-ezpack

EzpackInit

# 初期表示で使うプラグイン
Ezpack vim-jp/vital.vim
Ezpack utubo/vim-colorscheme-girly # うちのvimが一番kawaii!
Ezpack utubo/vim-colorscheme-softgreen # 緑がかって目に優しめを目指しました
Ezpack utubo/vim-zenmode # cmdheight=0エミュレータ(statuslineも非表示)
Ezpack utubo/vim-anypanel

# 遅延ロード
EzpackLazyLoad
Ezpack Bakudankun/BackAndForward.vim
Ezpack LeafCage/yankround.vim
Ezpack LeafCage/vimhelpgenerator
Ezpack PProvost/vim-ps1 # Powershellのシンタックスハイライト
Ezpack girishji/vimcomplete
Ezpack hrsh7th/vim-vsnip
Ezpack hrsh7th/vim-vsnip-integ
Ezpack itchyny/calendar.vim
Ezpack kana/vim-smartword # wとかのモーションをいい感じにする
Ezpack luochen1990/rainbow
Ezpack matze/vim-move
Ezpack michaeljsmith/vim-indent-object
Ezpack obcat/vim-hitspop
Ezpack osyo-manga/vim-textobj-multiblock
Ezpack rhysd/vim-gfm-syntax # コードブロックにも対応したmarkdownのハイライト
Ezpack skanehira/gh.vim
Ezpack thinca/vim-portal
Ezpack thinca/vim-themis
Ezpack tommcdo/vim-exchange
Ezpack tpope/vim-fugitive # `:Git`コマンド
Ezpack tyru/capture.vim
Ezpack yuki-yano/dedent-yank.vim # yankするときにインデントを削除
Ezpack wellle/targets.vim # 引数とかのテキストオブジェクト

# あとは全部opt行き
EzpackInstallToOpt
Ezpack MTDL9/vim-log-highlighting <on> Filetype log
Ezpack airblade/vim-gitgutter # gitの差分を表示する
Ezpack cohama/lexima.vim <mode> [ic] <post> call vimrc#lexima#LazyLoad()
Ezpack kana/vim-textobj-user
Ezpack lambdalisue/nerdfont.vim
Ezpack machakann/vim-sandwich
Ezpack utubo/vim-easymotion <branch> develop
Ezpack yegappan/lsp

# 様子見中
EzpackLazyLoad
Ezpack sheerun/vim-polyglot       # 色んなファイルタイプに対応
EzpackInstallToOpt
Ezpack robenkleene/veep.vim <cmd> P # ビジュアルブロックに対してexcommand

# 復活させるかも
# Ezpack girishji/autosuggest.vim # うちのWindows環境で動きが怪しい
# Ezpack github/copilot.vim
# Ezpack yegappan/mru <cmd> MRUToggle,MRU
# Ezpack tani/vim-typo            # おま環でOmniSyntaxListが何故か重い
# Ezpack obcat/vim-sclow          # 調査中
# Ezpack Shougo/cmdline.vim
# Ezpack utubo/cmdline.vim <branch> develop
# Ezpack lambdalisue/fern.vim
# Ezpack lambdalisue/fern-git-status.vim
# Ezpack lambdalisue/fern-renderer-nerdfont.vim
# Ezpack lambdalisue/fern-hijack.vim
# Ezpack ctrlpvim/ctrlp.vim
# Ezpack mattn/ctrlp-matchfuzzy

# 🐶🍚
EzpackLazyLoad
Ezpack utubo/vim-headtail         # Textobjの先頭や末尾に移動
Ezpack utubo/vim-hlpairs          # 括弧をハイライト強化版
Ezpack utubo/vim-minviml          # Vim scriptをminify
Ezpack utubo/vim-registers-lite   # registers.nvimライクなプラグイン
Ezpack utubo/vim-update           # gvim.exeの最新版をgithubから落とす
Ezpack utubo/vim-yomigana         # 漢字やひらがなをカタカナに変換したり
# 以下はoptに入れておけばOK
EzpackInstallToOpt
Ezpack utubo/vim-ezpack           # 自作プラグインマネージャ
Ezpack utubo/vim-popselect        # ポップアップで色々開くやつ
Ezpack utubo/vim-reformatdate     # <C-a>で日付と曜日をインクリメントとか
Ezpack utubo/vim-previewcmd <mode> c # コマンド補完
Ezpack utubo/vim-skipslash  <mode> c # `:%s/foo/bar/`のとき<Tab>でfooからbarへ移動
Ezpack utubo/vim-vim9skkp <mode> [ict] <pre> vimrc#vim9skkp#LazyLoad() # Vim9 scriptで作ったskk

# 🐶💬🍚作ったけど使用頻度が低い
EzpackInstallToOpt
Ezpack utubo/vim-ddgv <cmd> DDGV  # duckduckGo検索
EzpackLazyLoad
Ezpack utubo/vim-portal-aim       # vim-portalを狙った場所に撃てるようにする
Ezpack utubo/vim-shrink           # ウィンドウ移動時にいい感じにサイズ縮小
Ezpack utubo/vim-textobj-twochars # 指定した2つの文字で挟まれるtextobj

# 🐶✋🍚作ったけど使わなくなった。optに入れておいて修正したいときに手でpackaddする
EzpackInstallToOpt
Ezpack utubo/vim-cmdheight0       # cmdheight=0エミュレータ(statuslineに対応)
Ezpack utubo/jumpcursor.vim       # jumpcursorのvim対応版
Ezpack utubo/vim-tablist          # タブ一覧を表示する
Ezpack utubo/vim-tabpopupmenu     # タブ操作関係のメニュー
Ezpack utubo/vim-altkey-in-term   # `<Esc>k`を`<A-k>`に(クライアントの設定でAltをそのまま送ればいいので不要)

export def Install()
  ezpack#Install()
enddef

export def CleanUp()
  ezpack#CleanUp()
enddef
