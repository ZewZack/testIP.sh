#!/bin/bash

# Function to get CIDR blocks from whois
get_cidr_blocks() {
  whois "$1" | grep "CIDR" | awk '{print $2}'
}

# Prompt for IP address if not provided as an argument
if [ -z "$1" ]; then
  echo -n "What is the IP address? : "
  read TESTIP
else
  TESTIP=$1
fi

# Perform GeoIP lookup
geoip_result=$(geoiplookup "$TESTIP")
echo "$geoip_result"

# Prompt user to continue
echo "Do you want to continue? (yes/no)"
read answer

if [ "$answer" != "yes" ]; then
  echo "Terminating script."
  exit 0
fi

# Get CIDR blocks from whois
cidr_blocks=$(get_cidr_blocks "$TESTIP")

# Check if any CIDR blocks were found
if [ -z "$cidr_blocks" ]; then
  echo "No CIDR blocks found. Blocking IP only."
  sudo ufw deny from "$TESTIP"
else
  IFS=$'\n' read -rd '' -a cidr_array <<< "$cidr_blocks"
  echo "Found CIDR blocks:"
  for cidr in "${cidr_array[@]}"; do
    echo "$cidr"
    sudo ufw deny from "$cidr"
  done
fi

echo "I found that IP is: $TESTIP"
if [ -n "$cidr_blocks" ]; then
  echo "Found CIDR/CIDR'S:"
  for cidr in "${cidr_array[@]}"; do
    echo "$cidr"
  done
fi
echo "Blocked successfully."
