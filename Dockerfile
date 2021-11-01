FROM phusion/baseimage:focal-1.1.0

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install latest su-exec
# https://gist.github.com/dmrub/b311d36492f230887ab0743b3af7309b
RUN  set -ex; \
     \
     curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
     \
     fetch_deps='gcc libc-dev'; \
     apt-get update; \
     apt-get install -y --no-install-recommends $fetch_deps; \
     rm -rf /var/lib/apt/lists/*; \
     gcc -Wall \
         /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
     chown root:root /usr/local/bin/su-exec; \
     chmod 0755 /usr/local/bin/su-exec; \
     rm /usr/local/bin/su-exec.c; \
     \
     apt-get purge -y --auto-remove $fetch_deps

# Install vim related packaged
RUN add-apt-repository universe -y && apt-get update && apt-get install -y python3-pip python2 && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
    python2 get-pip.py && \
    pip2 install pynvim && \
    pip3 install pynvim

RUN add-apt-repository ppa:neovim-ppa/unstable -y && apt-get update && \
    apt-get install -y neovim 
RUN update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
RUN update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
RUN update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60

RUN apt-get update && apt-get install -y cpanminus && cpanm Neovim::Ext --force

# Install nvim plugin deps
RUN apt-get update && apt-get install -y \
    sqlite3 libsqlite3-dev \
    fd-find ripgrep

# Install docker
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Install packages
RUN apt-get update && apt-get install -y \
    build-essential openssh-client zsh fzf \
    stow \
    tmux \
    git git-crypt tig \
    curl \
    httpie \
    jq

RUN useradd -ms /bin/zsh me
WORKDIR /home/me
ENV HOME /home/me

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

# Install neovim language server
RUN npm install -g intelephense
RUN mkdir -p $HOME/intelephense
COPY --chown=me ./config/intelephense/licence.txt $HOME/intelephense/licence.txt.txt

COPY --chown=me ./config/zsh/.zshrc .
RUN /bin/zsh /home/me/.zshrc

COPY --chown=me config/nvim/.config/nvim/init.vim $HOME/.config/nvim/init.vim
RUN vim +PlugInstall +qall

RUN chown -R me: /home/me

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["/usr/bin/zsh"]
