## Test vim in a docker container

(This hasn't been maintained in a long time, so it might not work.)

Example
```sh
docker build . -t utubo-dotfiles
docker run --rm --name utubo-dotfiles -it utubo-dotfiles
```

If you want open the source of .vimrc
```vim
:e ~/dotfile/src/.vimrc.src.vim
```

or press `F1` key to open current dir.  

If it is bright
```vim
:colorscheme softgreen
```

I use my plugin manager.
[src/.vim/autoload/vimrc/ezpack.src.vim](src/.vim/autoload/vimrc/ezpack.src.vim)

