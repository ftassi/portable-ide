FROM phusion/baseimage:focal-1.1.0

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update && apt-get install -y \
    build-essential \
    git zsh tmux openssh-client \
    fzf curl httpie jq

RUN add-apt-repository universe -y && apt-get update && apt-get install -y python3-pip python2 && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
    python2 get-pip.py && \
    pip2 install pynvim && \
    pip3 install pynvim

RUN add-apt-repository ppa:neovim-ppa/unstable -y && apt-get update && \
    apt-get install -y neovim 

RUN apt-get update && apt-get install -y cpanminus && cpanm Neovim::Ext --force

COPY entrypoint.sh /bin/entrypoint.sh

RUN useradd -ms /bin/zsh me
WORKDIR /home/me

ENV HOME /home/me
USER me
