#!/bin/bash

CONFIG="/boot/config.txt"

# -----------------------------------------------------------------------------
# Hardware
# -----------------------------------------------------------------------------

banner "Hardware configuration..."

# disable wireless
exec "/boot/dietpi/func/dietpi-set_hardware bluetooth disable"
exec "/boot/dietpi/func/dietpi-set_hardware wifimodules onboard_disable"

# disable buses
exec "/boot/dietpi/func/dietpi-set_hardware i2c disable"
exec "/boot/dietpi/func/dietpi-set_hardware spi disable"

# disable HDMI/video output
exec "/boot/dietpi/func/dietpi-set_hardware headless enable"

# disable modules
exec "/boot/dietpi/func/dietpi-set_hardware rpi-camera disable"
exec "/boot/dietpi/func/dietpi-set_hardware rpi-codec disable"
exec "/boot/dietpi/func/dietpi-set_hardware rpi-opengl disable"

# disable IPv6
exec "/boot/dietpi/func/dietpi-set_hardware enableipv6 disable"


# -----------------------------------------------------------------------------
# Overclock
# -----------------------------------------------------------------------------

banner "Overclock configuration..."

# Profile - `energy saving`
exec "sed -i \"/^#over_voltage=/c\over_voltage=-2\" $CONFIG"
exec "sed -i \"/^over_voltage=/c\over_voltage=-2\" $CONFIG"
exec "sed -i \"/^#over_voltage_min=/c\over_voltage_min=-2\" $CONFIG"
exec "sed -i \"/^over_voltage_min=/c\over_voltage_min=-2\" $CONFIG"

# ARM Temp Limit - 65'C
exec "sed -i \"/^#temp_limit=/c\temp_limit=65\" $CONFIG"
exec "sed -i \"/^temp_limit=/c\temp_limit=65\" $CONFIG"

# ARM Idle Frequency - 300 Mhz
exec "sed -i \"/^#arm_freq_min=/c\arm_freq_min=300\" $CONFIG"
exec "sed -i \"/^arm_freq_min=/c\arm_freq_min=300\" $CONFIG"


# -----------------------------------------------------------------------------
# Dependencies
# -----------------------------------------------------------------------------

banner "Dependencies installation..."

# install Pi-hole (now not support auto-install)
exec "dietpi-software install 93"

# install pihole-updatelists
exec "wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash"


# -----------------------------------------------------------------------------
# Pi-hole
# -----------------------------------------------------------------------------

banner "Pi-hole configuration..."

# clear all preinstalled Pi-hole ad-lists and rules
exec "sqlite3 /etc/pihole/gravity.db \"DELETE FROM adlist;\""
exec "sqlite3 /etc/pihole/gravity.db \"DELETE FROM adlist_by_group;\""
exec "sqlite3 /etc/pihole/gravity.db \"DELETE FROM domainlist;\""
exec "sqlite3 /etc/pihole/gravity.db \"DELETE FROM domainlist_by_group;\""

# set new ad-lists and rules
exec "cat > /etc/pihole-updatelists.conf <<EOF
ADLISTS_URL=\"https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/adlist.txt\"
WHITELIST_URL=\"https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist.txt\"
REGEX_WHITELIST_URL=\"https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist_regex.txt\"
BLACKLIST_URL=\"https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist.txt\"
REGEX_BLACKLIST_URL=\"https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist_regex.txt https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile_regex.txt\"
EOF"

# update ad-lists and rules
exec "pihole-updatelists"


# -----------------------------------------------------------------------------
# Schedule
# -----------------------------------------------------------------------------

banner "Schedule configuration..."

# timer for update ad-lists, ex. every day at 4am
# https://crontab.guru/#0_4_*_*
exec "cat > /etc/cron.d/pihole-updatelists <<EOF
0 4 * * *  root  /usr/local/sbin/pihole-updatelists
EOF"


# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

banner () {
  title=`echo $1 | tr 'a-z' 'A-Z'`
  echo ""
  echo "||"
  echo "||  Running \"${BOLD}${YELLOW}${title}${NORMAL}\""
  echo "||"
  echo ""
}

check_error () {
  if [ $1 -gt 0 ]; then
    log "Failed in \"${BOLD}${RED}${2}${NORMAL}\""
    echo ""
    echo "||"
    echo "||  ${BOLD}${RED}ERROR ${1}${NORMAL}"
    echo "||"
    echo ""
    exit $1
  fi
}

log () {
  echo "--> $1"
}

body () {
  command=$1
  log "Executing \"${CYAN}${command}${NORMAL}\""
  eval $command
  status=$?
  check_error $status $1
}
