cd /tmp/ && wget https://ghproxy.com/https://github.com/prometheus/node_exporter/releases/download/v1.2.0/node_exporter-1.2.0.linux-amd64.tar.gz
tar -xzf node_exporter-1.2.0.linux-amd64.tar.gz && mv node_exporter-1.2.0.linux-amd64/node_exporter /usr/local/sbin/
chmod +x /usr/local/sbin/node_exporter
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=node_exporter
Documentation=https://prometheus.io/
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/sbin/node_exporter
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl enable node_exporter.service
systemctl start node_exporter.service