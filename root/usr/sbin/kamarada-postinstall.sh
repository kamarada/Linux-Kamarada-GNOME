#!/bin/bash
set -e

# From: https://github.com/OSInside/kiwi/blob/v9.18.12/kiwi/config/functions.sh
function baseUpdateSysConfig {
    # /.../
    # Update the contents of a sysconfig variable
    # ----
    local FILE=$1
    local VAR
    local VAL
    if [ -f "${FILE}" ];then
        VAR=$2
        VAL=$3
        eval sed -i "s'@^\($VAR=\).*\$@\1\\\"$VAL\\\"@'" "${FILE}"
    else
        echo "warning: config file $FILE not found"
    fi
}

# Set a random password for root
PASSWORD=$(head -c 16  /dev/random | md5sum | cut -f 1 -d\ )
echo "root:$PASSWORD" | chpasswd

# YaST Firstboot
baseUpdateSysConfig /etc/sysconfig/firstboot FIRSTBOOT_CONTROL_FILE "/etc/YaST2/firstboot.xml"
baseUpdateSysConfig /etc/sysconfig/firstboot FIRSTBOOT_WELCOME_DIR ""
touch /var/lib/YaST2/reconfig_system

# Enable journal write to disk
sed -i '/Storage=volatile/d' /etc/systemd/journald.conf

exit 0
