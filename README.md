# 玩客云(OneCloud) Armbian DLNA 投屏方案 - 技术说明文档

- **版本**: v1.0
- **作者**: 范范
- **日期**: 2026-10-02
- **设备**: 玩客云 (Xunlei OneCloud, Amlogic S805, ARM Cortex-A5 x4, 1GB RAM)
- **系统**: Armbian bookworm (原始安装 26.2.1, 后更换 hzyitc 内核 6.1.25-meson)
- **功能**: 手机通过 DLNA/UPnP 投屏视频到 HDMI 电视, 含开机状态指示画面、停止投屏清屏

---

## 1. 最终架构

```
手机(B站/BubbleUPnP等 DLNA 控制点)
    │ SSDP 发现(M-SEARCH/239.255.255.250:1900) + AVTransport 控制
    ▼
gmediarender 0.3.1 (gmrender-resurrect, 源码编译)
  - 自编译: libupnp-1.8.4 + GStreamer 1.22 栈
  - systemd: /etc/systemd/system/gmediarender.service
    参数: --logfile=stdout -I eth0 -f OneCloud-TV -u <uuid>
          --gstout-audiosink=alsasink
          --gstout-videopipe="videoflip method=automatic ! videoscale ! video/x-raw,width=1280,height=720 ! fbdevsink"
    启动保护: Wants/After=network-online.target + ExecStartPre 轮询等待 eth0 拿到 IP
    │ GStreamer playbin 软解(avdec_h264/aac)
    ▼
视频: fbdevsink → /dev/fb0 (1280x720@24bpp, DRM 强制模式) → HDMI
音频: alsasink → ALSA card 0 (ONECLOUD, gx-sound-card) → HDMI
    ▼
电视

辅助: gm-idle.service
  - 开机解绑 fbcon(vtconsole/vtcon1), 画"带框 starting"画面
  - socket 探测本机 49494 端口可连接 → 切"无框待机"画面
  - 常驻监听 journalctl -u gmediarender 的 STOPPED 事件
    → 延迟 2.5s+6s 两次写待机画面(消除残影)
```

状态指示约定: **带框 = 启动中/异常, 无框 = 可投屏**。(刻意只用黑白灰+有框/无框区分, 规避 meson fb 24bpp 的 R/B 色彩偏移问题)

---

## 2. 遇到的问题与解决方案 (时间线)

### 2.1 HDMI 显示: 官方 6.12 内核黑屏/无信号
- **现象**:电视从"无信号"变"黑屏"或完全无信号; EDID 读出 0 字节
- **根因**: Armbian 官方主线 6.12 内核在 meson8b/S805 上 HDMI 输出损坏(Armbian 论坛确认的回归, 2025 年多人报告); 叠加本机 DDC/EDID 读取始终为空
- **排查过程**:
  - 确认 fb0 中彩条数据存在(软件栈正常) → 定位到内核显示驱动层
  - 查阅 Armbian 论坛 S805 帖子确认主线 6.12 HDMI 回归
- **解决**: 安装 hzyitc/armbian-onecloud 发布的 6.1.25-meson 内核 deb(社区验证 HDMI 可用), 直接 `dpkg -i` 替换, 无需重刷系统
- **残留**: EDID 依然读不到 → 用内核参数强制模式兜底:
  `/boot/armbianEnv.txt` 追加 `extraargs=video=HDMI-A-1:1280x720@60D`

### 2.2 换内核后声卡消失 (probe error -22)
- **现象**: `/proc/asound/cards` 为空, dmesg 报 `gx-sound-card sound: probe ... error -22`
- **根因**: DTB 的 `sound` 节点缺少 `model` 属性, gx-sound-card 驱动的 `snd_soc_of_parse_card_name()` 缺失必返 -EINVAL
- **解决**: dtc 反编译 DTB → 补 `model = "ONECLOUD";` → 重编译 → 替换 `/boot/dtb/meson8b-onecloud.dtb` → 重启
- **坑**: hzyitc 的 DTB 同样缺该属性, 换内核后必须对新 DTB 重做此补丁

### 2.3 hzyitc 6.1.25 内核没有声卡驱动
- **现象**: 修好 DTB 后仍无声卡, dmesg 连 probe 尝试都没有
- **根因**: hzyitc 内核 `CONFIG_SND_MESON_GX_SOUND_CARD is not set`, 且无模块
- **解决**: 用完整内核源码(linux-6.1.25.tar.xz) + armbian headers deb 在盒子上本地编译
  - 仅需 2 个源文件: `gx-card.c` + `meson-card-utils.c` (+ `meson-card-utils.h`)
  - Kbuild: `obj-m := snd-soc-meson-gx-sound-card.o` / `snd-soc-meson-gx-sound-card-objs := gx-card.o meson-card-utils.o`
  - `make modules_prepare` 需补 headers 缺失的 `arch/arm/tools/`(syscall.tbl, syscallnr.sh 等)
  - `make M=sound/soc/meson modules`
- **坑(vermagic)**: 默认编出 vermagic `6.1.25`, 与运行内核 `6.1.25-meson` 不符 → `Exec format error`。
  修复: `scripts/config --set-str LOCALVERSION "-meson"` 后必须 `rm include/generated/utsrelease.h` 再 `make prepare` 重新生成, 否则模块仍用旧版本串
- **坑(覆盖原版模块)**: 第一次安装时 `cp *.ko /lib/modules/.../meson/` 把 aiu/codec-glue 等原版模块也覆盖成错误 vermagic 版本 → 断电重启后声卡又消失。
  修复: 只安装自编的 `snd-soc-meson-gx-sound-card.ko` 和 `snd-soc-meson-card-utils.ko`, 其余保持原版; 全部模块统一用正确 vermagic 重编亦可
- **自动加载**: `echo snd-soc-meson-gx-sound-card > /etc/modules-load.d/gx-sound.conf`

### 2.4 手机搜不到投屏设备 (多网卡)
- **现象**: 服务 active 且端口监听, 但手机/PC 发 M-SEARCH 无响应
- **根因**: 盒子有 ZeroTier + docker0 等多网卡, libupnp 组播绑错接口; journal 出现 `UpnpInit2 ... UPNP_E_INVALID_INTERFACE (-121)` 重试
- **解决**: gmediarender 加 `-I eth0` 显式指定接口
- **坑**: 重启后偶发搜不到 → 开机时 eth0 尚未完成 DHCP, UPnP 初始化在 60 秒重试窗口内竞态。
  修复: service 加 `Wants/After=network-online.target` + `ExecStartPre` 轮询等待 eth0 有 192.168 地址(最多 120s)才启动主程序

### 2.5 投屏卡住不动 (播放失败 704)
- **现象**: 手机能搜到、能选设备, 但进度条不动, 电视无反应
- **根因**: 日志报 `Playback open error on device 'default': No such file or directory` — ALSA default 设备缺失(由 2.3 声卡问题衍生)
- **解决**: 声卡恢复后自动解决; 排查方法是给 gmediarender 加 `--logfile=stdout` 看 journal

### 2.6 有画面但不缩放/不旋转 (fbdevsink 特性)
- **现象**: 360p 视频居中小窗, 1080p 被裁切, 竖屏视频横卧
- **根因**: fbdevsink/kmssink 均不做缩放; kmssink 另有渲染层被 fbcon framebuffer 挡住不可见的问题
- **解决**: gmediarender 原生支持 `--gstout-videopipe`(管道描述), 配置:
  `videoflip method=automatic ! videoscale ! video/x-raw,width=1280,height=720 ! fbdevsink`
- **坑**: systemd ExecStart 中管道含空格和 `!`, 必须整体加双引号, 否则被拆成多个参数(日志只会显示 "Setting video sink-pipeline to videoscale")

### 2.7 停止投屏后画面残影
- **现象**: 停止/切换投屏后电视保留最后一帧
- **解决**: `gm-idle.service` 常驻监听 `journalctl -u gmediarender -f`, 匹配 `STOPPED`/`NO_MEDIA_PRESENT` 后延迟 2.5s + 6s 两次写待机画面到 fb0(两次是为了覆盖 gstreamer 拆管线时写下的最后帧)

### 2.8 待机画面颜色显示偏差
- **现象**: 画的蓝色边框在电视上是"黄色"
- **根因**: meson fb0 为 24bpp(stride=3840), 实际色彩字节序与预期存在 R/B 偏移
- **解决**: 状态指示改用"有框/无框"区分, 配色只用黑白灰, 规避色彩偏移问题
- **教训**: 如果需要精确颜色, 先用纯绿全屏(不受 R/B 影响)验证写入路径, 再 dump `/dev/fb0` 字节对比实际显示

### 2.9 fb0 直接写屏注意事项
- fb0: 1280x720, 24bpp, stride=3840 (=1280*3)
- var screeninfo: `bits_per_pixel` 在 ioctl 返回缓冲区偏移 24(不是 96)
- fix screeninfo: `line_length` 在偏移 44
- 24bpp 按行写: 每行 xres*3 字节 + (stride - rowbytes) 补零

---

## 3. 从零复现部署步骤

前提: 玩客云已刷 Armbian bookworm(任意可用内核版本, 能 SSH 即可), 本机与盒子同网段。

### 步骤 1: 基础依赖
```bash
apt-get update
apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav \
  gstreamer1.0-alsa alsa-utils build-essential git autoconf automake \
  libtool pkg-config libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  libglib2.0-dev libupnp-dev bison flex
# 注意: 编译 gmrender-resurrect 需 CPPFLAGS=-I/usr/include/upnp (libupnp 1.8 头文件在子目录)
```

### 步骤 2: 编译 gmrender-resurrect
```bash
git clone --depth 1 https://github.com/hzeller/gmrender-resurrect.git /usr/local/src/
cd /usr/local/src/gmrender-resurrect
./autogen.sh
./configure CPPFLAGS=-I/usr/include/upnp
make -j4 && make install && ldconfig
```

### 步骤 3: 更换 hzyitc 内核(若 HDMI 不可用)
从 https://github.com/hzyitc/armbian-onecloud/releases 下载(ci-20230424-173029-UTC):
- `linux-image-current-meson_23.05.0-trunk--6.1.25-Sf17b-....deb` (24.5MB)
- `linux-dtb-current-meson_23.05.0-trunk--6.1.25-Sf17b-....deb`

```bash
dpkg -i linux-dtb-current-meson_*.deb
dpkg -i linux-image-current-meson_*.deb
reboot
```
大陆网络可在 GitHub URL 前加 `https://ghproxy.net/` 加速。

### 步骤 4: 修 DTB 声卡(必做)
```bash
dtc -I dtb -O dts -o /tmp/one.dts /boot/dtb/meson8b-onecloud.dtb
python3 -c "
s = open('/tmp/one.dts').read()
s = s.replace('compatible = \"amlogic,gx-sound-card\";',
  'compatible = \"amlogic,gx-sound-card\";\n\t\t\tmodel = \"ONECLOUD\";', 1)
open('/tmp/one_fixed.dts','w').write(s)"
dtc -I dts -O dtb -o /tmp/onecloud_fixed.dtb /tmp/one_fixed.dts
cp /tmp/onecloud_fixed.dtb /boot/dtb/meson8b-onecloud.dtb && sync
reboot
```

### 步骤 5: 编译声卡模块(6.1.25 内核必做)
包内 `kernel_module/` 目录已含源码和 .ko。若需重新编译:
```bash
# 安装与运行内核同版本的 headers deb, 然后:
dpkg -i linux-headers-current-meson_*.deb
apt-get install -y bison flex
# 若 make modules_prepare 报缺 arch/arm/tools/*, 从内核源码包补齐
cd /home/src/linux-6.1.25   # 完整源码树
cp /boot/config-6.1.25-meson .config
make olddefconfig && make modules_prepare
cd sound/soc/meson   # 放入 gx-card.c meson-card-utils.c meson-card-utils.h 及 Makefile.kbuild
make -C /usr/src/linux-headers-6.1.25-meson M=$PWD modules
```
Kbuild 文件内容(`Makefile`):
```makefile
obj-m := snd-soc-meson-gx-sound-card.o
snd-soc-meson-gx-sound-card-objs := gx-card.o meson-card-utils.o
```
vermagic 修正(必须):
```bash
scripts/config --set-str LOCALVERSION "-meson"
rm -f include/generated/utsrelease.h
make prepare
# 重新 make 模块
```
安装:
```bash
cp snd-soc-meson-gx-sound-card.ko snd-soc-meson-card-utils.ko \
   /lib/modules/6.1.25-meson/kernel/sound/soc/meson/
depmod -a
modprobe snd-soc-meson-gx-sound-card
echo snd-soc-meson-gx-sound-card > /etc/modules-load.d/gx-sound.conf
```
**切记**: 不要用 `cp *.ko` 覆盖整个目录, 会破坏原版模块的 vermagic!

### 步骤 6: 部署服务
包内 `configs/` 有现成的服务文件:
```bash
cp pkg_gmediarender.service /etc/systemd/system/gmediarender.service
cp pkg_gm-idle.service /etc/systemd/system/gm-idle.service
cp fb_idle.py fb_watch.py /home/src/
mkdir -p /etc/modules-load.d
echo snd-soc-meson-gx-sound-card > /etc/modules-load.d/gx-sound.conf
systemctl daemon-reload
systemctl enable --now gmediarender gm-idle
```
注: gmediarender.service 中 UUID 可保持不变或用 `cat /proc/sys/kernel/random/uuid` 重新生成。

### 步骤 7: 强制 HDMI 模式(EDID 读不到时)
`/boot/armbianEnv.txt` 追加:
```
extraargs=video=HDMI-A-1:1280x720@60D
```

### 步骤 8: 验证
```bash
cat /proc/asound/cards          # 应显示 ONECLOUD
speaker-test -c 2 -t sine -l 1  # 电视应有蜂鸣音
systemctl is-active gmediarender gm-idle
ss -tlnp | grep 49494           # UPnP 端口
# 电视应显示无框待机画面; 手机 DLNA 搜索 OneCloud-TV
```

---

## 4. 踩坑速查表

| # | 坑 | 症状 | 对策 |
|---|---|---|---|
| 1 | 6.12 主线内核 S805 HDMI 损坏 | 黑屏/无信号, fb0 数据正常 | 换 hzyitc 6.1.25 内核 |
| 2 | DTB sound 节点缺 model | gx-sound-card probe -22 | dtc 补属性重编译 |
| 3 | libupnp 1.8 头文件路径 | upnp.h not found | `CPPFLAGS=-I/usr/include/upnp` |
| 4 | 模块 vermagic 不符 | Exec format error | LOCALVERSION=-meson + 重新生成 utsrelease.h |
| 5 | cp *.ko 覆盖原版模块 | 重启后声卡消失 | 只装自编模块 |
| 6 | 多网卡组播绑错 | 搜不到设备, INVALID_INTERFACE | `-I eth0` |
| 7 | 开机 DHCP 未完成即启动 | 重启后偶发搜不到 | ExecStartPre 等 IP + network-online.target |
| 8 | systemd 参数含 ! 未加引号 | 管道被拆散只生效第一段 | 整体双引号 |
| 9 | fbcon 挡住 kmssink | kmssink 播放但只看到控制台 | 用 fbdevsink 或解绑 vtcon1 |
| 10 | fbdevsink 不缩放 | 小窗居中/裁切 | --gstout-videopipe 插 videoscale |
| 11 | 停止投屏残影 | 最后一帧留在屏幕 | STOPPED 事件后延迟两次写 fb0 |
| 12 | meson fb 24bpp 色彩偏移 | 颜色 R/B 反 | 状态用有框/无框区分, 避开彩色 |
| 13 | headers 缺 arch/arm/tools | modules_prepare 失败 | 从源码包补 syscall.tbl/syscallnr.sh |
| 14 | utsrelease 缓存 | LOCALVERSION 改了不生效 | 删 include/generated/utsrelease.h 再 prepare |
| 15 | Windows ssh 远端引号被剥离 | 远端命令莫名拆散 | 复杂命令走脚本文件 scp + bash -s, 或 base64 |

---

## 5. 程序包 / 中间件清单

### 系统包 (apt, Debian bookworm)
gstreamer1.0-tools / plugins-base / plugins-good / plugins-bad / libav / alsa (1.22.0),
alsa-utils, build-essential, git, autoconf, automake, libtool, pkg-config,
libgstreamer1.0-dev, libgstreamer-plugins-base1.0-dev, libglib2.0-dev,
libupnp-dev (1.8.4-2), libdrm-tests(modetest 调试用), python3-pil (9.4.0), bison, flex

### 手工编译/安装
| 组件 | 版本 | 来源 | 说明 |
|---|---|---|---|
| gmrender-resurrect | 0.3.1 | github.com/hzeller/gmrender-resurrect | DLNA 渲染器, 装到 /usr/local/bin |
| 内核 6.1.25-meson | 23.05.0-trunk | github.com/hzyitc/armbian-onecloud releases | HDMI 可用 |
| snd-soc-meson-gx-sound-card.ko | 自编 6.1.25 | 包内 kernel_module/ | 声卡驱动, hzyitc 内核缺失 |
| linux-headers-current-meson | 23.05.0-trunk | 同 hzyitc releases | 模块编译 |
| 内核源码 linux-6.1.25.tar.xz | 6.1.25 | mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/ | 模块编译 + 补 headers 缺件 |

### 服务
- `gmediarender.service` — DLNA 渲染器(带网络等待保护)
- `gm-idle.service` — 状态画面 + 停止清屏 watcher
- `modules-load.d/gx-sound.conf` — 声卡模块自动加载

### 远程管理
- SSH: root@<BOX_IP_A>, 密钥 `~/.ssh/id_ed25519`(Windows 端)
- Windows 辅助脚本: `scripts/ssh_box.ps1`(Posh-SSH 密码登录+重试, 或传脚本文件自动 base64 执行)

---

## 6. 包内文件清单

```
configs/
  pkg_gmediarender.service      # DLNA 渲染器 systemd 服务(现役配置)
  pkg_gm-idle.service           # 状态画面/清屏 watcher 服务
  pkg_armbianEnv.txt            # /boot/armbianEnv.txt 参考(含 video= 强制模式)
  pkg_gx-sound.conf             # modules-load.d 声卡自动加载
  snd-soc-meson-gx-sound-card.ko   # 自编声卡驱动(6.1.25-meson)
  snd-soc-meson-card-utils.ko      # 依赖模块
dtb/
  dtb_patched.dtb               # 修补好的 DTB(含 model 属性, 可直接替换 /boot/dtb/meson8b-onecloud.dtb)
  dtb_hzyitc_orig.dtb           # hzyitc 原版 DTB(未修补, 回滚参考)
  pkg_config-6.1.25-meson       # 内核编译配置(重编模块必需)
kernel_module/
  gx-card.c                     # 声卡卡驱动源码 (linux 6.1.25)
  meson-card-utils.c            # 公共卡工具源码
  meson-card-utils.h            # 头文件
  Makefile                      # 模块构建 Kbuild(obj-m 定义)
  Makefile.meson-reference      # 内核树 Makefile 参考(构建目标定义)
scripts/
  ssh_box.ps1                   # Windows SSH 辅助(密码/脚本文件执行)
  ssdp_search.ps1               # Windows 端 SSDP 发现自测
  step_install.sh               # apt 依赖安装
  step_build.sh                 # gmrender-resurrect 编译
  step_key.sh                   # SSH 公钥安装
  step_patchdtb61.sh            # DTB 补 model 属性 + 重编译
  step_modbuild.sh              # 声卡模块后台编译
  step_rebuild.sh               # 模块 vermagic 修正重编+安装
  step_netfix.sh                # gmediarender 服务网络等待加固部署
  step_vpipe2.sh                # videopipe 引号修复示例
  step_rot.sh                   # videoflip 自动旋转配置
  step_idle.sh                  # gm-idle 状态画面服务部署
src/
  fb_idle.py                    # fb0 绘图库(状态画面/清屏, 支持 starting/ok)
  fb_watch.py                   # STOPPED 监听 + 就绪检测 + 启动状态机
  fb_green.py                   # 全屏纯绿测试(验证 fb 写入通路)
README.md                       # 本文档
```

## 7. 日常运维

```bash
systemctl status gmediarender gm-idle     # 服务状态
journalctl -u gmediarender -f             # 实时日志(含投屏控制事件)
systemctl restart gmediarender            # 重启渲染器(手机重搜)
python3 /home/src/fb_idle.py ok           # 手动画待机画面
python3 /home/src/fb_idle.py starting     # 手动画启动中画面
python3 /home/src/fb_green.py             # 全屏绿(测试 fb 通路)
modprobe snd-soc-meson-gx-sound-card      # 手动加载声卡
# 已知限制: S805 软解, 720p 流畅, 1080p 会卡; 手机端建议选"流畅"清晰度
```
