#!/bin/bash
cp /boot/dtb/meson8b-onecloud.dtb /boot/dtb/meson8b-onecloud.dtb.hzyitc.bak
sed 's/compatible = "amlogic,gx-sound-card";/\&\n\t\t\tmodel = "ONECLOUD";/' /tmp/one61.dts | sed 's/\&$/compatible = "amlogic,gx-sound-card";/' > /tmp/one61_fixed.dts
python3 - <<'PYEOF'
s = open("/tmp/one61.dts").read()
s = s.replace('compatible = "amlogic,gx-sound-card";', 'compatible = "amlogic,gx-sound-card";\n\t\t\tmodel = "ONECLOUD";', 1)
open("/tmp/one61_fixed.dts","w").write(s)
PYEOF
grep -n ONECLOUD /tmp/one61_fixed.dts
dtc -I dts -O dtb -o /tmp/one61_fixed.dtb /tmp/one61_fixed.dts 2>/dev/null
cp /tmp/one61_fixed.dtb /boot/dtb/meson8b-onecloud.dtb && sync
echo DTB_PATCHED
