# 最优设置

## 网络配置

### Netplan
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 1.0.0.1/24
        - 2001:ff:ff:ff::1/64
      routes:
        - to: default
          via: 1.1.1.1
          on-link: true
        - to: default
          via: 2001:ff:ff::1
          on-link: true # 当网关不属于当前网络时需要设置
      nameservers:
        addresses:
          - 1.1.1.1
          - 2606:4700:4700::1111
      match:
        macaddress: 2a:d0:33:43:85:45
      set-name: eth0
```

### BBRv3
```shell
cat >> /etc/sysctl.d/99-bbr.conf <<EOF
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
EOF
sysctl -p --system
```

### Random IPv6
```shell
cat >> /etc/sysctl.d/99-random-ipv6.conf <<EOF
net.ipv6.ip_nonlocal_bind=1
EOF
sysctl -p --system
apt install ndppd
systemctl stop ndppd
cat >> /etc/ndppd.conf <<EOF
proxy eth0 {
    router no
    timeout 500
    ttl 30000
    rule 2001::/64 {
        static
    }
}
EOF
systemctl start ndppd
systemctl enable ndppd
```
持久化则在 netplan route 中添加
```yaml
routes:
  - to: 2001::/64
    type: local
```
