#!/usr/bin/bash

set -euo pipefall

echo "== Updating system =="
sudo pacman -Syu --noconfirm

echo "== Installing Packages using Pacman =="
sudo pacman -S --needed --noconfirm  - < packages.txt
