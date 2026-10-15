#!/bin/bash
echo '=== 清华镜像真实下载 8MB ==='
timeout 25 curl -o /dev/null -sL -w 'speed: %{speed_download} B/s, got %{size_download} bytes, http %{http_code}\n' --range 0-8000000 https://mirrors.tuna.tsinghua.edu.cn/debian/ls-lR.gz
echo '=== 中科大镜像 ==='
timeout 25 curl -o /dev/null -sL -w 'speed: %{speed_download} B/s, got %{size_download} bytes, http %{http_code}\n' --range 0-8000000 https://mirrors.ustc.edu.cn/debian/ls-lR.gz
echo '=== DNS 解析抖音CDN ==='
grep nameserver /etc/resolv.conf | head -2
time getent hosts v3-web.douyinvod.com || echo 'dns-fail'
echo NET3-DONE
