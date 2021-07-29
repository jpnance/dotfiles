#!/bin/bash

dotfiles=(bash_profile bashrc vimrc vim gitconfig tmux.conf)

for dotfile in ${dotfiles[*]}
do
	ln -snf $PWD/$dotfile ~/.$dotfile
done
