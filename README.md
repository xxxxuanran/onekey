# onekey

## Basic Security Setting

### SSH Key Management
```shell
ssh-keygen -a 1000 -t ed25519 -f ./id_ed25519
cat ./id_ed25519.pub | tee -a /root/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
passwd -d root
rm -f /etc/ssh/sshd_config.d/01-permitrootlogin.conf
rm -f /etc/ssh/sshd_config.d/50-cloud-init.conf
cat > '/etc/ssh/sshd_config.d/50-cloud-init.conf' << __EOF__
LogLevel VERBOSE
MaxAuthTries 5
PermitRootLogin prohibit-password
PasswordAuthentication no
PermitEmptyPasswords no
__EOF__
systemctl restart sshd
```

## Package Repository Configuration

### APT Package Manager

#### Basic
```shell
mkdir -p /etc/apt/mirrors
mkdir -p /etc/apt/sources.list.d/bak
mv /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/bak
```

#### Ubuntu
```shell
echo "http://azure.archive.ubuntu.com/ubuntu/ priority:5" > /etc/apt/mirrors/ubuntu.list
echo "http://archive.ubuntu.com/ubuntu/" >> /etc/apt/mirrors/ubuntu.list
echo "http://azure.archive.ubuntu.com/ubuntu" > /etc/apt/mirrors/ubuntu-security.list
cat > '/etc/apt/sources.list.d/ubuntu.sources' << __EOF__
Types: deb
URIs: mirror+file:///etc/apt/mirrors/ubuntu.list
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: mirror+file:///etc/apt/mirrors/ubuntu-security.list
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
__EOF__
cat > /etc/apt/sources.list << __EOF__
# Ubuntu sources have moved to the /etc/apt/sources.list.d/ubuntu.sources
# file, which uses the deb822 format. Use deb822-formatted .sources files
# to manage package sources in the /etc/apt/sources.list.d/ directory.
# See the sources.list(5) manual page for details.
__EOF__
```

### Common Softwore
```shell
apt clean all
apt update
apt upgrade -y
apt install -y \
build-essential gnupg dpkg apt-transport-https lsb-release ca-certificates \
sudo neofetch git curl wget vim nano openssl net-tools dnsutils cron mtr \
htop btop nload python3-pip python3-venv python3-full pipx iftop ufw unzip \
```

### Dnf Package Manager

#### Basic
两个主流发行版都使用 Fastly CDN，直接使用源站点即可。使用 Mirror 可能会被分配到无速度的节点。
```shell
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://|baseurl=https://|g' \
    -e 's|^#baseurl=https://|baseurl=https://|g' \
    -i.bak \
    /etc/yum.repos.d/rocky*.repo \
    /etc/yum.repos.d/almalinux*.repo 2>/dev/null
```

## Extra Repository
