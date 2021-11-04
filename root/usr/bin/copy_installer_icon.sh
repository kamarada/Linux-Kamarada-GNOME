#!/bin/bash

DESKTOP_DIR=$(xdg-user-dir DESKTOP)

cp /usr/share/applications/calamares.desktop "$DESKTOP_DIR/"
# Set desktop file trusted
gio set -t string "$DESKTOP_DIR/calamares.desktop" "metadata::trusted" true

if [ -f $HOME/.config/autostart/copy_installer_icon.desktop ]; then
    rm $HOME/.config/autostart/copy_installer_icon.desktop
fi

