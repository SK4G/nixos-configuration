#!/usr/bin/env bash
# Setup Debian Trixie systemd-nspawn container

set -e

CONTAINER_NAME="debian-trixie"
CONTAINER_PATH="/var/lib/machines/$CONTAINER_NAME"
TEMP_DIR="/tmp/debian-setup"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exec sudo "$0" "$@"
fi

echo "Setting up Debian Trixie container..."

# Install required tools
echo "Installing required tools..."
if command -v nix-shell >/dev/null 2>&1; then
    echo "Using nix-shell to get required tools..."
    nix-shell -p p7zip curl wget --run "echo 'Tools available in nix-shell'"
else
    echo "Please ensure p7zip and curl are available"
fi

# Create temporary directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Create Debian Trixie container
echo "Creating Debian Trixie container..."

# Create container directory
mkdir -p "$CONTAINER_PATH"

# Create Debian Trixie rootfs using debootstrap
echo "Creating Debian Trixie rootfs using debootstrap..."

# Check if debootstrap is available
if ! command -v debootstrap >/dev/null 2>&1; then
    echo "Installing debootstrap..."
    if command -v nix-shell >/dev/null 2>&1; then
        echo "Using nix-shell to get debootstrap..."
        nix-shell -p debootstrap --run "debootstrap --include=coreutils,bash,util-linux,systemd,systemd-sysv trixie $CONTAINER_PATH http://deb.debian.org/debian"
    else
        echo "Please install debootstrap first"
        exit 1
    fi
else
    # Use system debootstrap
    debootstrap --include=coreutils,bash,util-linux,systemd,systemd-sysv trixie "$CONTAINER_PATH" http://deb.debian.org/debian
fi

# Configure the container
echo "Configuring container..."

# Set hostname
cat > "$CONTAINER_PATH/etc/hostname" << EOF
debian-container
EOF

# Set up sources.list for Trixie
cat > "$CONTAINER_PATH/etc/apt/sources.list" << EOF
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware

deb http://deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
EOF

# Set up proper PATH in /etc/environment
cat > "$CONTAINER_PATH/etc/environment" << EOF
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF

# Set up proper PATH in root's .bashrc
cat >> "$CONTAINER_PATH/root/.bashrc" << EOF

# Ensure /usr/sbin is in PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF

# Create a setup script to run inside the container
cat > "$CONTAINER_PATH/root/debian-setup.sh" << 'EOF'
#!/bin/bash
# Debian setup script

# Set PATH to include /usr/sbin
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "Setting up Debian environment..."

# Update package lists
apt-get update

# Install essential packages
apt-get install -y \
    curl \
    wget \
    git \
    nano \
    htop \
    systemd \
    systemd-sysv \
    dbus \
    sudo \
    openssh-server \
    python3 \
    python3-pip \
    build-essential

# Create debian user
useradd -m -s /bin/bash -G sudo debian
echo "debian:debian" | chpasswd

# Set up proper PATH for debian user
mkdir -p /home/debian
cat >> /home/debian/.bashrc << 'BASHRC_EOF'

# Ensure /usr/sbin is in PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
BASHRC_EOF

chown debian:debian /home/debian/.bashrc

# Enable SSH
systemctl enable ssh

# Set up a simple motd
cat > /etc/motd << 'MOTD_EOF'
Debian Trixie Container
- Minimal Debian setup
- User: debian (password: debian)
- SSH enabled

MOTD_EOF

echo "Debian setup completed!"
echo "Default user: debian"
echo "Default password: debian"
EOF

chmod +x "$CONTAINER_PATH/root/debian-setup.sh"

# Create systemd service file (skip on NixOS read-only filesystem)
if [ -w "/etc/systemd/system/" ]; then
    cat > "/etc/systemd/system/systemd-nspawn@$CONTAINER_NAME.service" << EOF
[Unit]
Description=Container %i
Documentation=man:systemd-nspawn(1)
PartOf=machines.target
Before=machines.target
After=network.target systemd-resolved.service
RequiresMountsFor=/var/lib/machines

[Service]
ExecStart=systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest --network-veth -U --settings=override --machine=%i
KillMode=mixed
Type=notify
RestartForceExitStatus=133
SuccessExitStatus=133
Slice=machine.slice
Delegate=yes
TasksMax=16384
WantedBy=machines.target

[Install]
WantedBy=machines.target
EOF
    echo "Systemd service file created."
else
    echo "Skipping systemd service creation (read-only filesystem)."
    echo "On NixOS, you can manage containers through configuration.nix instead."
fi

echo "Container setup complete!"
echo ""
echo "To start the container and run initial setup:"
echo "  sudo systemd-nspawn -D $CONTAINER_PATH"
echo "  # Inside container, run: /root/debian-setup.sh"
echo ""
echo "To start as a service:"
echo "  sudo systemctl start systemd-nspawn@$CONTAINER_NAME"
echo "  sudo systemctl enable systemd-nspawn@$CONTAINER_NAME"
echo ""
echo "To get a shell in the running container:"
echo "  sudo machinectl shell $CONTAINER_NAME"
echo ""
echo "Container location: $CONTAINER_PATH"

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "Setup script completed!"