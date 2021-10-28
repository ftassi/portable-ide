[ -f ~/.antigen/antigen.zsh ] && source ~/.antigen/antigen.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
antigen use oh-my-zsh

antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

antigen theme agnoster
antigen apply

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#757575'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
