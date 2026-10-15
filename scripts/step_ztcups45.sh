#!/bin/bash
# zerotier + cups + hplip 安装
set -x
export DEBIAN_FRONTEND=noninteractive

# ---- zerotier ----
if ! command -v zerotier-cli >/dev/null; then
  curl -sSL https://install.zerotier.com -o /tmp/zt_install.sh
  bash /tmp/zt_install.sh 2>&1 | tail -5
fi
systemctl enable --now zerotier-one 2>&1 | tail -1
zerotier-cli info

# ---- cups + hplip ----
apt-get install -y -qq cups cups-client printer-driver-postscript-hp hplip hp-ppd 2>&1 | tail -3
systemctl enable --now cups
lpinfo -v 2>/dev/null | grep -i usb | head -5
hp-info -h 2>/dev/null | head -2
echo ZT-CUPS-DONE
