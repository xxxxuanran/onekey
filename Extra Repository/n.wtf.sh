#!/bin/bash

# Check user
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

curl -fsSL https://n.wtf/public.key | gpg --dearmor > /usr/share/keyrings/n.wtf.gpg
chmod a+r /usr/share/keyrings/n.wtf.gpg
cat > '/etc/apt/sources.list.d/n.wtf.sources' << EOF
Types: deb
URIs: https://mirror-cdn.xtom.com/sb/nginx/
Suites: $(lsb_release -sc)
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/n.wtf.gpg
EOF
apt-get update
