# Origin of the project

The Helsinki rephotography project (2018-2022) with Ajapaik was to develop a solution for backups and monitoring. Our solution was to use a Linux server for this. However, as we used it, we noticed that there was also a need to have a dedicated solution just for backups and monitoring which could run under minimal maintenance. Another requirement was that the solution would need to be cheap and available in future too so that it could be replaced in case of hardware failure.

In the Autumn 2022, the Russian invasion of Ukraine caused a spike in energy bills in Europe. For Finland, electricity prices doubled or tripled; it was unknown how high it would go. This situation prompted us to seek alternatives to our homelab Linux server, allowing us to use the larger server only when required while a low-power system would remain operational 24/7.

Initially, we considered using second-hand laptops, mini PCs, or the Mac mini. However, this would result in a diverse mix of hardware, making maintenance challenging. These would also have moving parts like fans which could fail. We also considered using Raspberry Pi's, but its unavailability and limited IO bandwidth made it a less-than-ideal choice for storage.

After evaluating various options, we discovered the Odroid M1 single-board computer. It was selected for its good storage support, low power usage, and readily available casing. The manufacturer had also committed to long-term support for the device.

One major challenge was the absence of mainline Linux software support for the hardware. This forced us to use a downstream distribution from the manufacturer. However, we remained hopeful that mainline software support would become available in a few years as rk3568-based boards gained popularity, allowing us to use the standard Debian distribution.

Another concern was that SSDs could fail due to sudden power loss, and even configuring them as read-only wouldn't solve this problem. If we wanted the hardware to run for an extended period, this could likely be a point of failure.

We could have safeguarded the hardware with a UPS, but this would increase cost, power consumption, and heat output and added another potential failure point. Instead of using a UPS, we decided to program the device to wake up periodically using the real-time clock and shut it down once the task was completed. This strategy would keep the device off for over 95% of the time, significantly reducing the chance of power loss occurring while it was on. We considered using a simple surge protector for additional protection. For added safety, we opted to use industrial SSDs, which, although more expensive, provide hardware-level protection against power loss.

From a security standpoint, the backup files are encrypted before being transferred to the device using rsync. Encryption keys was not keeped on the backup device. File integrity was none using SHA-1 checksums. The newest versions of the files are also backed up to two separate disks. 

As for maintenance, the system will install security updates automatically. Also, normally, devices don't have any services such as SSH open, but the administrator can trigger maintenance mode with SSH access. 

Since the device would be off most of the time, we added a small E-ink display. E-ink displays can maintain the image even without power, allowing us to see the last status of the device when it is powered down. For online tracking, we programmed the device to send a heartbeat notification to the web server both when it powers on and after the task is completed. If the device encounters errors or warnings, it sends alerts through Slack. If the web server doesn't receive the device's heartbeat notifications, it triggers Slack alerts.

In our plan, we intended to use two nodes in physically separate locations, with both nodes performing identical backups independently. It is also possible to add redundancy by incorporating similar new nodes.

# About  sustainability. 

As single-board computers, power consumption is very low, for Odroid M1, it is 6W, and in our strategy, it is mostly powered down the power consumption is minimal. Single-board computers are small, and overall material footprint and transport costs are smaller than traditional computers.

Regarding hardware lifespan, disk space will run out at some point, but it will take over five years at the current speed. Then the SSD will need to be replaced with a larger one, or we need to change the backup strategy. Peripheral components (power adapters, disks, batteries, e-ink displays) can be replaced and are produced by multiple manufacturers. Information about the Odroid M1 and e-ink displays, including schematics, is publicly available, making repairs at some level possible. 

The biggest unknown issue is on mainline Linux support. If there is mainline Linux support, then there is working hardware support for the entire lifetime of the hardware. However, if the mainline support needs to be included, then software support may be substantially shorter than the hardware's lifetime.

# Technical implementation

See: [Readme](https://github.com/Ajapaik/Odroid_m1_backup_sbc/tree/main#readme)
