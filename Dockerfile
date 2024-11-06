FROM thinca/vim:v9.1.0842

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

RUN sudo npm install -g npm
RUN sudo npm install -g typescript-language-server
RUN sudo npm install -g vim-language-server
RUN sudo npm install -g vscode-html-languageserver-bin
RUN sudo npm install -g vscode-json-languageserver

WORKDIR $HOME

ADD https://api.github.com/repos/utubo/dotfiles/git/refs/heads/master version.json
RUN git clone https://github.com/utubo/dotfiles.git
RUN sh dotfiles/install.sh

