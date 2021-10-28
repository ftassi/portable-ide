source .antigen.zsh
source .fzf.zsh
antigen use oh-my-zsh

antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

antigen theme agnoster
antigen apply

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#757575'
