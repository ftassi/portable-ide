FROM phusion/baseimage:focal-1.1.0

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN add-apt-repository universe -y && apt-get update && apt-get install -y python3-pip python2 && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
    python2 get-pip.py && \
    pip2 install pynvim && \
    pip3 install pynvim

RUN add-apt-repository ppa:neovim-ppa/unstable -y && apt-get update && \
    apt-get install -y neovim 

RUN apt-get update && apt-get install -y cpanminus && cpanm Neovim::Ext --force

# Add some basic shell stuff
RUN apt-get update && apt-get install -y build-essential openssh-client zsh fzf 

# Add some dev goodies
RUN apt-get update && apt-get install -y \
    tmux \
    git git-crypt \
    curl \
    httpie \
    jq

COPY entrypoint.sh /bin/entrypoint.sh

RUN useradd -ms /bin/zsh me
WORKDIR /home/me

ENV HOME /home/me
USER me

RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
RUN ~/.fzf/install

RUN mkdir -p $HOME/.antigen
RUN curl -L git.io/antigen > $HOME/.antigen/antigen.zsh

ENV NVM_DIR /home/me/.nvm
ENV NODE_VERSION 14.18.1
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install nvm with node and npm
RUN curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.39.0/install.sh | bash \
  && . $NVM_DIR/nvm.sh \ 
  && nvm install $NODE_VERSION 

# /Install neovime language server
RUN npm install -g intelephense

COPY ./config/zsh/.zshrc .
RUN /bin/zsh /home/me/.zshrc


