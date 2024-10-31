#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#


# 移除要替换的包
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/net/mosdns
# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
# mosdns
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

git clone https://github.com/zzsj0928/luci-app-pushbot package/luci-app-pushbot
# git_sparse_clone master https://github.com/xuanranran/openwrt-packages mosdns
git_sparse_clone master https://github.com/xuanranran/openwrt-packages luci-app-adguardhome
# 加入OpenClash核心
# chmod -R a+x $GITHUB_WORKSPACE/preset-clash-core.sh
# $GITHUB_WORKSPACE/preset-clash-core.sh

# 修改默认IP
sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate

# 修改默认主题
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" feeds/luci/collections/luci-light/Makefile


