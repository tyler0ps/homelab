## Install NPM as LXC
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/nginxproxymanager.sh)"
```

## Set Static IP for LXC

By default the LXC uses DHCP, so the IP may change on every reboot. Fix by setting a static IP in the Proxmox LXC config.

SSH into the Proxmox host and edit the LXC 105 config:

```bash
nano /etc/pve/lxc/105.conf
```

Change the `net0` line from DHCP to a static IP (pick an IP outside your router's DHCP range):

```bash
# Before:
net0: name=eth0,bridge=vmbr0,ip=dhcp,...

# After:
net0: name=eth0,bridge=vmbr0,ip=192.168.1.x/24,gw=192.168.1.1,...
```

Restart the LXC to apply:

```bash
pct reboot 105
```

## Configure Pfsense to forward all traffic to this NPM

## Add Proxy Host

Domain: sso.tylerops.dev
Scheme: http
Forward IP: 192.168.1.192
Forward Port: 80

SSL:
- Force SSL
- Request new Cert, let's encrypt
