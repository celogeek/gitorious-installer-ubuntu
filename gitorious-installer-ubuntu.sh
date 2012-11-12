#!/bin/bash

#CONF
DBS=$(which debootstrap)
DBS_FILE=/usr/share/debootstrap/scripts/lucid 
INSTALL_DIR=/var/lib/gitorious
SUDO=$(which sudo)

function gitorious_root_exec {
	sudo chroot $INSTALL_DIR $*
}

function gitorious_exec {
	sudo chroot --userspec git:git $INSTALL_DIR $*
}

function gitorious_setup_mount {
	for i in dev dev/pts sys proc
	do
		sudo mount --bind /$i $INSTALL_DIR/$i
	done
}

function gitorious_setup_umount {
	for i in proc sys dev/pts dev
	do
		sudo umount $INSTALL_DIR/$i
	done
}

#CHECK NEED PACKAGE
if [ "$DBS" == "" ] || [ ! -e $DBS_FILE ]
then
	echo "Please install debootstrap with Ubuntu Lucid support"
	exit 1
fi

if [ "$SKIP_DEBOOTSTRAP" == "" ]
then

	if [ -d $INSTALL_DIR ]
	then
		echo "Root dir already install, remote it to do it again"
		exit 1
	fi

	if [ ! -x $SUDO ]
	then
		echo "Please install sudo and allow this user to use it"
		exit 1
	fi

	sudo debootstrap lucid /var/lib/gitorious http://mirror.ovh.net/ubuntu/

fi

gitorious_setup_mount
gitorious_setup_umount
