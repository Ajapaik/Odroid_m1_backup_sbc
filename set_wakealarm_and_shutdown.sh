#!/bin/sh
# Scripts shutdown the device and wakes it up after 10 minutes
echo 0 >  /sys/class/rtc/rtc0/wakealarm 
date '+%s' -d '+10 minutes' > /sys/class/rtc/rtc0/wakealarm 
poweroff
