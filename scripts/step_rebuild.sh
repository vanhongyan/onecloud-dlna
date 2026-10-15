#!/bin/bash
cd /home/src/linux-6.1.25
scripts/config --set-str LOCALVERSION "-meson"
make olddefconfig >/dev/null 2>&1
rm -f sound/soc/meson/snd-soc-meson-gx-sound-card.o sound/soc/meson/snd-soc-meson-gx-sound-card.ko sound/soc/meson/gx-card.o sound/soc/meson/meson-card-utils.o sound/soc/meson/snd-soc-meson-card-utils.o sound/soc/meson/snd-soc-meson-card-utils.ko
make M=sound/soc/meson modules 2>&1 | tail -3
modinfo sound/soc/meson/snd-soc-meson-card-utils.ko | grep vermagic
cp sound/soc/meson/snd-soc-meson-gx-sound-card.ko sound/soc/meson/snd-soc-meson-card-utils.ko /lib/modules/6.1.25-meson/kernel/sound/soc/meson/
depmod -a
modprobe snd-soc-meson-gx-sound-card 2>&1
sleep 2
cat /proc/asound/cards
aplay -l 2>&1 | head -4
echo ====REBUILD_END
