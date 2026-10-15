#!/bin/bash
# 断点续传 + 多代理重试下载 hzyitc 内核 deb
cd /home/pkg || exit 1
BASE=https://github.com/hzyitc/armbian-onecloud/releases/download/ci-20230424-173029-UTC
IMG=linux-image-current-meson_23.05.0-trunk--6.1.25-Sf17b-De8b2-P759b-Cf6d5Hfe66-HK01ba-Va132-B3dc3_armhf.deb
DTB=linux-dtb-current-meson_23.05.0-trunk--6.1.25-Sf17b-De8b2-P759b-Cf6d5Hfe66-HK01ba-Va132-B3dc3_armhf.deb

fetch() {
  local f=$1
  local urls=(
    "https://ghfast.top/$BASE/$f"
    "https://gh-proxy.com/$BASE/$f"
    "https://ghproxy.net/$BASE/$f"
    "$BASE/$f"
  )
  for i in $(seq 1 40); do
    for u in "${urls[@]}"; do
      echo "[$i] $(date +%T) try $u"
      curl -sSL -C - --connect-timeout 15 --speed-time 20 --speed-limit 1000 -o "$f" "$u" && break 2
      sleep 2
    done
  done
}
fetch "$IMG"
fetch "$DTB"
echo "== RESULT =="
ls -la /home/pkg/*.deb
sha256sum /home/pkg/*.deb
curl -sSL "https://ghfast.top/$BASE/sha256sum" | grep current-meson || \
curl -sSL "$BASE/sha256sum" | grep current-meson
