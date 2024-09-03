FROM thinca/vim:latest

RUN apk update && \
    apk --no-cache add \
    git \
    zsh \
    curl \
    sudo \
    nodejs \
    npm

ENV SHELL /bin/zsh
RUN zsh

ENV USER dotfile
ENV HOME /home/$USER
RUN addgroup -S $USER && \
    adduser -S -u 1000 -G $USER $USER && \
    chown -R $USER:$USER $HOME
RUN echo "dotfile ALL=NOPASSWD: ALL" >> /etc/sudoers
USER $USER

WORKDIR $HOME

ADD https://api.github.com/repos/utubo/dotfiles/git/refs/heads/master version.json
RUN git clone https://github.com/utubo/dotfiles.git
RUN sh dotfiles/install.sh

