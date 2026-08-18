#!/bin/bash

# This script provides information about a file.

# Check if the script is called with a file argument
if [ $# -eq 0 ]
then
    echo "Usage: $0 [File]"
    exit 1
fi

# Retrieve the owner, size, month, and time of the file
OWNER=$(ls -la $1 | awk '{print $3}')
SIZE=$(ls -la $1 | awk '{print $5}')
MONTH=$(ls -la $1 | awk '{print $6 " " $7}')
TIME=$(ls -la $1 | awk '{print $8}')

echo "File name: $1"
echo
echo "Owner: $OWNER"
echo "Size: $SIZE bytes"
echo "This file was created on $MONTH at $TIME"
echo "File Type: $(file $1)"
echo
echo "Permissions"

# Check if the file is readable
if [ -r $1 ]
then
    echo "READABLE=TRUE"
else
    echo "READABLE=FALSE"
fi

# Check if the file is writable
if [ -w $1 ]
then
    echo "WRITABLE=TRUE"
else
    echo "WRITABLE=FALSE"
fi

# Check if the file is executable
if [ -x $1 ]
then
    echo "EXECUTABLE=TRUE"
else
    echo "EXECUTABLE=FALSE"
fi