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
    trap ctrlC SIGINT   # Trap Ctrl+C.

    # Misc items
    declare -gr SPACER='----------------------------------------------------------------------------------------------------'
	declare -gr E=$'\e[1;31;103m'			# (E) Error: highlighted text.
	declare -gr W=$'\e[1;31;103m'			# (W) Warning: highlighted text.
	declare -gr B=$'\e[1m'				# B for Bold.
	declare -gr R=$'\e[0m'				# R for Reset.

    # Display a warning.
	clear

	# Give some instruction.
	# Show a warning.
	cat <<-END


		${SPACER}


		${B}WARNING${R}

		This script is only to be run on Debian 10 minimal installations, as described on the following link:
        https://zacks.eu/debian-buster-minimal-installation/

        The script has a specific purpose and runs a certain tasks involving operating system environment
        customization and software installation. Running this script anywhere at any time will leave you
        with potentially un-bootable OS and software you may not want.

        A detailed overview of tasks this script will perform can be seen on the following link:
        https://zacks.eu/debian-10-buster-initial-customization/

        Please make sure you understand what is written above!


	END

    # Ask for confirmation.
	local ANSWER
	read -rp "Type ${B}Y${R} to proceed, or anything else to cancel, and press Enter: ${B}" ANSWER
	echo "${R}"

	# Terminate if required.
	if [[ "${ANSWER,}" != 'y' ]]
	then
		echo
		echo 'Terminated. I did nothing.'
		echo
		exit 1
	fi
} # initialise end

initialise