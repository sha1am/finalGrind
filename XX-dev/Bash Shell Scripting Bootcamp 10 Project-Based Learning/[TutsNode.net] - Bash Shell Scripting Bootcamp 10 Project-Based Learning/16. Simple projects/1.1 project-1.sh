#!/bin/bash

#This script generates a random quote every time it is executed.

ARRAY=(
"The greatest glory in living lies not in never falling, but in rising every time we fall. - Nelson Mandela"
"The way to get started is to quit talking and begin doing. - Walt Disney"
"Your time is limited, don't waste it living someone else's life. - Steve Jobs"
"If life were predictable it would cease to be life, and be without flavor. - Eleanor Roosevelt"
"If you set your goals ridiculously high and it's a failure, you will fail above everyone else's success."
)

#The following line prints a random quote in red color.

echo -e "\e[31m${ARRAY[$RANDOM%4]}\e[0m"