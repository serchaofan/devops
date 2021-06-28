#!/bin/bash
EXPORTER_PASS="Exporter@2021"

cd /tmp/ && wget https://ghproxy.com/https://github.com/prometheus/mysqld_exporter/releases/download/v0.13.0/mysqld_exporter-0.13.0.linux-amd64.tar.gz
tar -xzf mysqld_exporter-0.13.0.linux-amd64.tar.gz && mv mysqld_exporter-0.13.0.linux-amd64/mysqld_exporter /usr/local/sbin/
cat <<EOF > /etc/systemd/system/mysqld_exporter.service
[Unit]
Description=mysqld_exporter
After=network.target

[Service]
Type=simple
Environment=DATA_SOURCE_NAME=exporter:${EXPORTER_PASS}@unix(/data/mysql/3306/mysql.sock)/
ExecStart=/usr/local/sbin/mysqld_exporter --web.listen-address=:9104
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable mysqld_exporter.service
systemctl start mysqld_exporter.service