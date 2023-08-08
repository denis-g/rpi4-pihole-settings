#!/bin/bash

CONFIG_FILE="/boot/config.txt"


# -----------------------------------------------------------------------------
# Dependencies
# -----------------------------------------------------------------------------

# install pihole-updatelists
apt install php-cli php-sqlite3 php-intl php-curl -y
wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash


# -----------------------------------------------------------------------------
# Hardware
# -----------------------------------------------------------------------------

# disable wireless
/boot/dietpi/func/dietpi-set_hardware bluetooth disable
/boot/dietpi/func/dietpi-set_hardware wifimodules onboard_disable

# disable buses
/boot/dietpi/func/dietpi-set_hardware i2c disable
/boot/dietpi/func/dietpi-set_hardware spi disable

# disable HDMI/video output
/boot/dietpi/func/dietpi-set_hardware headless enable

# disable modules
/boot/dietpi/func/dietpi-set_hardware rpi-camera disable
/boot/dietpi/func/dietpi-set_hardware rpi-codec disable
/boot/dietpi/func/dietpi-set_hardware rpi-opengl disable

# disable IPv6
/boot/dietpi/func/dietpi-set_hardware enableipv6 disable


# -----------------------------------------------------------------------------
# Overclock
# -----------------------------------------------------------------------------

# Profile - `energy saving`
sed -i "/^#over_voltage=/c\over_voltage=-2" $CONFIG_FILE
sed -i "/^over_voltage=/c\over_voltage=-2" $CONFIG_FILE
sed -i "/^#over_voltage_min=/c\over_voltage_min=-2" $CONFIG_FILE
sed -i "/^over_voltage_min=/c\over_voltage_min=-2" $CONFIG_FILE

# ARM Temp Limit - 65'C
sed -i "/^#temp_limit=/c\temp_limit=65" $CONFIG_FILE
sed -i "/^temp_limit=/c\temp_limit=65" $CONFIG_FILE

# ARM Idle Frequency - 300 Mhz
sed -i "/^#arm_freq_min=/c\arm_freq_min=300" $CONFIG_FILE
sed -i "/^arm_freq_min=/c\arm_freq_min=300" $CONFIG_FILE


# -----------------------------------------------------------------------------
# Pi-hole
# -----------------------------------------------------------------------------

# clear all preinstalled Pi-hole ad-lists and rules
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist;"
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist_by_group;"
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist;"
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist_by_group;"

# set new ad-lists and rules
cat << '_EOF_' > "/etc/pihole-updatelists.conf"
ADLISTS_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/adlist.txt"
WHITELIST_URL="https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist.txt"
REGEX_WHITELIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist_regex.txt"
BLACKLIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist.txt"
REGEX_BLACKLIST_URL="https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist_regex.txt https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile_regex.txt"
_EOF_

# timer for update ad-lists, ex. every day at 4am
# https://crontab.guru/#0_4_*_*
cat << '_EOF_' > "/etc/cron.d/pihole-updatelists"
0 4 * * *  root  /usr/local/sbin/pihole-updatelists
_EOF_

# update ad-lists and rules
pihole-updatelists
