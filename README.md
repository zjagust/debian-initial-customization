# Debian Initial Customization
**This is a helper script whose purpose is to fully automate initial customization of environment and installation of basic software on Debian operating system right after minimal installation is complete.**

## Prerequisites
This will only work for Debian minimal installations, as described in the following article:
* [Debian 10 Buster minimal installation](https://zacks.eu/debian-buster-minimal-installation/)

## Version
10.0.0 - Specifically for Debian 10 Buster release

## Installation
Once you have Debian minimal installation in place and running, please execute the following commands:
```bash
echo -n > /etc/apt/sources.list

echo -e "deb http://deb.debian.org/debian buster main contrib non-free
deb http://deb.debian.org/debian-security buster/updates main contrib non-free" > /etc/apt/sources
.list

apt-get update

apt-get install -y --no-install-recommends wget ca-certificates unzip

wget https://github.com/zjagust/debian-initial-customization/archive/master.zip

unzip master.zip

cd debian-initial-customization-master

. debian-initial-cutomization.sh
```
When script completes all tasks, your machine will reboot so all settings get applied. Once it boots back up, you can delete **master.zip** file and complete **debian-initial-customization-master** directory.

