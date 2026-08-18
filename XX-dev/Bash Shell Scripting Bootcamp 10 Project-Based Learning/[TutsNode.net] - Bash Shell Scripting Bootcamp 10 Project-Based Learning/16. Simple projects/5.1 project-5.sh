#!/bin/bash

# This script will check you are root or a normal user.


if [ $UID -eq 0 ]
then
	echo "You have access to this file system... "
else
	echo "You must be root to access this file system. "
fi