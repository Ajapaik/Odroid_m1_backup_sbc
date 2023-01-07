#!/bin/bash

# Wait for internet
for COUNT in {1..100}
do
        ping -c1 www.google.com > /dev/null
        if [ $? -eq 0 ]; then
            break
        fi
        sleep 1
done

# Mode
case "$1" in
        boot)
                LINE3="BOOT"
                ;;
        powerdown)
                LINE3="POWERDOWN"
                ;;
        reboot)
                LINE3="REBOOT"
                ;;
        *)

                echo "Update the eink display. Available messages are boot, online, powerdown, reboot"
                echo "Usage: $0 {boot|powerdown|reboot}"
                exit 1
esac

LINE2=`ip route get 1.2.3.4 |head -n1|cut -f 7 -d " "`
LINE1=$(date "+%F %T")
source /home/zache/venv/bin/activate
mpremote exec "import badger2040; badger=badger2040.Badger2040();badger.pen(0);badger.text('$LINE1', 20,20,scale=0.7);badger.text('$LINE2', 20, 60,scale=0.7); badger.text('$LINE3', 20, 100, scale=0.7); badger.update()"
