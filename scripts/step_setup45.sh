#!/bin/bash
# <BOX_IP_B>: DTB补丁(声卡model属性) + gmrender-resurrect 编译安装
set -x
# ---- 1. DTB patch ----
cd /tmp
dtc -I dtb -O dts -o one.dts /boot/dtb/meson8b-onecloud.dtb
python3 - <<'EOF'
s = open('/tmp/one.dts').read()
if 'model = "ONECLOUD"' not in s:
    s = s.replace('compatible = "amlogic,gx-sound-card";',
                  'compatible = "amlogic,gx-sound-card";\n\t\t\tmodel = "ONECLOUD";', 1)
    open('/tmp/one_fixed.dts','w').write(s)
    print('PATCHED')
else:
    print('ALREADY-OK')
    import shutil; shutil.copy('/tmp/one.dts','/tmp/one_fixed.dts')
EOF
dtc -I dts -O dtb -o /tmp/onecloud_fixed.dtb /tmp/one_fixed.dts
cp /boot/dtb/meson8b-onecloud.dtb /boot/dtb/meson8b-onecloud.dtb.pre-model 2>/dev/null
cp /tmp/onecloud_fixed.dtb /boot/dtb/meson8b-onecloud.dtb
sync
echo DTB-DONE

# ---- 2. gmrender-resurrect build ----
cd /tmp
rm -rf gmrender-resurrect
git clone --depth 1 https://ghfast.top/https://github.com/hzeller/gmrender-resurrect.git 2>/dev/null \
  || git clone --depth 1 https://github.com/hzeller/gmrender-resurrect.git
cd gmrender-resurrect
./autogen.sh
./configure CPPFLAGS=-I/usr/include/upnp
make -j4
make install
ldconfig
gmediarender --version
echo BUILD-DONE
