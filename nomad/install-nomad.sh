#!/bin/sh

set -e

sudo chown root:root nomad
sudo mv nomad /usr/local/bin/
nomad version

nomad -autocomplete-uninstall || true
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad

sudo mkdir --parents /opt/nomad

sudo touch /etc/systemd/system/nomad.service

sudo tee /etc/systemd/system/nomad.service <<EOF 
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF