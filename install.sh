#!/bin/bash

dotfiles=(vimrc vim spectrwm.conf spectrwm gitconfig tmux.conf Xresources xinitrc)

for dotfile in ${dotfiles[*]}
do
	ln -snf $PWD/$dotfile ~/.$dotfile
done
