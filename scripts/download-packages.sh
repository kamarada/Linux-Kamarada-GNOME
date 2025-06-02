#!/bin/bash

set -ex

LOCAL_FOLDER='/home/vinicius/dev/projects/git/kamarada/packages/public/15.6/'
DOWNLOADOO_PATH='https://download.opensuse.org/repositories/home:/kamarada:/15.6/'

# Ensure that paths end in slash
[[ $LOCAL_FOLDER != */ ]] && LOCAL_FOLDER="$LOCAL_FOLDER"/
[[ $DOWNLOADOO_PATH != */ ]] && DOWNLOADOO_PATH="$DOWNLOADOO_PATH"/

[ -d $LOCAL_FOLDER ] || mkdir -p $LOCAL_FOLDER
cd $LOCAL_FOLDER

# Compute skip paths
SKIP_PATHS=`echo $DOWNLOADOO_PATH | tr -cd '/' | wc -c`
SKIP_PATHS=`expr $SKIP_PATHS - 3`
# There are 3 slashes in "https://download.opensuse.org/"

# Download everything from OBS
wget -q -m -nH --cut-dirs=$SKIP_PATHS -np --reject 'index.*,*.meta4,*.metalink,*.mirrorlist,*.iso*' -e robots=off $DOWNLOADOO_PATH
# To prevent duplicate (big) ISO images, I'm going to download them by hand

# .repo file needs to be deleted, otherwise local mirror redirects to download.opensuse.org
find . -name '*.repo' -type f -delete

LOCAL_FILES=`find -path $LOCAL_FOLDER -prune -o -type f -printf '%P\n'`

# For each file stored locally
for LOCAL_FILE in $LOCAL_FILES ; do
    # Check whether the file exists online
    HTTP_STATUS=`curl -o /dev/null --silent --head --write-out '%{http_code}\n' "$DOWNLOADOO_PATH$LOCAL_FILE"`
    # If it does not exist online, delete it
    if [[ $HTTP_STATUS == 404 ]]
    then
        rm $LOCAL_FILE
    fi
done

rm -rf "${LOCAL_FOLDER}images"

echo -e "\n\nRemember to download ISO images by hand:\n\n${DOWNLOADOO_PATH}images/iso/\n"

