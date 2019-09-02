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
rm /etc/zypp/repos.d/*.repo

# Add repos from /etc/YaST2/control.xml
add-yast-repos
zypper --non-interactive rm -u live-add-yast-repos
# Enable autorefresh for some repos
zypper mr -r repo-oss
zypper mr -r repo-non-oss
zypper mr -r repo-update
zypper mr -r repo-update-non-oss

zypper addrepo -f -K -n "Linux Kamarada" http://download.opensuse.org/repositories/home:/kamarada:/15.1:/dev/openSUSE_Leap_15.1/ kamarada

# openSUSE Bug 984330 overlayfs requires AppArmor attach_disconnected flag
# https://bugzilla.opensuse.org/show_bug.cgi?id=984330

# Linux Kamarada issue #1 unable to ping
# https://github.com/kamarada/kiwi-config-Kamarada/issues/1
sed -i -e 's/\/{usr\/,}bin\/ping {/\/{usr\/,}bin\/ping (attach_disconnected) {/g' /etc/apparmor.d/bin.ping

# suseConfig has been kept for compatibility on latest KIWI
if [[ "$kiwi_profiles" == *"pt-BR"* ]];
then
    #baseUpdateSysConfig /etc/sysconfig/keyboard YAST_KEYBOARD "portugese-br,pc104"
    echo "YAST_KEYBOARD=\"portugese-br,pc104\"" >> /etc/sysconfig/keyboard
    #localectl set-keymap br
    sed -i -e 's/@KEYMAP_GOES_HERE@/br/g' /etc/vconsole.conf
    baseUpdateSysConfig /etc/sysconfig/language RC_LANG "pt_BR.UTF-8"
    baseUpdateSysConfig /etc/sysconfig/language ROOT_USES_LANG "yes"
    baseUpdateSysConfig /etc/sysconfig/language INSTALLED_LANGUAGES "pt_BR"
    ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    #baseUpdateSysConfig /etc/sysconfig/clock DEFAULT_TIMEZONE "Brazil/East"
    echo "DEFAULT_TIMEZONE=\"Brazil/East\"" >> /etc/sysconfig/clock
    echo "pt_BR" > /var/lib/zypp/RequestedLocales

    # Locale clean up
    mkdir /usr/share/locale_keep
    mv /usr/share/locale/{en*,pt*} /usr/share/locale_keep/
    rm -rf /usr/share/locale
    mv /usr/share/locale_keep /usr/share/locale

    sed -i 's/New_York/Sao_Paulo/g' /usr/share/calamares/modules/locale.conf
else
    #baseUpdateSysConfig /etc/sysconfig/keyboard YAST_KEYBOARD "english-us,pc104"
    echo "YAST_KEYBOARD=\"english-us,pc104\"" >> /etc/sysconfig/keyboard
    #localectl set-keymap us
    sed -i -e 's/@KEYMAP_GOES_HERE@/us/g' /etc/vconsole.conf
    baseUpdateSysConfig /etc/sysconfig/language RC_LANG "en_US.UTF-8"
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    #baseUpdateSysConfig /etc/sysconfig/clock DEFAULT_TIMEZONE "US/Eastern"
    echo "DEFAULT_TIMEZONE=\"US/Eastern\"" >> /etc/sysconfig/clock

    # YaST Firstboot
    baseUpdateSysConfig /etc/sysconfig/firstboot FIRSTBOOT_CONTROL_FILE "/etc/YaST2/firstboot-kamarada.xml"
    baseUpdateSysConfig /etc/sysconfig/firstboot FIRSTBOOT_WELCOME_DIR "/usr/share/firstboot/"
    touch /var/lib/YaST2/reconfig_system
fi

# Disable journal write to disk in live mode, bug 950999
echo "Storage=volatile" >> /etc/systemd/journald.conf

# Remove generated files (boo#1098535)
rm -rf /var/cache/zypp/* /var/lib/zypp/AnonymousUniqueId /var/lib/systemd/random-seed

# Save 165MB by removing this, not very useful for lives
rm -rf /lib/firmware/{liquidio,netronome}

#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

#======================================
# Exit safely
#--------------------------------------
exit 0
