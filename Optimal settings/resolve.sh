#!/bin/bash

if systemctl status systemd-resolved >/dev/null 2>&1; then
    sed -e 's/^#\?DNSStubListener=.*/DNSStubListener=no/' \
        -e 's/^#\?Cache=.*/Cache=no/' \
        -e 's/^#\?LLMNR=.*/LLMNR=no/' \
        -i.bak /etc/systemd/resolved.conf
    systemctl restart systemd-resolved
    echo "Set systemd-resolved completed"
fi
