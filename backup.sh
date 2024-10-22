#!/bin/bash

export LC_CTYPE="UTF-8"
export LANG="en_US.UTF-8"
export SLACK_KEY="SECRET"
export PUBKEY="pubkey"
export RSYNC_SERVER="rsync_server"

ajapaik_notify() {
    URL="https://ajapaik.ee/status/odroidm1_$1"
    wget --quiet -O /dev/null $URL
}

slack_message() {
        MESSAGE="$(date) Odroid M1: $1"
        JSON_MESSAGE="{\"text\":\"$MESSAGE\"}"
        echo $message
        echo "$message" >> /var/log/backup.slack.log
        curl -X POST -H 'Content-type: application/json' --data "$JSON_MESSAGE" https://hooks.slack.com/services/$SLACK_KEY
}

wait_for_internet() {

   # Wait for internet
   for COUNT in {1..100}
   do
        ping -c1 www.google.com > /dev/null
        if [ $? -eq 0 ]; then
            break
        fi
        sleep 1
   done
}

badger_message() {
   # DATE TIME
   LINE1=$(date "+%F %T")

   # LOCAL IP
   LINE2=`ip route get 1.2.3.4 |head -n1|cut -f 7 -d " "`

   # Message
   LINE3=$1

   source /home/zache/venv/bin/activate
   mpremote exec "import badger2040; badger=badger2040.Badger2040();badger.pen(0);badger.text('$LINE1', 20,20,scale=0.7);badger.text('$LINE2', 20, 60,scale=0.7); badger.text('$LINE3', 20, 100, scale=0.7); badger.update()"
   deactivate
}

rsync_file() {
    SOURCE_FILENAME=$1
    TARGET_DIR="/var/backups/ajapaik"
    TARGET_FILENAME="$TARGET_DIR/$1"
    echo $SOURCE_FILENAME
    rsync $RSYNC_SERVER:/database/$SOURCE_FILENAME*  $TARGET_DIR -avr

    if [ $? -ne 0 ]
    then
        slack_message "$(date) backup node: Error happened in downloading backups ($SOURCE_FILENAME): Error in rsync, exit code was: $rsync_status"
        ajapaik_notify "backup_rsync_db_failed"
        badger_message "rsync db failed"
        exit 1
    fi

    ## check that file exists
     
    if [ ! -f $TARGET_FILENAME ]
    then
        slack_message "$(date) trou.eu: Error happened in daily backup: Backup for date $(date +%d) does not exist"
        ajapaik_notify "backup_file_not_exist_failure"
        badger_message "file failed"

        exit 1
    fi

    sync
    sleep 5
    ## verify integrity of the daily backup

    integrity_status=$(openssl dgst -verify $PUBKEY -keyform PEM -sha256 -signature $TARGET_FILENAME.sign -binary $TARGET_FILENAME)
    echo $TARGET_FILENAME $integrity_status

    if [ "$integrity_status" != "Verified OK" ]
    then
        echo "openssl dgst -verify $PUBKEY -keyform PEM -sha256 -signature $TARGET_FILENAME.sign -binary $TARGET_FILENAME"
        slack_message "$(date) Error happened in daily backup: Integrity of backup couldn't be verified, OpenSSL said: $integrity_status"
        ajapaik_notify "backup_file_integrity_failed"
        badger_message "integrity failed"
        exit 1
    fi
}

rsync_media() {
    rsync $RSYNC_SERVER:/media "/media/btrfs_mirror/media" -avr --partial --append-verify

    # Retry once if transfer fails
    if [ $? -ne 0 ]
    then
        echo "Retrying rsync_media() (#1)"
        rsync $RSYNC_SERVER:/media "/media/btrfs_mirror/media" -avr --partial --append-verify
    fi

    if [ $? -ne 0 ]
    then
        slack_message "$(date) backup node: Error happened in downloading media ($SOURCE_FILENAME): Error in rsync, exit code was: $?"
        ajapaik_notify "backup_rsync_media_failed"
        badger_message "rsync media failed"
        exit 1
    fi
}

daily_db_filename=ajapaik_web_db_daily_$(date +%d).psql.gz.enc
weekly_db_filename=ajapaik_web_db_weekly_$(date -dlast-monday +%Y-%m-%d).psql.gz.enc
project_db_filename=ajapaik_project_daily_$(date +%d).psql.gz

sleep 5
wait_for_internet
badger_message "backup started"
ajapaik_notify "backup_started"

sleep 5
rsync_file $weekly_db_filename
sync
rsync_file $daily_db_filename
sync
rsync_file $project_db_filename
sync

badger_message "backup db OK"
ajapaik_notify "backup_db_ok"
sleep 5

sleep 5
rsync_media
sync
badger_message "backup media OK"
ajapaik_notify "backup_media_ok"

sleep 180
sudo /home/zache/set_wakealarm_and_shutdown.sh
exit 0
