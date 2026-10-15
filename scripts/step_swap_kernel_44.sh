#!/bin/bash
# <BOX_IP_C> (OneCloud, S812固件, vendor u-boot + uEnv.txt) 换 hzyitc 6.1.25-meson 内核
set -e
cd /home/pkg
KVER=6.1.25-meson
IMG=linux-image-current-meson_23.05.0-trunk--6.1.25-Sf17b-De8b2-P759b-Cf6d5Hfe66-HK01ba-Va132-B3dc3_armhf.deb
DTB=linux-dtb-current-meson_23.05.0-trunk--6.1.25-Sf17b-De8b2-P759b-Cf6d5Hfe66-HK01ba-Va132-B3dc3_armhf.deb

echo "== 1. 备份原引导文件 =="
cp /boot/uImage /boot/uImage.5.9.bak 2>/dev/null || true
cp /boot/uInitrd /boot/uInitrd.5.9.bak 2>/dev/null || true
cp /boot/uEnv.txt /boot/uEnv.txt.bak

echo "== 2. 安装内核/DTB deb =="
dpkg -i "$DTB" "$IMG"

echo "== 3. 检查内核镜像格式 =="
ls -la /boot/vmlinuz-* 2>/dev/null
file /boot/vmlinuz-$KVER 2>/dev/null || true

echo "== 4. 生成 initramfs =="
# hzyitc deb 通常不带 initrd; 用现有 5.9 initramfs 工具链生成
update-initramfs -c -k $KVER 2>&1 | tail -2 || true
ls -la /boot/initrd.img-$KVER 2>/dev/null || echo "NO initrd.img-$KVER"

echo "== 5. 打包 uImage =="
# 判断压缩: vmlinuz 若为 gzip zImage/Image 用 gzip 包装
if file /boot/vmlinuz-$KVER | grep -q gzip; then C=gzip; else C=none; fi
mkimage -A arm -O linux -T kernel -C $C -a 0x00208000 -e 0x00208000 \
  -n "linux-$KVER" -d /boot/vmlinuz-$KVER /boot/uImage.new
mv /boot/uImage.new /boot/uImage

echo "== 6. 打包 uInitrd =="
if [ -f /boot/initrd.img-$KVER ]; then
  mkimage -A arm -O linux -T ramdisk -C gzip -a 0 -e 0 \
    -n "uInitrd-$KVER" -d /boot/initrd.img-$KVER /boot/uInitrd.new
  mv /boot/uInitrd.new /boot/uInitrd
else
  echo "!! 无 initrd, 沿用备份 uInitrd (5.9)"
fi

echo "== 7. DTB: 使用包内已修补版(含 model=ONECLOUD) =="
cp /home/pkg/dtb_patched.dtb /boot/dtb/meson8b-onecloud.dtb

echo "== 8. 更新 uEnv.txt =="
sed -i 's|^FDT=.*|FDT=/dtb/meson8b-onecloud.dtb|' /boot/uEnv.txt
grep -q 'video=HDMI-A-1' /boot/uEnv.txt || \
  sed -i 's|^APPEND=\(.*\)|APPEND=\1 video=HDMI-A-1:1280x720@60D|' /boot/uEnv.txt
cat /boot/uEnv.txt

echo "== 9. 模块安装(仅自编声卡模块稍后处理) =="
depmod -a $KVER

echo "DONE-SWAP. 准备重启"
