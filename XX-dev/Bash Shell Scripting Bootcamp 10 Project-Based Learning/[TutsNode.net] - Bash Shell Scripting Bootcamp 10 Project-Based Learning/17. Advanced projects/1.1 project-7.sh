#!/bin/bash

# This script processes images.

# Checking if the script is called with the correct arguments.
if [ $# -eq 0 ]
then
	echo "Usage: $0 [File-1] [File-2] .... [File-n]"
fi

# Looping through each file argument provided.
for i in $@
do
	# Checking if the argument is a regular file.
	if [ -f $i ]
	then
		# Extracting the file name without the extension.
		file_name=`echo $i | sed 's/[.].*//'`
		# Converting the file to PNG format using the 'convert' command.
		convert $i $file_name.png
	else
		echo "ERROR: $i is not a regular file..."
	fi 
done

echo "[+] File conversion completed."
