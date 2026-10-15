#!/bin/bash
echo '=== /boot 内容 ==='
ls -la /boot/ 2>/dev/null | head -15
echo '=== 当前内核 cmdline ==='
cat /proc/cmdline
echo '=== boot 配置文件(scr/extlinux/uEnv) ==='
for f in /boot/extlinux/extlinux.conf /boot/boot.cmd /boot/uEnv.txt /boot/armbianEnv.txt; do
  [ -f "$f" ] && echo "--- $f ---" && cat "$f"
done
echo '=== HDMI 当前模式 ==='
cat /sys/class/display/mode 2>/dev/null || cat /sys/class/amhdmitx/amhdmitx0/disp_mode 2>/dev/null || echo 'no-amlogic-sysfs'
for p in /sys/class/drm/card*-HDMI-A-1/modes; do [ -f "$p" ] && echo "--- $p ---" && head -5 "$p"; done 2>/dev/null
echo '=== fb 相关内核参数/驱动 ==='
dmesg 2>/dev/null | grep -iE 'meson.*fb|osd|hdmi.*mode|vic ' | head -10
echo '=== video cmdline 参数 ==='
cat /proc/cmdline | tr ' ' '\n' | grep -iE 'video|hdmi|fb'
echo RECON-DONE
