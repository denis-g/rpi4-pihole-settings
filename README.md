# Raspberry Pi and Pi-Hole

<div align="center">
  <img src="https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/logo.png" alt="DietPi, Pi-hole, Unbound" style="width: 100%;" />
</div>

---

- [Overview](#-overview)
- [Install DietPi](#-install-dietpi)
- [Prepare Pi-Hole](#-prepare-pi-hole)
- [Update](#-update)

---

## 🔹 Overview

Basic Raspberry Pi on DietPi with Pi-Hole and Unbound for more privacy.

Ingredients:

> **[DietPi](https://github.com/MichaIng/DietPi)**: DietPi is an extremely lightweight Debian-based OS. It is highly optimised for minimal CPU and RAM resource usage, ensuring your SBC always runs at its maximum potential.

> **[Pi-Hole](https://docs.pi-hole.net/)**: Pi-Hole is a DNS sinkhole that protects your devices from unwanted content without installing any client-side software.

> **[pihole-updatelists](https://github.com/jacklul/pihole-updatelists)**: Update Pi-Hole's lists from remote sources.

> **[Unbound](https://unbound.docs.nlnetlabs.nl/en/latest/)**: Unbound is a validating, recursive, caching DNS resolver. It is designed to be fast and lean and incorporates modern features based on open standards.

---

## 🔹 Install DietPi

See `DietPi` install guide [here](https://dietpi.com/docs/install/).

After completed flash the SD card open `dietpi.txt` from the card and change basic settings for auto-configuration.

> ⚠️ This config applied on first boot of DietPi only!

Modified settings example:

```ini
# -----------------------------------------------------------------------------
# Language/Regional options
# -----------------------------------------------------------------------------

AUTO_SETUP_KEYBOARD_LAYOUT=us
AUTO_SETUP_TIMEZONE=Europe/Warsaw

# -----------------------------------------------------------------------------
# Network options
# -----------------------------------------------------------------------------

AUTO_SETUP_NET_USESTATIC=1
AUTO_SETUP_NET_STATIC_IP=192.168.50.5
AUTO_SETUP_NET_STATIC_GATEWAY=192.168.50.1

AUTO_SETUP_NET_HOSTNAME=raspberrypi-eth

# -----------------------------------------------------------------------------
# Misc options
# -----------------------------------------------------------------------------

# disable swap
AUTO_SETUP_SWAPFILE_SIZE=0

# disable HDMI/video output and framebuffers
AUTO_SETUP_HEADLESS=1

# post-install and configuration
AUTO_SETUP_CUSTOM_SCRIPT_EXEC=https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/dietpi-postinstall.sh

# -----------------------------------------------------------------------------
# Software options
# -----------------------------------------------------------------------------

# software to automatically install
AUTO_SETUP_AUTOMATED=1

# global password [!]
AUTO_SETUP_GLOBAL_PASSWORD=password

# software to automatically install
# Git
AUTO_SETUP_INSTALL_SOFTWARE_ID=17
# SQLite, PHP
AUTO_SETUP_INSTALL_SOFTWARE_ID=87 89
# Unbound
AUTO_SETUP_INSTALL_SOFTWARE_ID=182

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
```

Also for additional configuration see [dietpi-install.sh](https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/dietpi-postinstall.sh) file.

---

Connect to your berry on the console with global password:

```shell
ssh root@192.168.50.5
```

... and wait `[!]` few minutes to install and update completed.

---

## 🔹 Prepare Pi-Hole

> Currently, Pi-Hole doesn't support auto-install.

Run this for execute Pi-Hole installation wizard:

```shell
dietpi-software install 93
```

Setup and set custom DNS server (Unbound):

```ini
127.0.0.1#5335
```

After all is completed – update Pi-Hole settings by default:

```shell
pihole-FTL --config database.maxDBdays 91
```

And install `pihole-updatelists` for import and auto-update lists and rules:

```shell
wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash
```

### Block Lists And Rules

Recommended block lists and rules repositories:
- [DNS Blocklists](https://github.com/hagezi/dns-blocklists) – see [included source lists](https://github.com/hagezi/dns-blocklists/blob/main/sources.md)
- [Regex Filters for Pi-Hole](https://github.com/mmotti/pihole-regex) – basic blacklist regex

Set your personal lists on config file:

```shell
cat > /etc/pihole-updatelists.conf << EOF
BLOCKLISTS_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/rules/blocklists.txt"
ALLOWLISTS_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/rules/allowlists.txt"
WHITELIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/rules/whitelist.txt"
REGEX_WHITELIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/rules/whitelist_regex.txt"
BLACKLIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/rules/blacklist.txt"
REGEX_BLACKLIST_URL="https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/rules/blacklist_regex.txt https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile_regex.txt"
EOF
```

Clear all preinstalled Pi-Hole lists and rules:

```shell
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist_by_group;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist_by_group;"
```

And update lists and rules on `Pi-Hole`:

```shell
pihole-updatelists
```

### Schedule

Set schedule timer for update all lists. For example, `every day at 4am`:

```shell
cat > /etc/cron.d/pihole-updatelists << EOF
0 4 * * *  root  /usr/local/sbin/pihole-updatelists
EOF
```

See [cron schedule expressions editor](https://crontab.guru/#0_4_*_*) for details.

---

## 🔹 Update

Update, upgrade system, all packages, lists and rules:

```shell
pihole-updatelists --update -y && \
pihole-updatelists && \
pihole -up && \
dietpi-update 1 && \
apt-get update -y && \
apt-get upgrade -y && \
apt-get dist-upgrade -y
```
