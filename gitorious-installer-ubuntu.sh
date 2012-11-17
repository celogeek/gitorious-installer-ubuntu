#!/bin/bash

#CONF
cd "$(dirname "$0")"
DBS=$(which debootstrap)
DBS_DISTRO=quantal
DBS_FILE=/usr/share/debootstrap/scripts/$DBS_DISTRO
INSTALL_DIR=/var/lib/gitorious
SUDO=$(which sudo)

function gitorious_setup {
	sudo sed -i "/gitorious/d" /etc/fstab
	sudo sed -i "/gitorious/d" /etc/hosts
	cat <<EOF | sudo tee -a /etc/fstab > /dev/null
/dev/pts $INSTALL_DIR/dev/pts none bind 0 4
proc $INSTALL_DIR/proc proc defaults 0 4
sysfs $INSTALL_DIR/sys sysfs defaults 0 4
EOF
	cat <<EOF | sudo tee -a /etc/hosts > /dev/null
127.0.1.1 gitorious
EOF
	sudo mount -a
}

function gitorious_install_files {
	$SUDO install -o root -g root -m 0755 bin/gitorious /usr/local/bin/
	for f in tools/gitorious-tools-*
	do
		$SUDO install -o root -g root -m 0755 "$f" "$INSTALL_DIR/usr/bin/"
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

	sudo debootstrap $DBS_DISTRO /var/lib/gitorious http://mirror.ovh.net/ubuntu/

fi

gitorious_setup
gitorious_install_files

cat <<EOF
Tools for gitorious has been installed, and based directory is ready. You can now run the gitorious command setup :

gitorious setup

EOF
