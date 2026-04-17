Install NPM as LXC
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/nginxproxymanager.sh)"
```

Configure Pfsense to forward all traffic to this NPM

Add Proxy Host

Domain: sso.tylerops.dev
Scheme: http
Forward IP: 192.168.1.192
Forward Port: 80

SSL:
- Force SSL
- Request new Cert, let's encrypt
