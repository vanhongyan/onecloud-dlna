#!/bin/bash
journalctl -u gmediarender --since '2026-10-09 13:08:00' --no-pager \
 | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g' \
 | grep -o 'http://upos-sz-mirrorbd[^" <]*' | head -1 > /tmp/bili_url.txt
U=$(cat /tmp/bili_url.txt)
echo "URL len: ${#U}"
if [ -n "$U" ]; then
  echo '=== GStreamer默认UA ==='
  timeout 12 curl -s -o /dev/null -w "speed %{speed_download} B/s http %{http_code}\n" --range 0-4000000 "$U" -A 'GStreamer souphttpsrc'
  echo '=== 手机浏览器UA ==='
  timeout 12 curl -s -o /dev/null -w "speed %{speed_download} B/s http %{http_code}\n" --range 0-4000000 "$U" -A 'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36'
  echo '=== B站TV UA ==='
  timeout 12 curl -s -o /dev/null -w "speed %{speed_download} B/s http %{http_code}\n" --range 0-4000000 "$U" -A 'Mozilla/5.0 (Linux; U; Android 11) bilibili_tv_proj/8481100'
else
  echo NO-URL
fi
echo BILI-DONE
