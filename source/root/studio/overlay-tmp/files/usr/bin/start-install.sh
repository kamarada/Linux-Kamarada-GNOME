#!/bin/bash
#YaST takes a certain time to show up, so we need to prevent calling it twice simultaneously
#snippet from man 1 flock
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

#Look like the DVD installer everywhere
unset XDG_CURRENT_DESKTOP

cat >/etc/install.inf <<EOF
ZyppRepoURL: http://download.opensuse.org/distribution/leap/42.2/repo/oss/
InstMode: net
# disable self-update, it expects inst-sys environment and doesn't work from Live CD
SelfUpdate: 0
EOF

/usr/lib/YaST2/startup/YaST2.call installation initial
