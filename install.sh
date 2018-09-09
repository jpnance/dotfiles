#!/bin/bash

dotfiles=(vimrc vim spectrwm.conf gitconfig)

for dotfile in ${dotfiles[*]}
do
	ln -s $PWD/$dotfile ~/.$dotfile
done
