#!/bin/bash
echo '=== 网络接口/速率协商 ==='
ethtool eth0 2>/dev/null | grep -E 'Speed|Duplex|Link' || cat /sys/class/net/eth0/speed
echo '=== 拉流下载测速(抖音CDN节点样例 10s) ==='
# 用 curl 测公网下载能力
timeout 15 curl -o /dev/null -s -w 'speed: %{speed_download} B/s, size: %{size_download}\n' http://speedtest.tele2.net/1MB.zip || true
timeout 15 curl -o /dev/null -s -w 'speed: %{speed_download} B/s\n' https://dldir1.qq.com/qqfile/qq/QQNT/Mac/QQ_6.9.25_240422_01.dmg --range 0-3000000 || true
echo '=== 中断统计(丢包) ==='
ip -s link show eth0 | head -6
echo NET-DONE
