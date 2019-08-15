#!/usr/bin/env bash

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

} # modifyGrub end

initialise
preseedInitialize
setSources
modifyGrub