#!/bin/bash
set -e

USERNAME=$(whoami)
THIS_SCRIPT=$(realpath "$0")

if [[ $UID -gt 0 ]] ; then
    sudo sh $THIS_SCRIPT $USERNAME # https://askubuntu.com/a/719582/560233
    exit
fi

USERNAME=$1
BASEDIR=$(dirname $THIS_SCRIPT) # https://stackoverflow.com/a/55472432/1657502

rm -rf /tmp/myimage
kiwi-ng --type iso --profile=pt_BR system build --description $BASEDIR --target-dir /tmp/myimage
kiwi-ng result bundle --target-dir /tmp/myimage --id pt_BR-Build1.1 --bundle-dir $BASEDIR
chmod 777 ./Linux_Kamarada*
chown $USERNAME ./Linux_Kamarada*
rm -rf /tmp/myimage/Linux_Kamarada*
