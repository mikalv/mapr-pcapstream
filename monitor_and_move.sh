#!/usr/bin/env bash

source env.sh

inotifywait=$(which inotifywait)

if [ -z $inotifywait ]; then
    echo "inotifywait is not installed. Please install it."
    exit 1
fi

while true; do
    if [ -d $CAPTURE_DIR ]; then
        $inotifywait -q -t 300 -e create $NFS_CAPTURE_DIR
        # get the second most recently created file
        # the most recent is being written to and is 
        # not ready for processing. Filter out . and ..
        FILENAME_TO_RENAME=$(ls -atr $NFS_CAPTURE_DIR | egrep -v '^\.{1,2}$' | tail -2 | head -1)
        NEW_NAME=$(echo $FILENAME_TO_RENAME | sed -e 's/\.//')
        if ! [ $FILENAME_TO_RENAME == $NEW_NAME ]; then
            if ! $(mv "$NFS_CAPTURE_DIR/$FILENAME_TO_RENAME" "$NFS_CAPTURE_DIR/$NEW_NAME"); then
                echo "Failed to rename $NFS_CAPTURE_DIR/$FILENAME_TO_RENAME"
            fi
        fi
    else
        echo "waiting for $NFS_CAPTURE_DIR to exist."
    fi
    sleep .5
done
