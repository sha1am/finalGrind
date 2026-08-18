#!/bin/bash

# This script is written in bash.

# Colors for terminal output.
RED="\e[31m"
GREEN="\e[32m"
EXIT="\e[0m"

# This script installs packages on the system.

# Checking if the script is being run as the root user.
if [ $UID -ne 0 ]
then
	echo "ERROR: Run as root user...."
	exit 1
fi

# List of packages to be installed.
PACKAGES=( figlet sl net-tools )

# Loop through the packages and install them.
for i in ${PACKAGES[@]}
do
	echo
	echo -e "${RED}[+] Installing $i ....${EXIT}"
	apt install $i -y &>/dev/null
	echo
	echo -e "${GREEN}[+] Installation completed ....${EXIT}"
	echo
done
