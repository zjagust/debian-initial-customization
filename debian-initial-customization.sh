#!/usr/bin/env bash
set -eio pipefail

#######################################################################################################
#
# Debian 10 Buster initial customization script
#
# This script is only to be run on Debian 10 minimal installations, as described on the following link:
# https://zacks.eu/debian-buster-minimal-installation/
#
# The script has a specific purpose and runs a certain tasks involving operating system environment 
# customization and software installation. Running this script anywhere at any time will leave you 
# with potentially un-bootable OS and software you may not want.
#
# A detailed overview of tasks this script will perform can be seen on the following link:
# https://zacks.eu/debian-10-buster-initial-customization/
#
# Please follow the instructions!
#
#######################################################################################################

################
## INITIALIZE ##
################

function initialise ()
{
	# Misc items
	declare -gr SPACER='----------------------------------------------------------------------------------------------------'
	declare -gr E=$'\e[1;31;103m'			# (E) Error: highlighted text.
	declare -gr W=$'\e[1;31;103m'			# (W) Warning: highlighted text.
	declare -gr B=$'\e[1m'				# B for Bold.
	declare -gr R=$'\e[0m'				# R for Reset.

	# Display a warning.
	clear

	# Show a warning.
	cat <<-END
 
		${SPACER}

		    ${B}** WARNING **${R}

		    This script is only to be run on Debian 10 minimal installations, as described on the following link:
		    https://zacks.eu/debian-buster-minimal-installation/

		    The script has a specific purpose and runs a certain tasks involving operating system environment
		    customization and software installation. Running this script anywhere at any time will leave you
		    with potentially un-bootable OS and software you may not want.

		    A detailed overview of tasks this script will perform can be seen on the following link:
		    https://zacks.eu/debian-10-buster-initial-customization/

		    Please make sure you understand what is written above!

		${SPACER}
 
	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} to proceed, or anything else to cancel, and press Enter: ${B}" ANSWER
	echo "${R}"

	# Terminate if required.
	if [[ "${ANSWER,}" != 'y' ]]
	then
		echo
		echo 'Terminated. Nothing done.'
		echo
		exit 1
	fi

} # initialise end

#############################
## INITIALIZE PRESEED FILE ##
#############################

function preseedInitialize ()
{
	cat <<-END
		${SPACER}

		    Script will now initialize a preseed file required for software installation. Since all software installation
		    is unattended (requires no user interaction), we need to give the installer some answers which it would 
		    usually ask for. This file will provide such answers.

		${SPACER}
	
	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Initialize debian.preseed
	cd "$(dirname "$0")"
	debconf-set-selections preseed/debian.preseed

} # preseedInitialize end

##########################
## SET SOFTWARE SOURCES ##
##########################

function setSources ()
{
	cat <<-END
		${SPACER}

		    A correct software repositories will be set in this step. All the software will be installed from the sources
		    set in this step. Once in place, script will invoke repository update.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Set sources.list
	echo -n > /etc/apt/sources.list
	echo -e "deb http://deb.debian.org/debian buster main contrib non-free
	deb http://deb.debian.org/debian-security stable/updates main contrib non-free" > /etc/apt/sources.list
	# Update repositories
	apt-get update

} # setSources end

########################
## GRUB MODIFICATIONS ##
########################

function modifyGrub ()
{
	cat <<-END
		${SPACER}

		    At this stage the script will modify some values regarding GRUB boot loader. It will set a verbose
		    boot process display and it will force the use of legacy network interface names.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Set boot verbosity
	sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT=""/g' /etc/default/grub
	# Enforce legacy interfaces names
	sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
	# Update GRUB
	update-grub

} # modifyGrub end

##########################
## NET INTERFACES NAMES ##
##########################

function interfacesName ()
{
	cat <<-END
		${SPACER}
		
		    Considering the enforcement of legacy network interfaces names in GRUB in previous step, scritp will
		    now modify the interfaces itself, setting the legacy names in /etc/network/interfaces file.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Set interface name
	sed -i 's/^allow_hotplug .*/allow_hotplug eth0/' /etc/network/interfaces
	# Set interface name on protocol line
	sed -i 's/^iface .* inet dhcp/iface eth0 inet dhcp/' /etc/network/interfaces

} # interfacesName end

########################
## ADDITIONAL LOCALES ##
########################

function additionalLocales ()
{
	cat <<-END
		${SPACER}

		    In this step script will set up some additional locales and limit system message translation (only US
		    English will be supported).

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Set locales
	update-locale LC_ALL=en_US.UTF-8
	update-locale LC_MESSAGES=POSIX
	update-locale LC_LANGUAGE=en_US.UTF-8
	# Export locales
	export LC_ALL=en_US.UTF-8
	export LC_MESSAGES=POSIX
	export LC_LANGUAGE=en_US.UTF-8

} # additionalLocales end

#########################
## DEBCONF MIN DETAILS ##
#########################

function debconfMinimal ()
{
	cat <<-END
		${SPACER}

		    Script will now set installer detail level to a minimum. Since this is unattended installation,
		    and preseed file is already provided, we don't want no questions asked from installer.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Reconfigure debconf - minimal details
	echo -e "debconf debconf/frontend select Noninteractive\ndebconf debconf/priority select critical" | debconf-set-selections

} # debconfMinimal end

#########################
## ADDITIONAL SOFTWARE ##
#########################

function sysdigRepo ()
{
	cat <<-END
		${SPACER}

		    At this stage script will add some additional software repositories. It will also install
		    some additional software required to setup such repositories.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Install required software for repo setup
	apt-get install -y --no-install-recommends curl gnupg2
	# Set Sysdig repo key
	curl -s http://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public | apt-key add -
	# Define Sysdig repo source file
	curl -s -o /etc/apt/sources.list.d/draios.list http://download.draios.com/stable/deb/draios.list
	# Update APT
	apt-get update

} # sysdigRepo end

#################################
## INSTALL APTITUDE AND UPDATE ##
#################################

function installAptitude ()
{
	cat <<-END
		${SPACER}

		    I prefer Aptitude over apt-get or apt itself just because it has a primitive, but very useful UI.
		    The script will now install Aptitude and perform initial full system upgrade.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Install Aptitude
	apt-get install --no-install-recommends -y aptitude apt-transport-https
	# Update repos with Aptitude
	aptitude update -q2
	# Forget new packages
	aptitude forget-new
	# Perform full system upgrade
	aptitude full-upgrade --purge-unused -y

} # installAptitude end

###############################
## STANDARD SOFTWARE INSTALL ##
###############################

function standardSoftware ()
{
	cat <<-END
		${SPACER}

		    At this stage script will install a first batch of some useful software. Mostly a bunch of
		    helpful system utilities.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Install standard software packages
	aptitude install -R -y busybox_ bash-completion bind9-host busybox-static dnsutils dosfstools \
	friendly-recovery ftp fuse geoip-database groff-base hdparm info install-info iputils-tracepath irqbalance \
	lshw lsof ltrace man-db manpages mlocate mtr-tiny parted powermgmt-base psmisc rsync sgml-base strace \
	tcpdump telnet time uuid-runtime xml-core iptables

} # standardSoftware end

###############################
## DEVELOPMENT TOOLS INSTALL ##
###############################

function develSoftware ()
{
	cat <<-END
		${SPACER}

		    With standard software installed, script will now install a batch of software required to
		    build various other software from source.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Install development tools
	aptitude install -R -y linux-headers-amd64 build-essential

} # develSoftware end

#################################
## ADDITIONAL SOFTWARE INSTALL ##
#################################

function additionalSoftware ()
{
	cat <<-END
		${SPACER}

		    This is the final batch of software the script will install. Again, mostly a bunch of helpful
		    system tools and utilites, hardware monitoring tools, compress/decompress utils and other.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Install additiona software
	aptitude install -R -y safecat sharutils lynx zip unzip lrzip pbzip2 p7zip p7zip-full rar pigz unrar acpid \
	inotify-tools sysfsutils dstat htop lsscsi iotop itop nmap ifstat iftop tcptrack whois atop \
	sysstat gpm localepurge mc screen vim ethtool apt-file sysdig net-tools sudo wget
	# Update apt-file
	apt-file update
	# Turn off screen startup message
	sed -i 's/^#startup_message/startup_message/g' /etc/screenrc
	# Configure Vim for root user
	mkdir -p /root/.vim/saves
	cat <<-EOF > /root/.vimrc
		set tabstop=4
		set softtabstop=4
		set expandtab
		set shiftwidth=4
		set backupdir=~/.vim/saves/
		set mousemodel=popup
		syntax on
	EOF

} # additionalSoftware end

#################################
## SET CUSTOM BASHRC $ CLEANUP ##
#################################

function bashrcCleanup ()
{
	cat <<-END
		${SPACER}

		    This is the last task the script will perform. It will set a custom .bashrc environment file with
		    custom prompt, alias and history definitions. It will also cleanup the system from any leftovers
		    and reboot the machine so all settings get in place.

		${SPACER}

	END

	# Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} and press Enter to proceed: ${B}" ANSWER
	echo "${R}"

	# Set custom bashrc env file
	cd "$(dirname "$0")"
	cp environment/.bashrc /root/.
	# APT cleanup
	aptitude clean
	aptitude autoclean
	# Return debconf to max details
	echo -e "debconf debconf/frontend select Dialog\ndebconf debconf/priority select low" | debconf-set-selections
	# Reboot the system
	reboot

} # bashrcCleanup end

initialise
preseedInitialize
setSources
modifyGrub
interfacesName
additionalLocales
debconfMinimal
sysdigRepo
installAptitude
standardSoftware
develSoftware
additionalSoftware
bashrcCleanup