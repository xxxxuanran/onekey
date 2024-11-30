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
    yum install -yq caddy
elif check_sys debian || check_sys ubuntu; then
    curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    chmod a+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    cat > '/etc/apt/sources.list.d/caddy-stable.sources' << EOF
Types: deb
URIs: https://dl.cloudsmith.io/public/caddy/stable/deb/debian/
Suites: any-version
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/caddy-stable-archive-keyring.gpg
EOF
    apt-get update
fi
