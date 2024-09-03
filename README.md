## Test vim in a docker container
Example
```sh
docker build . -t dotfiles
docker run run -it dotfiles
```

If you warn open source of .vimrc
```vim
:e ~/dotfile/src/.vimrc.src.vim
```

or press `F1` key to open fern.  

If it is bright
```vim
:colorscheme softgreen
```

