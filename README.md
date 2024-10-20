<a href="https://commons.wikimedia.org/wiki/File:Odroid_M1_with_SATA_mount_cablekit_with_Samsung_SATA_SSD_drive.jpg"><img align="right"   src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Odroid_M1_with_SATA_mount_cablekit_with_Samsung_SATA_SSD_drive.jpg/264px-Odroid_M1_with_SATA_mount_cablekit_with_Samsung_SATA_SSD_drive.jpg" /></a>
The target for the device is a low-power daily backup device that is robust enough to survive electrical blackouts and simple enough so that it can be duplicated for redundancy when needed.

* [Read more about project background](Background.md)

# Workflow

1. Wake up from suspend
2. Update e-ink display with message backup started + TIMESTAMP
3. Send heartbeat information to a remote server
4. Check that hardware is OK
5. RSYNC databases 
6. RSYNC images
7. BACKUP Github repositories
8. Mount storage disk as read-only
9. Check using checksums that data was copied correctly
10. Update e-ink display with message backup was successfully finished + TIMESTAMP
11. Suspend for 24h and goto #1

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
* Odroid M1 SATA Mount and Cable Kit screws are too long for attaching SSD:st to plate with some drives and additional screws are needed. For example Samsung PM897 screwholes are shorter than screws.

# Power consumption notes
* Board with default OS (emmc with Ubuntu 20.04 ) average power consumption was ~3.5W (2.1.2022)
* Board with Ubuntu 22.04 via Petiboot (emmc, commandline only) average power consumption was ~4W (2.1.2022)
* Board with Debian bullseye install via Petiboot (emmc+Samsung 970 EVO Nvme) 8.4W max (4.1.2022)
* Board with Debian bullseye installed via Petiboot (emmc+Samsung PM897 2.5" SSD ) 4.7W max (21.1.2022)
* Board with Ubuntu 22.04 via Petiboot (emmc+Samsung PM897, commandline only) average power consumption was 5.7W (21.1.2022)
* Board with Debian GNU/Linux 11 (bullseye) (emmc+Samsung PM897 2.5" SATA+ 970 EVO Nvme + Badger eink) 4.86 W idle 20.10.2024)
 
# Operating system 
* Debian 11 (installable via Petiboot netboot installer)

# Alternatives
* [Odroid default OS Ubuntu 20.04 : Ubuntu Kernel 4.19](https://wiki.odroid.com/odroid-m1/os_images/ubuntu/ubuntu)
* [Armbian stable 22.11 with 6.1.y](https://www.armbian.com/odroid-m1/) - ([Odroid forum](https://forum.odroid.com/viewtopic.php?f=214&t=44575)) (uses mainline kernel, doesn't support emmc?)
* Ubuntu 22.04 with 5.18 kernel (installable via Petiboot netboot installer)

## OS Notes

### Data drive Filesystem options
* Ext4 + md5sums for detecting bitrot + rsync --backup + optionally par2 data for recovering data 
  - simple in filesystem level, but complex to implement scripting
* Ext4 + FS-PARITY for detecting bitrot + rsync --backup 
  - works only for read only files, doesn't allow updating image files
* Zfs + snapshots + optionally two data copies for self-healing
  - Stable and well working, Incompatible licence with Linux kernel, doesn't work with Petiboot installations (requires Armbian to work out-of-the-box)
* Btrfs + snapshots + optionally two data copies for self-healing
  - Unstable reputation on unexpected KERNEL HALTS or powerloss
* Bcachefs
  - Beta and is not mainlined. Requires 6.2 kernel ( = Armbian) . Supports snapshots and checksumming and erasure coding.

# Eink display
## Badger 2040 with mpremote

```
sudo apt-get install python3-venv
source venv/bin/activate
pip install mpremote
mpremote exec "import badger2040; badger=badger2040.Badger2040();badger.pen(0);badger.text('Testing ...', 20,20);badger.update()"
```

# Example boot status script
* [badger.sh](badger.sh)

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

# GPG Keys
* https://www.jwillikers.com/backup-and-restore-a-gpg-key

## encrypt
```
cat file.gz | gpg --encrypt --batch --cipher-algo AES256 --compress-algo none -r b763e320fe05cc67744d8353d88eb927 -o file.gz.enc --trusted-key b763e320fe05cc67744d8353d88eb927 
gpg --output private.pgp --armor --export-secret-key b763e320fe05cc67744d8353d88eb927
```

On target machine
## restore
```
scp username@source.org:/home/backup/private.pgp /home/restore/private.gpg
scp username@source.org:/home/backup/file.gz.enc /home/restore/file.gz.enc

gpg -o private.gpg --export-options backup --export-secret-keys
gpg --decrypt file.gz.enc |gzip -t
```

# Flowchart
<img src="https://github.com/Ajapaik/Odroid_m1_backup_sbc/blob/main/Odroid%20M1%20backup%20node%20workflow.drawio.svg" width=60% >




