FROM phusion/baseimage:focal-1.1.0

# Install base packages
RUN yes | unminimize
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get -y --quiet --no-install-recommends install \
       man manpages-posix \
       locales \
       build-essential openssh-client curl software-properties-common \
       gcc \
       ca-certificates \
       gnupg \
       lsb-release \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get -y --quiet --no-install-recommends install \
       docker-ce docker-ce-cli containerd.io \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose 

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
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository universe -y && apt-get update && \
       apt-get -y --quiet --no-install-recommends install \
        python3-pip python2 && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
    python2 get-pip.py && \
    pip2 install pynvim && \
    pip3 install pynvim \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN add-apt-repository ppa:neovim-ppa/unstable -y && apt-get update && \
    apt-get install -y neovim 
RUN update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
RUN update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
RUN update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60

# RUN apt-get update \
#     && DEBIAN_FRONTEND=noninteractive \
#        apt-get -y --quiet --no-install-recommends install \
#        cpanminus && cpanm Neovim::Ext --force \
#     && apt-get -y autoremove \
#     && apt-get clean autoclean \
#     && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Install nvim plugin deps
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get -y --quiet --no-install-recommends install \
       sqlite3 libsqlite3-dev fd-find ripgrep \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Install packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get -y --quiet --no-install-recommends install \
       zsh fzf \
       stow \
       tmux \
       git git-crypt tig \
       curl \
       httpie \
       jq \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

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
