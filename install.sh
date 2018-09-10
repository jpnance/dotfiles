#!/bin/bash

dotfiles=(vimrc vim spectrwm.conf spectrwm gitconfig Xresources)

for dotfile in ${dotfiles[*]}
do
	ln -s $PWD/$dotfile ~/.$dotfile
done
