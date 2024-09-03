## Test vim in a docker container
Example
```sh
docker build . -t utubo-dotfiles
docker run run -it utubo-dotfiles
```

If you want open source of .vimrc
```vim
:e ~/dotfile/src/.vimrc.src.vim
```

or press `F1` key to open fern.  

If it is bright
```vim
:colorscheme softgreen
```

