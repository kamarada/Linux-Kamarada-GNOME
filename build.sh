#!/bin/bash
set -e

USERNAME=$(whoami)
USERHOME=$HOME
THIS_SCRIPT=$(realpath "$0")

if [[ $UID -gt 0 ]] ; then
    sudo sh $THIS_SCRIPT $USERNAME $USERHOME # https://askubuntu.com/a/719582/560233
    exit
fi

USERNAME=$1
USERHOME=$2
BASEDIR=$(dirname $THIS_SCRIPT) # https://stackoverflow.com/a/55472432/1657502

rm -rf $USERHOME/tmp-kamarada
kiwi-ng --type iso system build --description $BASEDIR --target-dir $USERHOME/tmp-kamarada
kiwi-ng result bundle --target-dir $USERHOME/tmp-kamarada --id Build1.1 --bundle-dir $BASEDIR
chmod 777 ./Linux_Kamarada*
chown $USERNAME ./Linux_Kamarada*
rm -rf $USERHOME/tmp-kamarada/Linux_Kamarada*
