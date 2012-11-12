#!/bin/bash

#CONF
DBS=$(which debootstrap)
DBS_FILE=/usr/share/debootstrap/scripts/lucid 
INSTALL_DIR=/var/lib/gitorious

#CHECK NEED PACKAGE
if [ "$DBS" == "" ] || [ ! -e $DBS_FILE ]
then
	echo "Please install debootstrap with Ubuntu Lucid support"
	exit 1
fi

if [ -d $INSTALL_DIR ]
then
	echo "Root dir already install, remote it to do it again"
	exit 1
fi
