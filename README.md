## Test vim in a docker container
example
```sh
docker build . -t dotfiles
docker run run -it dotfiles
```

if you warn open source of .vimrc
```vim
:e ~/dotfile/src/.vimrc.src.vim
```

or press `F1` key to open fern.
