#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt for Amlogic s9xxx tv box
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/coolsnowwolf/lede / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
# sed -i 's/luci-theme-bootstrap/luci-theme-material/g' ./feeds/luci/collections/luci/Makefile

# Add autocore support for armvirt
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings
echo "DISTRIB_SOURCECODE='lede'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate

# Replace the default software source
# sed -i 's#openwrt.proxy.ustclug.org#mirrors.bfsu.edu.cn\\/openwrt#' package/lean/default-settings/files/zzz-default-settings
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic
sed -i "s|amlogic_firmware_repo.*|amlogic_firmware_repo 'https://github.com/alecthw/openwrt-n1'|g" package/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|ARMv8|armv8_mini|g" package/luci-app-amlogic/root/etc/config/amlogic

# Fix runc version error
# rm -rf ./feeds/packages/utils/runc/Makefile
# svn export https://github.com/openwrt/packages/trunk/utils/runc/Makefile ./feeds/packages/utils/runc/Makefile

# coolsnowwolf default software package replaced with Lienol related software package
# rm -rf feeds/packages/utils/{containerd,libnetwork,runc,tini}
# svn co https://github.com/Lienol/openwrt-packages/trunk/utils/{containerd,libnetwork,runc,tini} feeds/packages/utils

# Add third-party software packages (The entire repository)
# git clone https://github.com/libremesh/lime-packages.git package/lime-packages
# Add third-party software packages (Specify the package)
# svn co https://github.com/libremesh/lime-packages/trunk/packages/{shared-state-pirania,pirania-app,pirania} package/lime-packages/packages
# Add to compile options (Add related dependencies according to the requirements of the third-party software package Makefile)
# sed -i "/DEFAULT_PACKAGES/ s/$/ pirania-app pirania ip6tables-mod-nat ipset shared-state-pirania uhttpd-mod-lua/" target/linux/armvirt/Makefile

# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------


# delete 53 redirect
sed -i '/REDIRECT --to-ports 53/d' package/lean/default-settings/files/zzz-default-settings

# replace v2ray-geodata
rm -rf feeds/packages/net/v2ray-geodata
svn co https://github.com/fw876/helloworld/trunk/v2ray-geodata feeds/packages/net/v2ray-geodata

# add OpenAppFilter
rm -rf package/OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# add luci-theme-argon-jerrykuku
rm -rf package/luci-theme-argon-jerrykuku
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git -b 18.06 package/luci-theme-argon-jerrykuku

# add luci-app-tcpdump
rm -rf package/luci-app-tcpdump
svn co https://github.com/Lienol/openwrt-package/branches/other/luci-app-tcpdump package/luci-app-tcpdump

# add luci-app-adguardhome
rm -rf package/luci-app-adguardhome
svn co https://github.com/Lienol/openwrt-package/branches/other/luci-app-adguardhome package/luci-app-adguardhome
# download latest adguardhome core
mkdir -p package/luci-app-adguardhome/root/etc/AdGuardHome
curl -kL --retry 3 --connect-timeout 3 -o package/luci-app-adguardhome/root/etc/AdGuardHome.tar.gz https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_linux_arm64.tar.gz
tar xzf package/luci-app-adguardhome/root/etc/AdGuardHome.tar.gz -C package/luci-app-adguardhome/root/etc/
rm -rf package/luci-app-adguardhome/root/etc/AdGuardHome.tar.gz

# replace luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns.git feeds/luci/applications/luci-app-smartdns

# replace smartdns
rm -rf feeds/packages/net/smartdns
svn co https://github.com/Lienol/openwrt-packages/branches/master/net/smartdns feeds/packages/net/smartdns

# replace luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
svn co https://github.com/sbwml/luci-app-mosdns/trunk/luci-app-mosdns feeds/luci/applications/luci-app-mosdns
# sed -i 's#PROG start#PROG start -d /etc/mosdns#g' feeds/luci/applications/luci-app-mosdns/root/etc/init.d/mosdns

# download rules
curl -kL --retry 3 --connect-timeout 3 -o feeds/luci/applications/luci-app-mosdns/root/etc/mosdns/rule/reject-list.txt https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt
curl -kL --retry 3 --connect-timeout 3 -o feeds/luci/applications/luci-app-mosdns/root/etc/mosdns/rule/cn-white.txt https://raw.githubusercontent.com/alecthw/chnlist/release/mosdns/whitelist.list
curl -kL --retry 3 --connect-timeout 3 -o feeds/luci/applications/luci-app-mosdns/root/etc/mosdns/rule/Country.mmdb https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb

# replace mosdns
rm -rf feeds/packages/net/mosdns
svn co https://github.com/sbwml/luci-app-mosdns/trunk/mosdns feeds/packages/net/mosdns
rm -rf feeds/packages/net/mosdns/patches
# use fork repo before PR accepted
sed -i 's/^PKG_VERSION.*/PKG_VERSION:=fa4996c/g' feeds/packages/net/mosdns/Makefile
sed -i 's#IrineSistiana/mosdns/tar#alecthw/mosdns/tar#g' feeds/packages/net/mosdns/Makefile
sed -i 's#v$(PKG_VERSION)#$(PKG_VERSION)#g' feeds/packages/net/mosdns/Makefile
sed -i 's/^PKG_HASH.*/PKG_HASH:=skip/g' feeds/packages/net/mosdns/Makefile

# add luci-app-openclash
rm -rf package/luci-app-openclash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash
# download latest clash meta core
mkdir -p package/luci-app-openclash/root/etc/openclash/core
clash_meta_version=$(curl -kLs "https://api.github.com/repos/MetaCubeX/Clash.Meta/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
echo "clash_meta_version: ${clash_meta_version}"
curl -kL --retry 3 --connect-timeout 3 -o package/luci-app-openclash/root/etc/openclash/core/clash_meta.gz https://github.com/MetaCubeX/Clash.Meta/releases/latest/download/clash.meta-linux-arm64-${clash_meta_version}.gz
gzip -d package/luci-app-openclash/root/etc/openclash/core/clash_meta.gz
chmod 755 package/luci-app-openclash/root/etc/openclash/core/clash_meta

# add other app
rm -rf package/luci-app-control-timewol package/luci-app-control-webrestriction package/luci-app-control-weburl package/luci-app-fileassistant package/luci-app-filebrowser package/luci-app-nginx-pingos
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-control-timewol package/luci-app-control-timewol
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-control-webrestriction package/luci-app-control-webrestriction
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-control-weburl package/luci-app-control-weburl
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-fileassistant package/luci-app-fileassistant
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-filebrowser package/luci-app-filebrowser
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-nginx-pingos package/luci-app-nginx-pingos
