#!/bin/bash
BASEDIR=$(dirname $(realpath "$0")) # https://stackoverflow.com/a/55472432/1657502
sudo rm -rf /tmp/myimage
sudo kiwi-ng --type iso system build --description $BASEDIR --target-dir /tmp/myimage
