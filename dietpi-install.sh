#!/bin/sh


# -----------------------------------------------------------------------------
# Banner
# -----------------------------------------------------------------------------

BANNER_FILE="/boot/dietpi/.dietpi-banner"

# Device model
sed -i "/^aENABLED\[0\]=/c\aENABLED\[0\]=1" $BANNER_FILE
# Uptime
sed -i "/^aENABLED\[1\]=/c\aENABLED\[1\]=1" $BANNER_FILE
# CPU temp
sed -i "/^aENABLED\[2\]=/c\aENABLED\[2\]=1" $BANNER_FILE
# FQDN/hostname
sed -i "/^aENABLED\[3\]=/c\aENABLED\[3\]=1" $BANNER_FILE
# NIS domainname
sed -i "/^aENABLED\[4\]=/c\aENABLED\[4\]=0" $BANNER_FILE
# LAN IP
sed -i "/^aENABLED\[5\]=/c\aENABLED\[5\]=1" $BANNER_FILE
# WAN IP
sed -i "/^aENABLED\[6\]=/c\aENABLED\[6\]=1" $BANNER_FILE
# Freespace (RootFS)
sed -i "/^aENABLED\[7\]=/c\aENABLED\[7\]=1" $BANNER_FILE
# Freespace (userdata)
sed -i "/^aENABLED\[8\]=/c\aENABLED\[8\]=0" $BANNER_FILE
# Weather (wttr.in)
sed -i "/^aENABLED\[9\]=/c\aENABLED\[9\]=0" $BANNER_FILE
# Custom banner entry
sed -i "/^aENABLED\[10\]=/c\aENABLED\[10\]=0" $BANNER_FILE
# Display DietPi useful commands?
sed -i "/^aENABLED\[11\]=/c\aENABLED\[11\]=0" $BANNER_FILE
# MOTD
sed -i "/^aENABLED\[12\]=/c\aENABLED\[12\]=0" $BANNER_FILE
# VPN status
sed -i "/^aENABLED\[13\]=/c\aENABLED\[13\]=0" $BANNER_FILE
# Large hostname
sed -i "/^aENABLED\[14\]=/c\aENABLED\[14\]=0" $BANNER_FILE
# Print credits
sed -i "/^aENABLED\[15\]=/c\aENABLED\[15\]=0" $BANNER_FILE
# Let's Encrypt cert status
sed -i "/^aENABLED\[16\]=/c\aENABLED\[16\]=0" $BANNER_FILE


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

CONFIG_FILE="/boot/config.txt"

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
