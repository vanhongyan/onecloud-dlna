#!/bin/bash
set -e
cd /tmp
URLS=(
 "https://ghfast.top/https://github.com/hzeller/gmrender-resurrect/archive/refs/tags/v0.3.1.tar.gz"
 "https://gh-proxy.com/https://github.com/hzeller/gmrender-resurrect/archive/refs/tags/v0.3.1.tar.gz"
 "https://github.com/hzeller/gmrender-resurrect/archive/refs/tags/v0.3.1.tar.gz"
)
for u in "${URLS[@]}"; do
  echo "try: $u"
  curl -fL --connect-timeout 10 -m 120 -o gmr.tar.gz "$u" && [ $(stat -c%s gmr.tar.gz) -gt 100000 ] && break
done
ls -l gmr.tar.gz
rm -rf gmrender-resurrect-0.3.1
tar xzf gmr.tar.gz
cd gmrender-resurrect-0.3.1
grep -n 'about-to-finish\|playbin\|uridecodebin\|buffering' src/gstreamer.c | head -20
echo FETCH-DONE
