#!/bin/bash

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

CONFIG_FILE="/boot/config.txt"

COLOR_GREY='\e[90m'
COLOR_RED='\e[31m'
COLOR_GREEN='\e[32m'
COLOR_YELLOW='\e[33m'
TEXT_BOLD=$(tput bold)
TEXT_RESET='\e[0m'

HEADER () {
  echo "${COLOR_GREEN}─────────────────────────────────────────────────────${TEXT_RESET}"
  echo "${COLOR_GREY}Post-Install : ${TEXT_BOLD}${COLOR_YELLOW}${1}${TEXT_RESET}"
  echo "${COLOR_GREEN}─────────────────────────────────────────────────────${TEXT_RESET}"
}

VALIDATION () {
  if [ $1 -gt 0 ]; then
    echo "${COLOR_GREY}Error message : ${TEXT_BOLD}${COLOR_RED}${1}${TEXT_RESET}"
    exit $1
  fi
}

BODY () {
  command=$1
  echo "${COLOR_GREY}[ Executing ] | ${COLOR_YELLOW}${command}${TEXT_RESET}"
  eval $command
  status=$?
  VALIDATION $status $1
}


# -----------------------------------------------------------------------------
# Dependencies
# -----------------------------------------------------------------------------

HEADER "Dependencies Installation"

# install pihole-updatelists
BODY "apt-get install php-cli php-sqlite3 php-intl php-curl"
BODY "wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash"


# -----------------------------------------------------------------------------
# Hardware
# -----------------------------------------------------------------------------

HEADER "Hardware Configuration"

# disable wireless
BODY "/boot/dietpi/func/dietpi-set_hardware bluetooth disable"
BODY "/boot/dietpi/func/dietpi-set_hardware wifimodules onboard_disable"

# disable buses
BODY "/boot/dietpi/func/dietpi-set_hardware i2c disable"
BODY "/boot/dietpi/func/dietpi-set_hardware spi disable"

# disable HDMI/video output
BODY "/boot/dietpi/func/dietpi-set_hardware headless enable"

# disable modules
BODY "/boot/dietpi/func/dietpi-set_hardware rpi-camera disable"
BODY "/boot/dietpi/func/dietpi-set_hardware rpi-codec disable"
BODY "/boot/dietpi/func/dietpi-set_hardware rpi-opengl disable"

# disable IPv6
BODY "/boot/dietpi/func/dietpi-set_hardware enableipv6 disable"


# -----------------------------------------------------------------------------
# Overclock
# -----------------------------------------------------------------------------

HEADER "Overclock Configuration"

# Profile - `energy saving`
BODY "sed -i \"/^#over_voltage=/c\over_voltage=-2\" $CONFIG_FILE"
BODY "sed -i \"/^over_voltage=/c\over_voltage=-2\" $CONFIG_FILE"
BODY "sed -i \"/^#over_voltage_min=/c\over_voltage_min=-2\" $CONFIG_FILE"
BODY "sed -i \"/^over_voltage_min=/c\over_voltage_min=-2\" $CONFIG_FILE"

# ARM Temp Limit - 65'C
BODY "sed -i \"/^#temp_limit=/c\temp_limit=65\" $CONFIG_FILE"
BODY "sed -i \"/^temp_limit=/c\temp_limit=65\" $CONFIG_FILE"

# ARM Idle Frequency - 300 Mhz
BODY "sed -i \"/^#arm_freq_min=/c\arm_freq_min=300\" $CONFIG_FILE"
BODY "sed -i \"/^arm_freq_min=/c\arm_freq_min=300\" $CONFIG_FILE"


# -----------------------------------------------------------------------------
# Pi-hole
# -----------------------------------------------------------------------------

HEADER "Pi-hole Configuration"

# clear all preinstalled Pi-hole ad-lists and rules
BODY "sqlite3 /etc/pihole/gravity.db \"DELETE FROM adlist;\""
BODY "sqlite3 /etc/pihole/gravity.db \"DELETE FROM adlist_by_group;\""
BODY "sqlite3 /etc/pihole/gravity.db \"DELETE FROM domainlist;\""
BODY "sqlite3 /etc/pihole/gravity.db \"DELETE FROM domainlist_by_group;\""

# set new ad-lists and rules
BODY "cat > /etc/pihole-updatelists.conf <<EOF
ADLISTS_URL=\"https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/adlist.txt\"
WHITELIST_URL=\"https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist.txt\"
REGEX_WHITELIST_URL=\"https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist_regex.txt\"
BLACKLIST_URL=\"https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist.txt\"
REGEX_BLACKLIST_URL=\"https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist_regex.txt https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile_regex.txt\"
EOF"

# timer for update ad-lists, ex. every day at 4am
# https://crontab.guru/#0_4_*_*
BODY "cat > /etc/cron.d/pihole-updatelists <<EOF
0 4 * * *  root  /usr/local/sbin/pihole-updatelists
EOF"

# update ad-lists and rules
BODY "pihole-updatelists"
