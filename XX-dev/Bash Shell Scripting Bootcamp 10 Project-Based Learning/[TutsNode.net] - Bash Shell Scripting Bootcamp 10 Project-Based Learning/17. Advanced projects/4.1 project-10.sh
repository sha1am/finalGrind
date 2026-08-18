#!/bin/bash

# This script provides server utilization information.

# Color codes for terminal output.
RED="\e[1;31m"
GREEN="\e[1;32m"
EXIT="\e[0m"

# Function to print a divider line.
divider () {
	echo -e "${RED}===========================================${EXIT}"
}

clear

# Displaying the title of the script.
echo -e "                               ${GREEN}******************************${EXIT}"
echo -e "                               ${GREEN}***** SERVER UTILIZATION *****${EXIT}"
echo -e "                               ${GREEN}******************************${EXIT}"
divider
echo 

# Displaying the current date.
echo -e "Today's date is : `date`"
echo
divider
echo 

# Displaying system uptime.
echo "Uptime: `uptime`"
echo 
divider
echo 

# Displaying currently logged-on users.
echo "Currently logged-on users:"
w
echo
divider
echo 

# Displaying last logins.
echo "Last logins"
last -a | head -n 3
echo 
divider
echo 

# Displaying disk and memory usage.
echo "Disk and Memory usage"
echo
df -h | xargs | awk '{print "Free/Total disk:" $11 "/" $9 }'
echo
free -m | xargs | awk '{print "Free/Total memory: " $17 "/" $8"  MB"}'
echo
divider
echo 

# Displaying system utilization and most expensive processes.
echo "Utilization and most expensive processes"
echo
top -b | head -n 3
echo 
top -b | head -n 10 | tail -n 4
echo
divider
