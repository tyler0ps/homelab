## Configure wakeonlan for tylerops node
From any node:
```bash
echo "wakeonlan: 7c:10:c9:8b:b0:74" >> /etc/pve/nodes/tylerops/config

# Verify
cat /etc/pve/nodes/tylerops/config
```
