#!/bin/bash
export RELEASE="2.2.1"


wget https://github.com/prometheus/prometheus/releases/download/v${RELEASE}/prometheus-${RELEASE}.linux-amd64.tar.gz


tar xvf prometheus-${RELEASE}.linux-amd64.tar.gz

cd prometheus-${RELEASE}.linux-amd64/


groupadd --system prometheus

useradd -s /sbin/nologin -r -g prometheus prometheus

mkdir -p /etc/prometheus/{rules,rules.d,files_sd}  /var/lib/prometheus

cp prometheus promtool /usr/local/bin/

cp -r consoles/ console_libraries/ /etc/prometheus/


cat <<EOF >> /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus systemd service unit
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries \
--web.listen-address=0.0.0.0:9090

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >> /etc/prometheus/prometheus.yml

# Global config
global: 
  scrape_interval: 15s # Set the scrape interval to every 15 seconds.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. 
  scrape_timeout: 15s # scrape_timeout is set to the global default (10s).

# A scrape configuration containing exactly one endpoint to scrape:# Here it's Prometheus itself.
scrape_configs:
  - job_name:       'node'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9100']
  - job_name:       'node-2'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
  
EOF




chown -R prometheus:prometheus /etc/prometheus/  /var/lib/prometheus/

chmod -R 775 /etc/prometheus/ /var/lib/prometheus/


systemctl start prometheus

systemctl enable prometheus