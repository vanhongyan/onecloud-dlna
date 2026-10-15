#!/bin/bash
# <BOX_IP_B> 新系统依赖安装
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-alsa alsa-utils build-essential git \
  autoconf automake libtool pkg-config libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  libglib2.0-dev libupnp-dev python3-pil device-tree-compiler curl less sudo 2>&1 | tail -3
echo DEPS-DONE
