#!/bin/bash

dotfiles=(vimrc vim spectrwm.conf spectrwm gitconfig Xresources oidentd.conf tmux.conf)

for dotfile in ${dotfiles[*]}
do
	ln -snf $PWD/$dotfile ~/.$dotfile
done
