#!/bin/bash
BASEDIR=$(dirname $(realpath "$0")) # https://stackoverflow.com/a/55472432/1657502
USERNAME=$(whoami)
sudo rm -rf /tmp/myimage
sudo kiwi-ng --type iso system build --description $BASEDIR --target-dir /tmp/myimage
sudo chmod 777 /tmp/myimage/Linux-Kamarada*
sudo chown $USERNAME /tmp/myimage/Linux-Kamarada*
sudo mv /tmp/myimage/Linux-Kamarada* $BASEDIR
