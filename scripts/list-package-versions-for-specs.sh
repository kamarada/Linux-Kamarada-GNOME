#!/bin/bash

# Run this script inside the live media

# List installed packages
INSTALLED_PACKAGES=$(rpm -qa --qf '%{name}|%{version}\n' | sort)

read -r -d '' PACKAGES_OF_INTEREST << EOF
kernel-default
xorg-x11-server
libwayland-server0
gnome-shell
libreoffice
MozillaFirefox
chromium
vlc
evolution
brasero
cups
drawing
firewalld
gparted
hplip
java-11-openjdk
keepassxc
linphone
pdfsam-basic
pidgin
python3
samba
tor
transmission
vim
wine
calamares
flatpak
EOF

# For each installed package
for PACKAGE in $PACKAGES_OF_INTEREST
do
    grep "^$PACKAGE[|]" <<< $INSTALLED_PACKAGES
done
