#!/bin/bash

#CONF
cd "$(dirname "$0")"
DBS=$(which debootstrap)
DBS_DISTRO=quantal
DBS_FILE=/usr/share/debootstrap/scripts/$DBS_DISTRO
INSTALL_DIR=/var/lib/gitorious
SUDO=$(which sudo)

function gitorious_checkport {
	H=$(hostname -i)
	if nc -z $H 22
	then
		echo "Please change the host SSH port, gitorious will need it for ssh"
		exit 1
	fi
	if nc -z $H 25
	then
		echo "Please change the host SMTP port, gitorious will need it for postfix"
		exit 1
	fi
	if nc -z $H 80 || nc -z $H 443
	then
		echo "Please change the host HTTP / HTTPS port, gitorious will need it for apache2"
		exit 1
	fi

	if nc -z 127.0.0.1 3306
	then
		echo "Please change the host MySQL port, gitorious will need it for mysql"
		exit 1
	fi

	if nc -z 127.0.0.1 61613
	then
		echo "Please change the host port 61613, gitorious will need it for stomp"
		exit 1
	fi

	if nc -z 127.0.0.1 11211
	then
		echo "Please change the host port 11211, gitorious will need it for memcached"
		exit 1
	fi

	if nc -z 127.0.0.1 9418
	then
		echo "Please change the host port 9418, gitorious will need it for git daemon"
		exit 1
	fi

	if nc -z 127.0.0.1 3312
	then
		echo "Please change the host port 3312, gitorious will need it for ultrasphinx"
		exit 1
	fi
}

function gitorious_setup {
	sudo sed -i "/gitorious/d" /etc/fstab
	sudo sed -i "/gitorious/d" /etc/hosts
	cat <<EOF | sudo tee -a /etc/fstab > /dev/null
/dev/pts $INSTALL_DIR/dev/pts none bind,noauto 0 4
proc $INSTALL_DIR/proc proc defaults 0 4
sysfs $INSTALL_DIR/sys sysfs defaults 0 4
EOF
	cat <<EOF | sudo tee -a /etc/hosts > /dev/null
127.0.1.1 gitorious
EOF
	sudo cp /etc/hosts $INSTALL_DIR/etc/hosts
	sudo mount -a
}

function gitorious_install_files {
	$SUDO install -o root -g root -m 0755 bin/gitorious /usr/local/bin/
	for f in tools/gitorious-tools-*
	do
		$SUDO install -o root -g root -m 0755 "$f" "$INSTALL_DIR/usr/bin/"
	done
	$SUDO install -o root -g root -m 0644 "upstart/gitorious.conf" "/etc/init/"
	$SUDO install -o root -g root -m 0755 "cron/gitorious-hourly" "/etc/cron.hourly/"
	$SUDO install -o root -g root -m 0755 "cron/gitorious-daily" "/etc/cron.daily/"
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
		echo "Root dir already install, remove it to do it again"
		echo "You can run and skip debootstrap :"
		echo "SKIP_DEBOOTSTRAP=1 $0"
		exit 1
	fi

	gitorious_checkport

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

Keep all value by default. 
  MySQL keep the default root password for futher configuration.
  Postfix, configure it as Satellite and put your real email server.

EOF
