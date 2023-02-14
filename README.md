# Raspberry Pi and Pi-hole

<div align="center">
  <img src="https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/logo.png" alt="DietPi, Pi-hole, Unbound" style="width: 100%;" />
</div>

---

- [Overview](#-overview)
- [Install](#-install)
- [Configuration](#-configuration)
- [Finish](#-finish)

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

After completed flash the SD card open `dietpi.txt` from the card and change basic settings, for example:

```ini
# Language/Regional options
AUTO_SETUP_KEYBOARD_LAYOUT=us
AUTO_SETUP_TIMEZONE=Europe/Warsaw

# Network options
AUTO_SETUP_NET_USESTATIC=1
AUTO_SETUP_NET_STATIC_IP=192.168.0.3

# Disable HDMI/video output
AUTO_SETUP_HEADLESS=1

# Dependency preferences
AUTO_SETUP_WEB_SERVER_INDEX=-2  # Lighttpd

# Software to automatically install
AUTO_SETUP_AUTOMATED=1
AUTO_SETUP_INSTALL_SOFTWARE_ID=182  # Unbound
AUTO_SETUP_INSTALL_SOFTWARE_ID=87   # SQLite

# DietPi-Survey
SURVEY_OPTED_IN=0

# Serial Console
CONFIG_SERIAL_CONSOLE_ENABLE=0  # for correct auto-install

# IPv6
CONFIG_ENABLE_IPV6=0
```

Connect to your berry on the console:

```shell
ssh root@192.168.0.3
```

... and wait `(!)` to auto-install completed.

Also needed to install `Pi-hole` (now not support auto-install):

```shell
dietpi-software install 93
```

Use wizard and setup. After all is completed install `pihole-updatelists`:

```shell
wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash
```

---

## 🔹 Configuration

### Ad-lists

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

Recommended ad-lists:
- [DNS Blocklists](https://github.com/hagezi/dns-blocklists), see [included source lists](https://github.com/hagezi/dns-blocklists/blob/main/usedsources.md)
- [Regex Filters for Pi-hole](https://github.com/mmotti/pihole-regex), basic blacklist regex
- [Commonly White List](https://github.com/anudeepND/whitelist), basic whitelist

Personal ad-lists:
- [MajkiIT/polish-ads-filter](https://github.com/MajkiIT/polish-ads-filter), Polish Filters
- [Schakal Hosts](https://4pda.to/forum/index.php?showtopic=275091&st=8000#Spoil-89665467-4), RU-adlist

### Schedule

Update schedule timer for update ad-lists. For example, `every day at 4am`:

```shell
cat > /etc/cron.d/pihole-updatelists << EOF

0 4 * * *  root  /usr/local/sbin/pihole-updatelists

EOF
```

See [cron schedule expressions editor](https://crontab.guru/#0_4_*_*) for details.

---

## 🔹 Finish

Clear all preinstalled Pi-hole ad-lists and rules:

```shell
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist_by_group;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist_by_group;"
```

Update, upgrade system, all packages and ad-lists:

```shell
dietpi-update 1 && \
apt update -y && \
apt upgrade -y && \
apt dist-upgrade -y && \
apt autoremove -y --purge && \
apt autoclean -y && \
pihole -up && \
pihole-updatelists --update && \
pihole-updatelists && \
reboot
```
