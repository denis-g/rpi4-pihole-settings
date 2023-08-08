# Raspberry Pi and Pi-hole

<div align="center">
  <img src="https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/logo.png" alt="DietPi, Pi-hole, Unbound" style="width: 100%;" />
</div>

---

- [Overview](#-overview)
- [Install](#-install)
- [Configuration](#-ad-lists)
- [Finish](#-update)

---

## 🔹 Overview

Basic Raspberry Pi 4 on DietPi with Pi-hole and Unbound for more privacy.

Ingredients:

> **[DietPi](https://github.com/MichaIng/DietPi)**: DietPi is an extremely lightweight Debian-based OS. It is highly optimised for minimal CPU and RAM resource usage, ensuring your SBC always runs at its maximum potential.

> **[Pi-hole](https://docs.pi-hole.net/)**: Pi-hole is a DNS sinkhole that protects your devices from unwanted content without installing any client-side software.

> **[pihole-updatelists](https://github.com/jacklul/pihole-updatelists)**: Update Pi-hole's lists from remote sources.

> **[Unbound](https://unbound.docs.nlnetlabs.nl/en/latest/)**: Unbound is a validating, recursive, caching DNS resolver. It is designed to be fast and lean and incorporates modern features based on open standards.

---

## 🔹 Install

See `DietPi` install guide [here](https://dietpi.com/docs/install/).

After completed flash the SD card open `dietpi.txt` from the card and change basic settings for auto-configuration.

> ⚠️ This config applied on first boot of DietPi only!

Example modified settings:

```ini
# -----------------------------------------------------------------------------
# Language/Regional options
# -----------------------------------------------------------------------------

AUTO_SETUP_KEYBOARD_LAYOUT=us
AUTO_SETUP_TIMEZONE=Europe/Warsaw

# -----------------------------------------------------------------------------
# Network options
# -----------------------------------------------------------------------------

# static network
AUTO_SETUP_NET_USESTATIC=1
AUTO_SETUP_NET_STATIC_IP=192.168.0.2

AUTO_SETUP_NET_HOSTNAME=raspberrypi-eth

# -----------------------------------------------------------------------------
# Misc options
# -----------------------------------------------------------------------------

# disable swap
AUTO_SETUP_SWAPFILE_SIZE=0

# disable HDMI/video output and framebuffers
AUTO_SETUP_HEADLESS=1

# post-install and configuration
AUTO_SETUP_CUSTOM_SCRIPT_EXEC=https://github.com/denis-g/rpi4-pihole-settings/blob/master/dietpi-install.sh

# -----------------------------------------------------------------------------
# Software options
# -----------------------------------------------------------------------------

# dependency preferences
AUTO_SETUP_WEB_SERVER_INDEX=-2  # Lighttpd

# software to automatically install
AUTO_SETUP_AUTOMATED=1

# global password
AUTO_SETUP_GLOBAL_PASSWORD=dietpi

# software to automatically install
AUTO_SETUP_INSTALL_SOFTWARE_ID=182  # Unbound
AUTO_SETUP_INSTALL_SOFTWARE_ID=87   # SQLite

# -----------------------------------------------------------------------------
# Misc DietPi program settings
# -----------------------------------------------------------------------------

# disable obtain information regarding your system and installed software
SURVEY_OPTED_IN=0

# -----------------------------------------------------------------------------
# DietPi-Config settings
# -----------------------------------------------------------------------------

# CPU Governor
CONFIG_CPU_GOVERNOR=powersave

# disable IPv6
CONFIG_ENABLE_IPV6=0

# for correct auto-install
CONFIG_SERIAL_CONSOLE_ENABLE=0
```

For additional installation and configuration see `dietpi-install.sh` file.

---

Connect to your berry on the console with global password:

```shell
ssh dietpi@192.168.0.2
```

... and wait `(!)` to auto-install completed.

---

## 🔹 Ad-lists

Recommended ad-lists:
- [DNS Blocklists](https://github.com/hagezi/dns-blocklists), see [included source lists](https://github.com/hagezi/dns-blocklists/blob/main/usedsources.md)
- [Regex Filters for Pi-hole](https://github.com/mmotti/pihole-regex), basic blacklist regex
- [Commonly White List](https://github.com/anudeepND/whitelist), basic whitelist

Personal ad-lists:
- [MajkiIT/polish-ads-filter](https://github.com/MajkiIT/polish-ads-filter), Polish Filters
- [Schakal Hosts](https://4pda.to/forum/index.php?showtopic=275091&st=8000#Spoil-89665467-4), RU-adlist

---

## 🔹 Update

Update, upgrade system, all packages and ad-lists:

```shell
sudo dietpi-update 1 && \
sudo apt update -y && \
sudo apt upgrade -y && \
sudo apt dist-upgrade -y && \
pihole -up && \
sudo pihole-updatelists --update && \
sudo pihole-updatelists && \
sudo reboot
```
