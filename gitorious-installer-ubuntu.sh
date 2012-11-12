#!/bin/bash

#CONF
DBS=$(which debootstrap)
DBS_DISTRO=quantal
DBS_FILE=/usr/share/debootstrap/scripts/$DBS_DISTRO
INSTALL_DIR=/var/lib/gitorious
SUDO=$(which sudo)

function gitorious_root_exec {
	LANG=C sudo chroot $INSTALL_DIR $*
}

function gitorious_exec {
	LANG=C sudo chroot --userspec git:git $INSTALL_DIR $*
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

function gitorious_setup_files {
	set -e -x
	cat <<EOF | sudo tee $INSTALL_DIR/usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
	sudo chmod +x $INSTALL_DIR/usr/sbin/policy-rc.d
	cat <<EOF | sudo tee $INSTALL_DIR/usr/sbin/invoke-rc.d
#!/bin/sh
exit 0
EOF
	sudo chmod +x $INSTALL_DIR/usr/sbin/invoke-rc.d
	cat <<EOF | sudo tee $INSTALL_DIR/etc/apt/sources.list
deb http://ftp.free.fr/mirrors/ftp.ubuntu.com/ubuntu/ quantal main restricted
deb http://security.ubuntu.com/ubuntu quantal-security main restricted
deb http://ftp.free.fr/mirrors/ftp.ubuntu.com/ubuntu/ quantal-updates main restricted

deb http://ftp.free.fr/mirrors/ftp.ubuntu.com/ubuntu/ quantal universe multiverse
deb http://security.ubuntu.com/ubuntu quantal-security universe multiverse
deb http://ftp.free.fr/mirrors/ftp.ubuntu.com/ubuntu/ quantal-updates universe multiverse
EOF
	set +e +x
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

gitorious_setup_mount
gitorious_setup_files
gitorious_root_exec apt-get update
gitorious_root_exec apt-get install -y git-core apg build-essential libpcre3 libpcre3-dev postfix make zlib1g zlib1g-dev ssh libc6-dev libssl-dev libmysql++-dev libmysqlclient-dev libsqlite3-dev libreadline-dev libonig-dev libyaml-dev geoip-bin libgeoip-dev libgeoip1 imagemagick mysql-client mysql-server libmysqlclient-dev sphinxsearch memcached apache2
gitorious_setup_umount
