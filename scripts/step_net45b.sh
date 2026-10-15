#!/bin/bash
echo '=== 阿里云 OSS 测速 5MB ==='
timeout 20 curl -o /dev/null -s -w 'speed: %{speed_download} B/s (%{size_download} bytes)\n' https://oss-cn-hangzhou.aliyuncs.com/ || true
echo '=== 腾讯软件源 ==='
timeout 20 curl -o /dev/null -s -w 'speed: %{speed_download} B/s (%{size_download} bytes)\n' --range 0-5000000 https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.13_240920_amd64_01.AppImage || true
echo '=== 清华镜像 ==='
timeout 20 curl -o /dev/null -s -w 'speed: %{speed_download} B/s (%{size_download} bytes)\n' --range 0-5000000 https://mirrors.tuna.tsinghua.edu.cn/debian-cd/current/amd64/iso-cd/debian-13.1.0-amd64-netinst.iso || true
echo '=== ping 网关/外网 ==='
GW=$(ip route | awk '/default/ {print $3; exit}')
ping -c 5 -q $GW | tail -2
ping -c 5 -q 223.5.5.5 | tail -2
echo NET2-DONE
