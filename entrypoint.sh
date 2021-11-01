#!/bin/sh

# Get standard cli USER_ID variable
USER_ID=${HOST_USER_ID:-1000}
GROUP_ID=${HOST_GROUP_ID:-1000}
# Change 'me' uid to host user's uid
if [ ! -z "$USER_ID" ] && [ "$(id -u me)" != "$USER_ID" ]; then
    # Create the user group if it does not exist
    groupadd --non-unique -g "$GROUP_ID" group
    # Set the user's uid and gid
    usermod --non-unique --uid "$USER_ID" --gid "$GROUP_ID" me
fi

# Setting permissions on docker.sock
chown me: /var/run/docker.sock
chown me: /ssh-agent

# Setup dotfiles
stow -d /home/me/dotfiles git -t /home/me

rm -R /home/me/.config/nvim
stow -d /home/me/dotfiles nvim -t /home/me

rm -R /home/me/.zshrc
stow -d /home/me/dotfiles zsh -t /home/me

# zsh shell
su-exec me $@
