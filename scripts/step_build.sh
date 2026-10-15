#!/bin/bash
exec >/tmp/build.log 2>&1
set -e
cd /usr/local/src
if [ ! -d gmrender-resurrect ]; then
  git clone --depth 1 https://github.com/hzeller/gmrender-resurrect.git
fi
cd gmrender-resurrect
./autogen.sh
make -j4
make install
ldconfig
echo BUILD_DONE
