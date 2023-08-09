#!/bin/bash
set -ex

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Call configuration code/functions
#--------------------------------------

# Setup baseproduct link
suseSetupProduct

echo "kamarada-pc" > /etc/hostname

# Add missing gpg keys to rpm
suseImportBuildKey

# Activate services
suseRemoveService wicked
suseRemoveService SuSEfirewall2
suseInsertService NetworkManager
suseInsertService firewalld
suseInsertService chronyd
suseInsertService pcscd

# Setup default target, multi-user GUI
baseSetRunlevel 5

# Sysconfig update
baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER gdm
baseUpdateSysConfig /etc/sysconfig/windowmanager DEFAULT_WM gnome

# /etc/sudoers hack to fix #297695
# (Installation Live DVD: no need to ask for password of root)
# https://bugzilla.novell.com/show_bug.cgi?id=297695
sed -i -e "s/ALL ALL=(ALL) ALL/ALL ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
chmod 0440 /etc/sudoers

# Create LiveDVD user linux
/usr/sbin/useradd -m -u 999 linux -c "Live User" -p ""

# delete passwords
passwd -d root
passwd -d linux
# empty password is ok
pam-config -a --nullok

# bug 544314, we only want to disable the bit in common-auth-pc
# https://bugzilla.novell.com/show_bug.cgi?id=544314
sed -i -e 's,^\(.*pam_gnome_keyring.so.*\),#\1,'  /etc/pam.d/common-auth-pc

# Automatically log in user linux
baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER_AUTOLOGIN linux

# Kamarada Firstboot
kamarada-setup en_US
kamarada-firstboot --prepare

# GNOME Logs does not display anything, unless the user belongs to the systemd-journal group
# https://tracker.pureos.net/w/troubleshooting/gnome_logs_can_t_see_any_logs/
usermod -aG systemd-journal linux

# Kamarada repository
# See: https://github.com/kamarada/Linux-Kamarada-GNOME/wiki/Mirrors
#KAMARADA_MIRROR="https://osdn.mirror.constant.com/storage/g/k/ka/kamarada/\$releasever/openSUSE_Leap_\$releasever/"
#KAMARADA_MIRROR="http://c3sl.dl.osdn.jp/storage/g/k/ka/kamarada/\$releasever/openSUSE_Leap_\$releasever/"
KAMARADA_MIRROR="http://download.opensuse.org/repositories/home:/kamarada:/\$releasever:/dev/openSUSE_Leap_\$releasever/"
zypper addrepo -f -K -n "Linux Kamarada" -p 95 "$KAMARADA_MIRROR" kamarada

# openSUSE Bug 984330 overlayfs requires AppArmor attach_disconnected flag
# https://bugzilla.opensuse.org/show_bug.cgi?id=984330

# Linux Kamarada issue #1 unable to ping
# https://github.com/kamarada/kiwi-config-Kamarada/issues/1
sed -i -e 's/\/{usr\/,}bin\/ping {/\/{usr\/,}bin\/ping (attach_disconnected) {/g' /etc/apparmor.d/bin.ping

# Locale clean up
mkdir /usr/share/locale_keep
mv /usr/share/locale/{en*,pt*} /usr/share/locale_keep/
rm -rf /usr/share/locale
mv /usr/share/locale_keep /usr/share/locale

# kamarada/Linux-Kamarada-GNOME#55 - Add the Brazilian root CA (ICP-Brasil) certificate to Chromium
su - linux -c "instalar-icpbrasil"

# Disable journal write to disk in live mode, bug 950999
echo "Storage=volatile" >> /etc/systemd/journald.conf

# Remove generated files (boo#1098535)
rm -rf /var/cache/zypp/* /var/lib/zypp/AnonymousUniqueId /var/lib/systemd/random-seed

# Save 165MB by removing this, not very useful for lives
rm -rf /lib/firmware/{liquidio,netronome}

#======================================
# Exit safely
#--------------------------------------
exit 0
