# Raspberry Pi 4 and Pi-hole settings

<div align="center">
  <p><img src="https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/pihole.svg" alt="Pi-hole" style="width: 40%;" /></p>
</div>

---

- [Raspberry Pi OS Lite](#-raspberry-pi-os-lite)
- [log2ram](#-log2ram)
- [Pi-hole](#-pi-hole)
- [pihole-updatelists](#-pihole-updatelists)
- [unbound](#-unbound) or [DNSCrypt](#-dnscrypt)
- [Update system and lists](#-update-system-and-lists)

---

## 🔹 Raspberry Pi OS Lite

Raspberry PI OS Lite is a minimal operating system. It fits the needs of a very light OS with a minimal set of packages. It is suggested only for experienced people able to use ssh connections and remote management with a Command Line Interface (CLI), without Graphical interfaces or Desktop Environment.

See [details](https://www.raspberrypi.com/software/operating-systems/).

### Install

Download and install [Raspberry Pi Imager](https://www.raspberrypi.com/software/):

- Select **Raspberry Pi OS Lite**
- Select storage
- Click `Settings` and set up
  - [x] Disable overscan
  - [x] Set hostname
  - [x] Enable SSH
  - [x] Set username and password
  - [ ] Configure wifi
  - [x] Set locale settings
  - [ ] Play sound when finished
  - [x] Eject media when finished
  - [ ] Enable telemetry
- Click `Write`

### Configuration

Connect to your device:

```shell
ssh username@raspberrypi.local
```

Set up Raspberry Pi OS:

```shell
sudo raspi-config
```

- set locale as `en_US.UTF-8 UTF-8`

Disable all interfaces, sound, and video:

```shell
sudo nano /boot/config.txt
```

```ini
# Enable audio (loads snd_bcm2835)
dtparam=audio=off

# Automatically load overlays for detected cameras
camera_auto_detect=0

# Automatically load overlays for detected DSI displays
display_auto_detect=0

# WiFi and Bluetooth
dtoverlay=disable-wifi
dtoverlay=disable-bt

# HDMI
# On the Raspberry Pi 4, setting hdmi_blanking=1 will not cause the HDMI output to be switched off,
# since this feature has not yet been implemented
hdmi_blanking=1
max_framebuffers=0

# RAM to the CPU, only for console using
gpu_mem=1

```

Disable IPv6:

```shell
sudo nano /etc/sysctl.conf
```

```ini
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.wlan0.disable_ipv6 = 1
```

---

## 🔹 log2ram

Useful for Raspberry Pi for not writing on the SD card all the time.

See [details](https://github.com/azlux/log2ram).

### Install

```shell
sudo apt -y install rsync
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
sudo apt update
sudo apt -y install log2ram
```

### Configuration

For generates many logs (like a Pi-hole), you needed to increasing this to a larger amount, such as 256M.

```shell
sudo nano /etc/log2ram.conf
```

```ini
SIZE=256M
```

Deletion of old "archived" logs can be fixed by adjusting a setting:

```shell
sudo nano /etc/systemd/journald.conf
```

```ini
SystemMaxUse=20M
```

---

## 🔹 Pi-hole

The Pi-hole is a DNS sinkhole that protects your devices from unwanted content without installing any client-side software.

See [details](https://docs.pi-hole.net/).

### Install

```shell
curl -sSL https://install.pi-hole.net | sudo bash
```

### Configuration

Use wizard and set up.

---

## 🔹 pihole-updatelists

Update Pi-hole's lists from remote sources.

See [details](https://github.com/jacklul/pihole-updatelists).

### Install

```shell
sudo apt -y install php-cli sqlite3 php-sqlite3 php-intl php-curl
wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash
```

### Configuration

Clear all preinstalled Pi-hole lists and rules:

```shell
sudo sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type=0;" # whitelist
sudo sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type=1;" # blacklist
sudo sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type=2;" # regex whitelist
sudo sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist WHERE type=3;" # regex blacklist
sudo sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist WHERE enabled=0;"  # disabled adlists
sudo sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist WHERE enabled=1;"  # enabled adlists
```

Set new personal lists:

```shell
sudo nano /etc/pihole-updatelists.conf
```

```ini
ADLISTS_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/adlist.txt"
WHITELIST_URL="https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist.txt"
REGEX_WHITELIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/whitelist_regex.txt"
BLACKLIST_URL="https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist.txt"
REGEX_BLACKLIST_URL="https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list https://raw.githubusercontent.com/denis-g/rpi4-pihole-settings/master/blacklist_regex.txt https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile_regex.txt https://perflyst.github.io/PiHoleBlocklist/regex.list"
```

For update lists and rules use:

```shell
sudo pihole-updatelists
```

Recommended lists:
- [DNS Blocklists](https://github.com/hagezi/dns-blocklists), see [included source lists](https://github.com/hagezi/dns-blocklists/blob/main/usedsources.md)
- [Regex Filters for Pi-hole](https://github.com/mmotti/pihole-regex), basic blacklist regex
- [PiHole and AGH Blocklists](https://github.com/Perflyst/PiHoleBlocklist), Smart TV blacklist and regex
- [Commonly White List](https://github.com/anudeepND/whitelist), basic whitelist

Personal lists:
- [MajkiIT/polish-ads-filter](https://github.com/MajkiIT/polish-ads-filter), Polish Filters
- [Schakal Hosts](https://4pda.to/forum/index.php?showtopic=275091&st=8000#Spoil-89665467-4), RU-adlist


For check domain available and see the lists for a specified domain use:

```shell
pihole -q example.com
```

---

## 🔹 unbound

> This is alternative for [DNSCrypt](#-dnscrypt) with current config, don't use both.

Unbound is a validating, recursive, caching DNS resolver. It is designed to be fast and lean and incorporates modern features based on open standards.

See [details](https://unbound.docs.nlnetlabs.nl/en/latest/).

### Install

```shell
sudo apt -y install unbound
```

### Configuration

More information about settings see on official [Pi-hole](https://docs.pi-hole.net/guides/dns/unbound/) and [unbound](https://nlnetlabs.nl/documentation/unbound/unbound.conf/) documentation.

Create new config:

```shell
sudo nano /etc/unbound/unbound.conf.d/pi-hole.conf
```

```ini
server:
    interface: 127.0.0.1
    port: 5533

    # BASIC SETTINGS
    cache-min-ttl: 60
    do-ip6: no
    use-caps-for-id: no

    # LOGGING
    verbosity: 0

    # PRIVACY SETTINGS
    aggressive-nsec: yes
    delay-close: 10000
    do-not-query-localhost: no
    neg-cache-size: 4M

    # SECURITY SETTINGS
    access-control: 127.0.0.1/32 allow
    access-control: 192.168.0.0/16 allow
    access-control: 172.16.0.0/12 allow
    access-control: 10.0.0.0/8 allow
    harden-algo-downgrade: yes
    harden-large-queries: yes
    hide-identity: yes
    hide-version: yes
    identity: "DNS"
    private-address: 10.0.0.0/8
    private-address: 172.16.0.0/12
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt
    unwanted-reply-threshold: 10000000
    val-clean-additional: yes

    # PERFORMANCE SETTINGS
    msg-cache-size: 260991658
    num-queries-per-thread: 4096
    outgoing-range: 8192
    rrset-cache-size: 260991658
    prefetch: yes
    prefetch-key: yes
    serve-expired: yes
    so-rcvbuf: 1m

forward-zone:
    name: "."
    forward-tls-upstream: yes
    forward-addr: 9.9.9.9@853#dns.quad9.net
    forward-addr: 149.112.112.112@953#dns.quad9.net
    forward-addr: 1.1.1.1@853#cloudflare-dns.com
    forward-addr: 1.0.0.1@853#cloudflare-dns.com
```

Set `unbound` as custom DNS server on Pi-hole admin panel `Settings > DNS`:

![Enable custom DNS server](https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/custom-dns.png)

And enable DNSSEC on `Advanced DNS settings`:

![Enable DNSSEC](https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/enable-dnssec.png)

Apply config and restart service:

```shell
sudo service unbound restart
sudo systemctl restart pihole-FTL
```

> To ensure the bootstrap is your DNS server you must redirect or block standard DNS port (TCP/UDP 53) and block all DOT (TCP 853) port.

---

## 🔹 DNSCrypt

> This is alternative for [unbound](#-unbound) with current config, don't use both.

A flexible DNS proxy, with support for modern encrypted DNS protocols such as DNSCrypt v2, DNS-over-HTTPS, Anonymized DNSCrypt and ODoH (Oblivious DoH).

See [details](https://github.com/DNSCrypt/dnscrypt-proxy).

### Install

Copy URL to latest **ARM** release from [this page](https://github.com/DNSCrypt/dnscrypt-proxy/releases):

```shell
sudo wget https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.2/dnscrypt-proxy-linux_arm-2.1.2.tar.gz
sudo tar -xvzf ./dnscrypt-proxy-linux_arm-2.1.2.tar.gz
sudo rm dnscrypt-proxy-linux_arm-2.1.2.tar.gz

sudo mv ./linux-arm ./dnscrypt-proxy
sudo cp ./dnscrypt-proxy/example-dnscrypt-proxy.toml ./dnscrypt-proxy/dnscrypt-proxy.toml
```

### Configuration

Set servers and port for service:

```shell
sudo nano ./dnscrypt-proxy/dnscrypt-proxy.toml
```

```ini
server_names = ['cloudflare-family', 'cloudflare']

# don't use 53 or 5353 port
listen_addresses = ['127.0.0.1:5533']
```

Install and start service:

```shell
sudo ./dnscrypt-proxy/dnscrypt-proxy -service install
sudo ./dnscrypt-proxy/dnscrypt-proxy -service start
```

Set `DNSCrypt` as custom DNS server on Pi-hole admin panel `Settings > DNS`:

![Enable custom DNS server](https://github.com/denis-g/rpi4-pihole-settings/blob/master/assets/custom-dns.png)

> To ensure the bootstrap is your DNS server you must redirect or block standard DNS port (TCP/UDP 53) and block all DOT (TCP 853) port.

---

## 🔹 Update system and lists

```shell
sudo apt update && \
sudo apt -y upgrade && \
sudo apt clean && \
sudo apt autoclean && \
sudo apt autoremove && \
sudo rpi-update && \
sudo pihole -up && \
sudo pihole-updatelists --update && \
sudo pihole-updatelists && \
sudo reboot
```
