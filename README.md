# Raspberry Pi and Pi-hole

<div align="center">
  <img src="https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/dietpi.png" alt="DietPi" style="width: auto; height: 200px;" />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/pihole.svg" alt="Pi-hole" style="width: auto; height: 200px;" />
</div>

---

- [Overview](#-overview)
- [Install](#-install)
- [Configuration](#-configuration)
- [Finish](#-finish)

---

## 🔹 Overview

Basic setup `Pi-hole` on Raspberry Pi with powerful ad-block utils.

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
AUTO_SETUP_NET_STATIC_DNS=1.1.1.1 1.0.0.1
AUTO_SETUP_DHCP_TO_STATIC=1

# Disable HDMI/video output
AUTO_SETUP_HEADLESS=1

# Dependency preferences
# Lighttpd
AUTO_SETUP_WEB_SERVER_INDEX=-2

# IPv6
CONFIG_ENABLE_IPV6=0
```

Connect to your berry on console and wait to auto-install completed.

```shell
ssh root@192.168.0.3
```

Use wizard and set up. After launch `DietPi-Software` select `Search Software`, find and check:
- [Pi-hole](https://dietpi.com/docs/software/dns_servers/#pi-hole)
- [Unbound](https://dietpi.com/docs/software/dns_servers/#unbound)
- [SQLite](https://dietpi.com/docs/software/databases/#sqlite)

And select `Install`.

Install `pihole-updatelists`:

```shell
wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash
```

---

## 🔹 Configuration

Set new personal lists:

```shell
nano /etc/pihole-updatelists.conf
```

```ini
ADLISTS_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/adlist.txt"
WHITELIST_URL="https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist.txt"
REGEX_WHITELIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist_regex.txt"
BLACKLIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist.txt"
REGEX_BLACKLIST_URL="https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist_regex.txt https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile_regex.txt"
```

Recommended lists:
- [DNS Blocklists](https://github.com/hagezi/dns-blocklists), see [included source lists](https://github.com/hagezi/dns-blocklists/blob/main/usedsources.md)
- [Regex Filters for Pi-hole](https://github.com/mmotti/pihole-regex), basic blacklist regex
- [Commonly White List](https://github.com/anudeepND/whitelist), basic whitelist

Personal lists:
- [MajkiIT/polish-ads-filter](https://github.com/MajkiIT/polish-ads-filter), Polish Filters
- [Schakal Hosts](https://4pda.to/forum/index.php?showtopic=275091&st=8000#Spoil-89665467-4), RU-adlist

For update lists and rules use:

```shell
pihole-updatelists
```

For check domain available and see the lists for a specified domain use:

```shell
pihole -q example.com
```

---

## 🔹 Finish

Clear all preinstalled Pi-hole lists and rules:

```shell
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type=0;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type=1;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type=2;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type=3;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist WHERE enabled=0;"  && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist WHERE enabled=1;"
```

<details><summary>Legend:</summary>

```ini
domainlist type=0 # whitelist
domainlist type=1 # blacklist
domainlist type=2 # regex whitelist
domainlist type=3 # regex blacklist
adlist enabled=0  # disabled adlists
adlist enabled=1  # enabled adlists
```

</details>

Update and upgrade all system:

```shell
apt update -y && \
apt upgrade -y && \
apt autoremove -y --purge && \
apt autoclean -y && \
rpi-update && \
pihole -up && \
pihole-updatelists --update && \
pihole-updatelists && \
reboot
```
