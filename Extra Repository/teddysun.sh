#!/bin/bash
# https://github.com/teddysun/lcmp/blob/master/lcmp.sh 修改而来

check_sys() {
    local value="$1"
    local release=''
    if [ -f /etc/redhat-release ]; then
        release="rhel"
    elif grep -Eqi "debian" /etc/issue; then
        release="debian"
    elif grep -Eqi "ubuntu" /etc/issue; then
        release="ubuntu"
    elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
        release="rhel"
    elif grep -Eqi "debian" /proc/version; then
        release="debian"
    elif grep -Eqi "ubuntu" /proc/version; then
        release="ubuntu"
    elif grep -Eqi "centos|red hat|redhat" /proc/version; then
        release="rhel"
    fi
    if [ "${value}" == "${release}" ]; then
        return 0
    else
        return 1
    fi
}

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

get_rhelversion() {
    if check_sys rhel; then
        local version
        local code=$1
        local main_ver
        version=$(get_opsy)
        main_ver=$(echo "${version}" | grep -oE "[0-9.]+")
        if [ "${main_ver%%.*}" == "${code}" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

get_debianversion() {
    if check_sys debian; then
        local version
        local code=$1
        local main_ver
        version=$(get_opsy)
        main_ver=$(echo "${version}" | grep -oE "[0-9.]+")
        if [ "${main_ver%%.*}" == "${code}" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

get_ubuntuversion() {
    if check_sys ubuntu; then
        local version
        local code=$1
        version=$(get_opsy)
        if echo "${version}" | grep -q "${code}"; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Check user
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

# Check OS
if  ! get_rhelversion 9 &&
    ! get_debianversion 12 &&
    ! get_ubuntuversion 24.04; then
    echo "${CFAILURE}Not supported OS, please change OS to Enterprise Linux 9+ or Debian 12+ or Ubuntu 24.04+ and try again.${CEND}"
    exit 1
fi

if check_sys rhel; then
    yum install -yq yum-utils epel-release crb
    yum-config-manager --enable epel crb
    yum install -y https://dl.lamp.sh/linux/rhel/el9/x86_64/teddysun-release-1.0-1.el9.noarch.rpm
    yum install -y https://dl.lamp.sh/shadowsocks/rhel/el9/x86_64/teddysun-release-1.0-1.el9.noarch.rpm
    yum makecache
    yum install -yq vim tar zip unzip net-tools bind-utils screen wget mtr iftop htop jq tree
    yum install -yq libnghttp2 libnghttp2-devel
    yum install -yq curl libcurl libcurl-devel
    if [ -s "/etc/selinux/config" ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's@^SELINUX.*@SELINUX=disabled@g' /etc/selinux/config
        setenforce 0
        _info "Disable SElinux completed"
    fi
    if [ -s "/etc/motd.d/cockpit" ]; then
        rm -f /etc/motd.d/cockpit
        _info "Delete /etc/motd.d/cockpit completed"
    fi
elif check_sys debian || check_sys ubuntu; then
    apt-get update
    apt-get -yq install lsb-release ca-certificates apt-transport-https curl gnupg dpkg
    curl -fsSL https://dl.lamp.sh/shadowsocks/DEB-GPG-KEY-Teddysun | gpg --dearmor --yes -o /usr/share/keyrings/deb-gpg-key-teddysun.gpg
    chmod a+r /usr/share/keyrings/deb-gpg-key-teddysun.gpg
    local repo_uri
    if check_sys debian; then
        repo_uri="https://dl.lamp.sh/shadowsocks/debian/"
    else
        repo_uri="https://dl.lamp.sh/shadowsocks/ubuntu/"
    fi
    cat > '/etc/apt/sources.list.d/teddysun.sources' << EOF
Types: deb
URIs: ${repo_uri}
Suites: $(lsb_release -sc)
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/deb-gpg-key-teddysun.gpg
EOF
    apt-get update
    apt-get -yq install vim tar zip unzip net-tools bind9-utils screen git wget mtr iftop htop jq tree
fi
