# 斐讯N1盒子 OpenWRT 超精简固件

[![Build OpenWrt](https://github.com/alecthw/openwrt-n1/actions/workflows/build-openwrt.yml/badge.svg)](https://github.com/alecthw/openwrt-n1/actions/workflows/build-openwrt.yml)
[![Use Releases file to Packaging](https://github.com/alecthw/openwrt-n1/actions/workflows/use-releases-file-to-packaging.yml/badge.svg)](https://github.com/alecthw/openwrt-n1/actions/workflows/use-releases-file-to-packaging.yml)

功能专一，只为旁路，极度精简，稳定运行！

每周五自动构建新版本。

默认IP: `10.21.2.1/20`，注意下掩码是`20`，不是`24`！！！这个Sorry下，为了自用方便这么设置的。

密码: `password`，设计默认密码的都是这个！！！

IP掩码看不懂的，建议直接用以下命令行修改即可：

```bash
# N1一般只作为旁路路由，IP不建议设置1，防止和主路由冲突！
uci set network.lan.ipaddr='192.168.1.2'
uci set network.lan.netmask='255.255.255.0'
uci commit network
```

## 特性

默认配置DHCPv6 Client接口`lan6`。

默认配置好了AdGuardHome、mosdns和openclash（或ssrp）的搭配运行配置。

- AdGuardHome的监控和广告过滤能力
  - 由于开启了路由本地代理，可以开启AdGuardHome的`浏览安全`和`家长监控`
- mosdns的分流能力，并启用了缓存
- 使用openclash时，dns必须经过openclash，否则Mapping机制问题导致分流可能异常

**以下部分仅仅是说明，无需手动设置。**

修改了dnsmasq的默认端口号，用AdGuardHome监听53端口作为默认的DNS解析，这样可以监控的各个终端的dns请求。dnsmasq作为AdGuardHome的上游，方便搭配其他各种科学上网插件使用。


```
AdGuardHome[53, no cache] --> dnsmasq[3553, no cache]
```

### 配合openclash

openclash中DNS设置`使用Dnsmasq转发`，当openclash启动时会修改dnsmasq配置，openclash作为dnsmasq的上游。同时设置openclash复写设置中，启用自定义上游DNS服务器，并指定mosdns为唯一上游。mosdns使用[alecthw修改版](https://github.com/alecthw/mosdns)，支持MMDB GeoIP匹配。

```
AdGuardHome[53, no cache] --> dnsmasq[3553, no cache] --> openclash[7874] --> mosdns[5335, cache]
```

### 配合ssrp

如果使用ssrp，ssrp设置`使用本机端口为5335的DNS服务`，

```
AdGuardHome[53, no cache] --> dnsmasq[3553, no cache] --> mosdns[5335, cache]
```

## 使用LEDE源码

[coolsnowwolf's code](https://github.com/coolsnowwolf/lede)

### 主要的插件应用

详细参考: [config](config)

- luci-app-adguardhome
- luci-app-amlogic
- luci-app-ddns
- luci-app-frpc
- luci-app-mosdns
- luci-app-openclash
- luci-app-samba4
- luci-app-smartdns
- luci-app-ssr-plus
- luci-app-tcpdump
- luci-app-zerotier

## 链接

- [coolsnowwolf lede](https://github.com/coolsnowwolf/lede)
- [breakings openwrt](https://github.com/breakings/OpenWrt)
- [Flippy's script](https://github.com/unifreq/openwrt_packit)
- [晶晨宝盒](https://github.com/ophub/luci-app-amlogic)
