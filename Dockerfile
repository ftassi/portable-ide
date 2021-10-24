FROM phusion/baseimage:focal-1.1.0

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update && apt-get install -y \
    git zsh tmux openssh-client \
    fzf curl httpie jq

RUN add-apt-repository ppa:neovim-ppa/unstable -y && apt-get update && apt-get install -y neovim

COPY entrypoint.sh /bin/entrypoint.sh

RUN useradd -ms /bin/zsh me
WORKDIR /home/me

ENV HOME /home/me
USER me
