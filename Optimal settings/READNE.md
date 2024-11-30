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