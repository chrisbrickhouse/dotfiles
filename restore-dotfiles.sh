#!/bin/bash

force=false
clean=false
while getopts cfi: flag
do
	case "${flag}" in
		f) force=true;;
		i) install=${OPTARG};;
		c) clean=true;;
		\?) exit 1;;
	esac
done

if $clean && ! $force; then
	echo "clean option (-c) requires force (-f)"
	exit 1
fi

DOTFILE_REPO_LOCATION=$HOME/.local/dotfiles
DOTFILE_INSTALL_LOCATION=$HOME
if [ -n "$install" ]; then
	DOTFILE_INSTALL_LOCATION=$install
fi

for f in $(find $DOTFILE_REPO_LOCATION -name '.*' -type f); do
	fname=${f#$DOTFILE_REPO_LOCATION/} # remove leading path from find output

	target=$DOTFILE_REPO_LOCATION/$fname
	link=$DOTFILE_INSTALL_LOCATION/$fname
	
	if $clean; then
		echo "Removing $fname from $DOTFILE_INSTALL_LOCATION"
		rm $link
		continue
	fi

	if [ -f "$link" ]; then
		message="Link to $fname already exists in $DOTFILE_INSTALL_LOCATION"
		if $force; then
			message=$message", forcing overwrite"
			echo $message
			rm $link
		else
			message=$message", skipping"
			echo $message
			continue
		fi
	else
		echo "Linking $fname to $target"
	fi

	ln $HOME/.local/dotfiles/$fname $HOME/$fname
done
