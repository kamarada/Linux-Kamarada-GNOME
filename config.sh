#!/bin/bash

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
# Mount system filesystems
#--------------------------------------
baseMount

#======================================
# Call configuration code/functions
#--------------------------------------

# Setup baseproduct link
suseSetupProduct

# Add missing gpg keys to rpm
suseImportBuildKey

# Activate services
suseRemoveService wicked
suseRemoveService SuSEfirewall2
suseInsertService NetworkManager
suseInsertService firewalld

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
/usr/sbin/useradd -m -u 999 linux -c "LiveDVD User" -p ""

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

# Official repositories
# (as found in http://download.opensuse.org/distribution/leap/15.2/repo/oss/control.xml)
rm /etc/zypp/repos.d/*.repo
zypper addrepo -f -K -n "Main Update Repository" http://download.opensuse.org/update/leap/15.2/oss/ repo-update
zypper addrepo -f -K -n "Update Repository (Non-Oss)" http://download.opensuse.org/update/leap/15.2/non-oss/ repo-update-non-oss
zypper addrepo -f -K -n "Main Repository" http://download.opensuse.org/distribution/leap/15.2/repo/oss/ repo-oss
zypper addrepo -f -K -n "Non-OSS Repository" http://download.opensuse.org/distribution/leap/15.2/repo/non-oss/ repo-non-oss
zypper addrepo -d -K -n "Debug Repository" http://download.opensuse.org/debug/distribution/leap/15.2/repo/oss/ repo-debug
zypper addrepo -d -K -n "Debug Repository (Non-OSS)" http://download.opensuse.org/debug/distribution/leap/15.2/repo/non-oss/ repo-debug-non-oss
zypper addrepo -d -K -n "Update Repository (Debug)" http://download.opensuse.org/debug/update/leap/15.2/oss repo-debug-update
zypper addrepo -d -K -n "Update Repository (Debug, Non-OSS)" http://download.opensuse.org/debug/update/leap/15.2/non-oss/ repo-debug-update-non-oss
zypper addrepo -d -K -n "Source Repository" http://download.opensuse.org/source/distribution/leap/15.2/repo/oss/ repo-source
zypper addrepo -d -K -n "Source Repository (Non-OSS)" http://download.opensuse.org/source/distribution/leap/15.2/repo/non-oss/ repo-source-non-oss
zypper addrepo -f -K -n "Linux Kamarada" http://download.opensuse.org/repositories/home:/kamarada:/15.2:/dev/openSUSE_Leap_15.2/ kamarada

# openSUSE Bug 984330 overlayfs requires AppArmor attach_disconnected flag
# https://bugzilla.opensuse.org/show_bug.cgi?id=984330

# Linux Kamarada issue #1 unable to ping
# https://github.com/kamarada/kiwi-config-Kamarada/issues/1
sed -i -e 's/\/{usr\/,}bin\/ping {/\/{usr\/,}bin\/ping (attach_disconnected) {/g' /etc/apparmor.d/bin.ping

# SuSEconfig
suseConfig

#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

#======================================
# Exit safely
#--------------------------------------
exit 0
