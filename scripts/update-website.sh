#!/bin/bash

set -ex

VERSION='15.6'
VERSION_WITHOUT_DOT='156'
LOCAL_FOLDER="/home/vinicius/dev/projects/sf/kamarada/$VERSION/"
REMOTE_LINK="https://sourceforge.net/projects/kamarada/files/$VERSION/"
LOCAL_WEBSITE='/home/vinicius/dev/projects/git/kamarada/kamarada-website-master/'

# Ensure that paths end in slash
[[ $LOCAL_FOLDER != */ ]] && LOCAL_FOLDER="$LOCAL_FOLDER"/
[[ $REMOTE_LINK != */ ]] && REMOTE_LINK="$REMOTE_LINK"/
[[ $LOCAL_WEBSITE != */ ]] && LOCAL_WEBSITE="$LOCAL_WEBSITE"/

update_website() {
    ISO_NAME=$1
    ISO_SIZE=$2
    CHECKSUM=$3
    CHECKSUM_NAME=$4
    SHORT_LANG=$5 # "en" or "pt"

    DATE_FORMAT="%b %d, %Y"
    DECIMAL_SEPARATOR="."

    if [ "$SHORT_LANG" == "pt" ]; then
        DATE_FORMAT="%d/%m/%Y"
        DECIMAL_SEPARATOR=","
    fi

    echo "$SHORT_LANG:"

    echo "    filename_value: '$ISO_NAME'"
    echo "    download_link: '$REMOTE_LINK$ISO_NAME/download'"

    ISO_DATE=$(date -r $ISO_NAME +"$DATE_FORMAT")
    ISO_DATE="${ISO_DATE^}"
    echo "    date_value: '$ISO_DATE'"

    ISO_SIZE_READABLE=$(echo "${ISO_SIZE}" | awk '{ split( "B KB MB GB TB PB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } printf "%.2f %s", $1, v[s] }')
    ISO_SIZE_READABLE=${ISO_SIZE_READABLE//'.'/$DECIMAL_SEPARATOR}
    echo "    size_value: '$ISO_SIZE_READABLE'"

    echo "    sha256sum_value: '$CHECKSUM'"

    echo "    sha256sum_link: '$REMOTE_LINK$CHECKSUM_NAME/download'"
}

cd $LOCAL_FOLDER

ISO_NAME=$(find * -name "*.iso")

ISO_SIZE=$(find . -maxdepth 1 -type f -name $ISO_NAME -printf '%s')

CHECKSUM=$(sha256sum $ISO_NAME)
CHECKSUM=${CHECKSUM%% *}

CHECKSUM_NAME=$(find * -name "*.iso.sha256")

LANG=en update_website $ISO_NAME $ISO_SIZE $CHECKSUM $CHECKSUM_NAME "en" > "${LOCAL_WEBSITE}_data/download$VERSION_WITHOUT_DOT.yml"
LANG=pt update_website $ISO_NAME $ISO_SIZE $CHECKSUM $CHECKSUM_NAME "pt" >> "${LOCAL_WEBSITE}_data/download$VERSION_WITHOUT_DOT.yml"

