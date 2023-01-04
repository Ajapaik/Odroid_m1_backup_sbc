<a href="https://commons.wikimedia.org/wiki/File:Odroid_M1_with_SATA_mount_cablekit_with_Samsung_SATA_SSD_drive.jpg"><img align="right"   src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Odroid_M1_with_SATA_mount_cablekit_with_Samsung_SATA_SSD_drive.jpg/264px-Odroid_M1_with_SATA_mount_cablekit_with_Samsung_SATA_SSD_drive.jpg" /></a>
The target for the device is a low-power daily backup device that is robust enough to survive electrical blackouts and simple enough so that it can be duplicated for redundancy when needed.

# Workflow

1. Wake up from suspend
2. Update e-ink display with message backup started + TIMESTAMP
3. Send heartbeat information to a remote server
4. Check that hardware is OK
5. RSYNC databases 
6. RSYNC images  
7. Mount storage disk as read-only
8. Check using checksums that data was copied correctly
9. Update e-ink display with message backup was successfully finished + TIMESTAMP
10. Suspend for 24h and goto #1

# Hardware

* [Odroid M1 8GB](https://www.hardkernel.com/shop/odroid-m1-with-8gbyte-ram/) (documentation: [Odroid wiki](https://wiki.odroid.com/odroid-m1/hardware/start))
* [KKSB Odroid M1 Case](https://kksb-cases.com/products/kksb-odroid-m1-chassi)
* [KKSB 12mm Push Button Momentary Power Switch](https://kksb-cases.com/products/kksb-12mm-push-button)
* [12V/2A power supply EU plug](https://www.hardkernel.com/shop/12v-2a-power-supply-eu-plug/)
* [CR 2032 RTC Battery](https://wiki.odroid.com/odroid-m1/getting_started/equip_an_rtc_battery) 
* [128GB eMMC Linux Module for Odroid M1](https://www.hardkernel.com/shop/128gb-emmc-module-m1-linux/) (boot & root drive)
* [Odroid M1 SATA Mount and Cable Kit](https://www.hardkernel.com/shop/m1-sata-mount-and-cable-kit/) (documentation: [Odroid wiki](https://wiki.odroid.com/accessory/cables/sata_holder?s[]=odroid&s[]=m1&s[]=sata))
* [Samsung PM897 2.5" SSD 3.84TB](https://semiconductor.samsung.com/resources/brochure/Samsung%20SATA%20SSD%20PM893%20%20PM897.pdf) (storage drive)
* [Badger 2040](https://shop.pimoroni.com/products/badger-2040) (eink display)
* [USB-A (Male) to USB-C Cable](https://www.tekniikkaosat.fi/tuote/sign-lyhyt-usb-c-kaapeli-nylonista-5v-3a-20cm-hopea)

* surge protector (?)

## Install notes
* m.2 screw is using _very small_ phillips screwdriver head
* eMMC card needs to be installed before board is installed to KKSB case as there is no room for fingers next to eMMC slot when it is in place

# Power consumption notes
* Board with default OS (emmc with Ubuntu 20.04 ) average power consumption was ~3.5W (2.1.2022)
* Board with Ubuntu 22.04 via Petiboot (emmc, commandline only) average power consumption was ~4W (2.1.2022)
* Board with Debian bullseye install via Petiboot (emmc+Samsung 970 EVO Nvme) 8.4W max (4.1.2022)
 
# Operating system 

## Default OS
* [Odroid default OS Ubuntu 20.04 : Ubuntu Kernel 4.19](https://wiki.odroid.com/odroid-m1/os_images/ubuntu/ubuntu)

## Alternatives 
* [Armbian stable 22.11 with 6.1.y](https://www.armbian.com/odroid-m1/) - ([Odroid forum](https://forum.odroid.com/viewtopic.php?f=214&t=44575)) (uses mainline kernel, doesn't support emmc?)
* Ubuntu 22.04 with 5.18 kernel (installable via Petiboot netboot installer)
* Debian 11 (installable via Petiboot netboot installer)

# Eink display
Information in the display
## On boot
* Date/time
* Local IP address
* Internet access state (OK/FAIL)
* Ssh server state (OK/FAIL)
* State: "START

## On failure
* Date/time
* Local IP address
* Internet access state (OK/FAIL)
* Ssh server state (OK/FAIL)
* State: "FAILED (NUMBER)"

## On backup finished
* Date/time
* Local IP address
* State: "BACKUP READY, SLEEPING..."

# Flowchart
<img src="https://github.com/Ajapaik/Odroid_m1_backup_sbc/blob/main/Odroid%20M1%20backup%20node%20workflow.drawio.svg" width=60% >




