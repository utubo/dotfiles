## Test vim in a docker container
Example
```sh
docker build . -t utubo-dotfiles
docker run -it utubo-dotfiles
```

If you want open the source of .vimrc
```vim
:e ~/dotfile/src/.vimrc.src.vim
```

or press `F1` key to open the fern.  

If it is bright
```vim
:colorscheme softgreen
```

