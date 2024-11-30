#!/bin/bash

# Check user
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

curl -fsSL https://dl.xanmod.org/archive.key | gpg --dearmor --yes -vo /usr/share/keyrings/xanmod-archive-keyring.gpg
chmod a+r /usr/share/keyrings/xanmod-archive-keyring.gpg
cat > '/etc/apt/sources.list.d/xanmod-release.sources' << EOF
Types: deb
URIs: http://deb.xanmod.org
Suites: releases
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/xanmod-archive-keyring.gpg
EOF
apt-get update
wget https://dl.xanmod.org/check_x86-64_psabi.sh
chmod a+x check_x86-64_psabi.sh
./check_x86-64_psabi.sh
