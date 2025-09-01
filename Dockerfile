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

ENV USER alice
ENV HOME /home/$USER
RUN addgroup -S $USER && \
    adduser -S -u 1000 -G $USER $USER && \
    chown -R $USER:$USER $HOME
RUN echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers
USER $USER

RUN sudo npm install -g --omit=optional npm
RUN sudo npm install -g --omit=optional typescript-language-server
RUN sudo npm install -g --omit=optional vim-language-server
RUN sudo npm install -g --omit=optional vscode-html-languageserver-bin
RUN sudo npm install -g --omit=optional vscode-json-languageserver

WORKDIR $HOME

ADD https://api.github.com/repos/utubo/dotfiles/git/refs/heads/master version.json
RUN git clone https://github.com/utubo/dotfiles.git
RUN sh dotfiles/install.sh

