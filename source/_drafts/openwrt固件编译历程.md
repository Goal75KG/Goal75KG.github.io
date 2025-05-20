---
title: openwrt固件编译历程
tags:
  - openwrt
  - 编译
categories: 教程
abbrlink: 4381ffa9
date: 2025-02-19 23:23:54
---

# 编译准备

- 2c4g Debian12 洛杉矶VPS 30G SSD

- 替换源以及安装软件包

```shell
apt update -y
apt full-upgrade -y
apt update
apt install build-essential clang flex bison g++ gawk \
gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
python3-setuptools rsync swig unzip zlib1g-dev file wget
```

- 克隆openwrt官方仓库，签出最新分支

```sh
git clone -b v24.10.0 --single-branch https://github.com/openwrt/openwrt
```

- 更新和安装Feeds

```sh
./scripts/feeds update -a
./scripts/feeds install -a
```

- 生成默认配置文件

```sh
make defconfig
```

- 自定义配置

```sh
make menuconfig
```

​	以斐讯K2P为例

​	访问[OpenWrt 固件选择器](https://firmware-selector.openwrt.org/)，搜索`K2P`，获得平台信息为：`ramips/mt7621`

![PixPin_2025-02-20_00-09-34](C:\Users\jingb\AppData\Local\Programs\PixPin\Temp\PixPin_2025-02-20_00-09-34.png)

​	Target System：MediaTek Ralink MIPS

​	Subtarget：MT7621

​	Target Profile：Phicome K2P

![PixPin_2025-02-20_00-17-27](C:\Users\jingb\AppData\Local\Programs\PixPin\Temp\PixPin_2025-02-20_00-17-27.png)

​	一路save，exit。

- 预下载依赖

```sh
make download -j8 V=s
find dl -size -1024c -exec ls -l {} \;
```



# 开始编译

```sh
make V=s -j$(nproc) > build.log 2>&1 &
```

