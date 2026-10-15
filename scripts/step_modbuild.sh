#!/bin/bash
exec >/tmp/buildmod.log 2>&1
set -e
cd /home/src
tar -xf linux-6.1.25.tar.xz
cp /boot/config-6.1.25-meson linux-6.1.25/.config
cd linux-6.1.25
scripts/config --enable CONFIG_SND_MESON_GX_SOUND_CARD --enable CONFIG_SND_MESON_CARD_UTILS
make olddefconfig
make modules_prepare
make M=sound/soc/meson modules
ls -l sound/soc/meson/*.ko
echo MODBUILD_DONE
