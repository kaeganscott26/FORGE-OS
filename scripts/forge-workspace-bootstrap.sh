#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "🚀 Starting Ultimate Mixed Distribution Workspace Setup"
echo "========================================="

# ----------------------------------------------------
# 1. GARUDA LINUX MIRRORS & REPOSITORIES (Chaotic-AUR)
# ----------------------------------------------------
echo "📦 Setting up Garuda Linux Mirrors & Chaotic-AUR..."

# Receive and sign the chaotic-aur primary keys
sudo pacman-key --recv-key 3056513887B78AEB --keyserver ://ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

# Install the official Garuda/Chaotic keyring and network mirrorlist directly
sudo pacman -U --noconfirm 'https://chaotic.cx' \
                           'https://chaotic.cx'

# Append the Chaotic-AUR repository to your Pacman config safely if not already present
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    sudo tee -a /etc/pacman.conf << 'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
fi

# Synchronize host databases and grab rankers used by Garuda
sudo pacman -Syu --noconfirm reflector rate-mirrors

# ----------------------------------------------------
# 2. NIXOS / NIX PACKAGE MANAGER INTEGRATION
# ----------------------------------------------------
echo "❄️ Installing Nix Package Manager (Multi-user)..."

# Installs multi-user Nix with systemd service integrations automatically
if ! command -v nix &> /dev/null; then
    curl -L https://nixos.org | sh -s -- --daemon --yes
    # Source the environment profile for immediate use in this script session
    if [ -f /etc/profile.d/nix.sh ]; then
        source /etc/profile.d/nix.sh
    fi
else
    echo "Nix is already installed."
fi

# ----------------------------------------------------
# 3. KALI LINUX ENVIRONMENT (Safe Tool Access via Distrobox)
# ----------------------------------------------------
echo "🐉 Deploying Kali Linux Container Sandbox..."

# Distrobox uses podman/docker to let you run a full Kali userspace with local display access
sudo pacman -S --noconfirm distrobox podman
sudo systemctl enable --now podman.socket

# Create a permanent Kali workspace container tracking official Kali repositories
distrobox create --image docker.io/kalilinux/kali-rolling --name kali-workspace --yes

echo "========================================="
echo "✅ Bootstrap Complete! Read instructions below to use."
echo "========================================="
