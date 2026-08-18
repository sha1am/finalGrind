#!/bin/bash

# This script gathers information from employees and stores it in a CSV file.

# Prompt the user to enter their name
read -p "[+] Enter your name: " NAME

# Prompt the user to enter their employee ID
read -p "[+] Enter your employee ID: " ID

# Prompt the user to enter their department
read -p "[+] Enter your department: " DEPARTMENT

# Prompt the user to enter their gender
read -p "[+] Enter your gender: " GENDER

# Store the gathered information in the INFO variable
INFO="$NAME,$ID,$DEPARTMENT,$GENDER"

echo

# Ask the user to confirm if the information provided is correct
read -p "Do you confirm the provided information is correct? [y/n]:" INPUT

case "$INPUT" in
	n|N)
		exit
		;;
	Y|y)
		# Append the INFO to the employee_data.csv file
		echo $INFO >> employee_data.csv
		;;
	*)
		exit
		;;
esac

echo "Your data has been stored successfully."