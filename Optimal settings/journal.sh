#!/bin/bash

# 设置 journald 日志存储为 volatile，并限制日志大小为 16M

if systemctl status systemd-journald >/dev/null 2>&1; then
    sed -e 's/^#\?Storage=.*/Storage=volatile/' \
        -e 's/^#\?SystemMaxUse=.*/SystemMaxUse=16M/' \
        -e 's/^#\?RuntimeMaxUse=.*/RuntimeMaxUse=16M/' \
        -i.bak /etc/systemd/journald.conf
    systemctl restart systemd-journald
    echo "Set systemd-journald completed"
fi
