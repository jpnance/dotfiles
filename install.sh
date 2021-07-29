#!/bin/bash

dotfiles=(vimrc vim gitconfig tmux.conf)

for dotfile in ${dotfiles[*]}
do
	ln -snf $PWD/$dotfile ~/.$dotfile
done
