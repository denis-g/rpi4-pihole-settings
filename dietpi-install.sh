#!/bin/sh

CONFIG_FILE="/boot/config.txt"


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
