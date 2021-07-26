#!/bin/bash
cd /tmp/ && wget https://github.com/prometheus/prometheus/releases/download/v2.28.1/prometheus-2.28.1.linux-amd64.tar.gz
tar -xzf prometheus-2.28.1.linux-amd64.tar.gz && mv prometheus-2.28.1.linux-amd64 /usr/local/prometheus
ln -s /usr/local/prometheus/prometheus /usr/bin/prometheus
ln -s /usr/local/prometheus/prometheus.yml /etc/prometheus.yml

cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
ExecStart=/usr/bin/prometheus --config.file=/etc/prometheus.yml --storage.tsdb.retention.time=7d --web.enable-lifecycle
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable prometheus.service
systemctl start prometheus.service
