#!/bin/sh

# -----------------------------------------------------------------------------
# Banner
#  [x] Device model
#  [x] Uptime
#  [x] CPU temp
#  [x] FQDN/hostname
#  [_] NIS domainname
#  [x] LAN IP
#  [x] WAN IP
#  [x] Freespace (RootFS)
#  [_] Weather (wttr.in)
#  [_] Custom banner entry
#  [_] Display DietPi useful commands?
#  [_] MOTD
#  [_] VPN status
#  [_] Large hostname
#  [_] Print credits
#  [_] Let's Encrypt cert status
# -----------------------------------------------------------------------------

BANNER_FILE="/boot/dietpi/.dietpi-banner"

cat > $BANNER_FILE << EOF
aDESCRIPTION[10]='Custom banner entry'
aENABLED[0]=1
aENABLED[1]=1
aENABLED[2]=1
aENABLED[3]=1
aENABLED[4]=0
aENABLED[5]=1
aENABLED[6]=1
aENABLED[7]=1
aENABLED[8]=0
aENABLED[9]=0
aENABLED[10]=0
aENABLED[11]=0
aENABLED[12]=0
aENABLED[13]=0
aENABLED[14]=0
aENABLED[15]=0
aENABLED[16]=0
aCOLOUR[0]='\e[38;5;154m'
aCOLOUR[1]='\e[1m'
aCOLOUR[2]='\e[90m'
aCOLOUR[3]='\e[91m'
EOF


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
