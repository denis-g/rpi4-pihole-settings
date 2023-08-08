# Raspberry Pi and Pi-hole

<div align="center">
  <img src="https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/logo.png" alt="DietPi, Pi-hole, Unbound" style="width: 100%;" />
</div>

---

- [Overview](#-overview)
- [Install DietPi](#-install-dietpi)
- [Install Pi-hole](#-install-pi-hole)
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

## 🔹 Install DietPi

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

AUTO_SETUP_NET_USESTATIC=1
AUTO_SETUP_NET_STATIC_IP=192.168.50.2
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
AUTO_SETUP_CUSTOM_SCRIPT_EXEC=https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/dietpi-install.sh

# -----------------------------------------------------------------------------
# Software options
# -----------------------------------------------------------------------------

# dependency preferences
# Lighttpd
AUTO_SETUP_WEB_SERVER_INDEX=-2

# software to automatically install
AUTO_SETUP_AUTOMATED=1

# global password [!]
AUTO_SETUP_GLOBAL_PASSWORD=password

# software to automatically install
# Lighttpd
AUTO_SETUP_INSTALL_SOFTWARE_ID=84
# SQLite
AUTO_SETUP_INSTALL_SOFTWARE_ID=87
# PHP
AUTO_SETUP_INSTALL_SOFTWARE_ID=89
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

> Now `Pi-hole` not support auto-install.

Also for additional configuration see `dietpi-install.sh` file.

---

Connect to your berry on the console with global password:

```shell
ssh root@192.168.50.2
```

... and wait `[!]` few minutes to auto-install completed.

---

## 🔹 Install Pi-hole

Run this for execute `Pi-hole` installation wizard:

```shell
dietpi-software install 93
```

After all is completed install `pihole-updatelists`:

```shell
wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash
```

### Ad-lists

Recommended ad-lists:
- [DNS Blocklists](https://github.com/hagezi/dns-blocklists), see [included source lists](https://github.com/hagezi/dns-blocklists/blob/main/usedsources.md)
- [Regex Filters for Pi-hole](https://github.com/mmotti/pihole-regex), basic blacklist regex
- [Commonly White List](https://github.com/anudeepND/whitelist), basic whitelist

Personal ad-lists:
- [MajkiIT/polish-ads-filter](https://github.com/MajkiIT/polish-ads-filter), Polish Filters
- [Schakal Hosts](https://4pda.to/forum/index.php?showtopic=275091&st=8000#Spoil-89665467-4), RU-adlist

Set your personal ad-lists on config file:

```shell
cat > /etc/pihole-updatelists.conf << EOF
ADLISTS_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/adlist.txt"
WHITELIST_URL="https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist.txt"
REGEX_WHITELIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist_regex.txt"
BLACKLIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist.txt"
REGEX_BLACKLIST_URL="https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist_regex.txt https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile_regex.txt"
EOF
```

Clear all preinstalled Pi-hole ad-lists and rules:

```shell
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist_by_group;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist_by_group;"
```

And update ad-lists and rules on `Pi-hole`:

```shell
pihole-updatelists
```

### Update Schedule

Set schedule timer for update ad-lists. For example, `every day at 4am`:

```shell
cat > /etc/cron.d/pihole-updatelists << EOF
0 4 * * *  root  /usr/local/sbin/pihole-updatelists
EOF
```

See [cron schedule expressions editor](https://crontab.guru/#0_4_*_*) for details.

---

## 🔹 Update

Update, upgrade system, all packages and ad-lists:

```shell
dietpi-update 1 && \
apt-get update -y && \
apt-get upgrade -y && \
apt-get dist-upgrade -y && \
pihole -up && \
pihole-updatelists --update && \
pihole-updatelists && \
reboot
```
