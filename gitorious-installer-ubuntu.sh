#!/bin/bash

#CHECK NEED PACKAGE
DBS=$(which debootstrap)
if [ "$DBS" == "" ] || [ ! -e /usr/share/debootstrap/scripts/lucid ]
then
	echo "Please install debootstrap with Ubuntu Lucid support"
	exit 1
fi
