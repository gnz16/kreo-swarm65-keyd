#!/bin/bash
# Installs the keyd remaps in config/ to /etc/keyd/ and reloads the daemon.
# Requires keyd (https://github.com/rvaiya/keyd) already installed.
set -euo pipefail

if ! command -v keyd &>/dev/null; then
  echo "keyd not found. Install it first: https://github.com/rvaiya/keyd" >&2
  exit 1
fi

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo cp "$dir/config/kreo-swarm65.conf" /etc/keyd/kreo-swarm65.conf
sudo cp "$dir/config/kreo-swarm65-wired.conf" /etc/keyd/kreo-swarm65-wired.conf
sudo cp "$dir/config/kreo-swarm65-wired-consumer.conf" /etc/keyd/kreo-swarm65-wired-consumer.conf

sudo keyd check /etc/keyd/kreo-swarm65.conf /etc/keyd/kreo-swarm65-wired.conf /etc/keyd/kreo-swarm65-wired-consumer.conf

# `keyd reload` has a known SEGV failure mode on some setups after a config
# change; `systemctl restart` is the reliable way to apply it.
sudo systemctl restart keyd

echo "Installed. Verify with: sudo keyd monitor"
