# modules/dev-containers/debian-python-dev-container.nix
# Configuration for managing Debian Python development containers
{ config, lib, pkgs, ... }:

{
  # Enable systemd-nspawn for containers
  systemd.services."systemd-nspawn@" = {
    enable = true;
  };

  # Create host directories for bind mounts
  system.activationScripts.createDebianPythonDirs = ''
    mkdir -p /home/luiz/.python
    mkdir -p /home/luiz/.cache/pip
    mkdir -p /home/luiz/.cache/uv
    chown -R luiz:users /home/luiz/.python 2>/dev/null || true
    chown -R luiz:users /home/luiz/.cache 2>/dev/null || true
  '';

  # Python development container management
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "debian-python-dev" ''
      CONTAINER_NAME="debian-python-dev"
      CONTAINER_PATH="/var/lib/machines/$CONTAINER_NAME"
      
      case "$1" in
        start)
          if [ ! -d "$CONTAINER_PATH" ]; then
            echo "Container not found. Run 'debian-python-dev create' first."
            exit 1
          fi
          echo "Starting Debian Python development container with bind mounts..."
          sudo systemd-nspawn -D "$CONTAINER_PATH" \
            --boot \
            --network-veth \
            --bind=/home/luiz/.python:/home/debian/.python \
            --bind=/home/luiz/.cache/pip:/home/debian/.cache/pip \
            --bind=/home/luiz/.cache/uv:/home/debian/.cache/uv \
            --bind=/home/luiz/.ssh:/home/debian/.ssh:ro \
            --bind=/home/luiz/.gitconfig:/home/debian/.gitconfig:ro
          ;;
        shell)
          if [ ! -d "$CONTAINER_PATH" ]; then
            echo "Container not found. Run 'debian-python-dev create' first."
            exit 1
          fi
          echo "Getting shell in Debian Python container..."
          sudo systemd-nspawn -D "$CONTAINER_PATH" \
            --bind=/home/luiz/.python:/home/debian/.python \
            --bind=/home/luiz/.cache/pip:/home/debian/.cache/pip \
            --bind=/home/luiz/.cache/uv:/home/debian/.cache/uv \
            --bind=/home/luiz/.ssh:/home/debian/.ssh:ro \
            --bind=/home/luiz/.gitconfig:/home/debian/.gitconfig:ro
          ;;
        create)
          if [ -d "$CONTAINER_PATH" ]; then
            echo "Container already exists at $CONTAINER_PATH"
            exit 1
          fi
          echo "Creating Debian Python development container..."
          sudo mkdir -p "$CONTAINER_PATH"
          
          # Use debootstrap to create Debian rootfs with essential packages
          if command -v debootstrap >/dev/null 2>&1; then
            sudo debootstrap --include=coreutils,bash,util-linux,systemd,systemd-sysv trixie "$CONTAINER_PATH" http://deb.debian.org/debian
          else
            echo "Using nix-shell to get debootstrap..."
            nix-shell -p debootstrap --run "sudo debootstrap --include=coreutils,bash,util-linux,systemd,systemd-sysv trixie $CONTAINER_PATH http://deb.debian.org/debian"
          fi
          
          # Configure the container for Python development
          echo "Configuring Python development environment..."
          
          # Set hostname
          echo "debian-python-dev" | sudo tee "$CONTAINER_PATH/etc/hostname" > /dev/null
          
          # Configure sources.list
          sudo tee "$CONTAINER_PATH/etc/apt/sources.list" > /dev/null << 'EOF'
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware

deb http://deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
EOF
          
          # Create Python development setup script
          sudo tee "$CONTAINER_PATH/root/python-setup.sh" > /dev/null << 'EOF'
#!/bin/bash
echo "Setting up Debian Python development environment..."

# Update package lists
apt-get update

# Install essential packages
apt-get install -y \
    curl \
    wget \
    git \
    nano \
    vim \
    neovim \
    htop \
    tree \
    tmux \
    systemd \
    systemd-sysv \
    dbus \
    sudo \
    openssh-server \
    coreutils \
    bash-completion \
    util-linux

# Install Python development packages
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools \
    python3-wheel \
    build-essential \
    pkg-config \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev

# Install database packages
apt-get install -y \
    postgresql-client \
    mysql-client \
    sqlite3 \
    redis-tools

# Install Node.js for web development
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# Install uv (fast Python package installer)
curl -LsSf https://astral.sh/uv/install.sh | sh
# Make uv available system-wide
cp /root/.cargo/bin/uv /usr/local/bin/

# Create debian user
useradd -m -s /bin/bash -G sudo debian
echo "debian:debian" | chpasswd

# Set up debian user's environment
sudo -u debian bash << 'USER_SETUP'
cd /home/debian

# Install uv for user
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc

# Create Python development directories
mkdir -p .python
mkdir -p .cache/pip
mkdir -p .cache/uv

# Set up git (will be overridden by bind mount)
git config --global init.defaultBranch main

# Create a sample Python project
mkdir -p .python/sample-project
cd .python/sample-project

cat > pyproject.toml << 'PYPROJECT_EOF'
[project]
name = "sample-project"
version = "0.1.0"
description = "Sample Python project in Debian container"
dependencies = [
    "requests>=2.28.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
PYPROJECT_EOF

cat > main.py << 'MAIN_EOF'
#!/usr/bin/env python3
"""
Sample Python project in Debian container.
"""
import sys

def main():
    print("Hello from Debian Python development container!")
    print(f"Python version: {sys.version}")
    
    try:
        import requests
        print("✓ requests library available")
    except ImportError:
        print("✗ requests library not installed")
        print("Run: uv pip install -e .")

if __name__ == "__main__":
    main()
MAIN_EOF

cat > README.md << 'README_EOF'
# Sample Python Project

This is a sample project created in the Debian Python development container.

## Setup

```bash
# Create virtual environment and install dependencies
uv venv
source .venv/bin/activate
uv pip install -e .

# Run the project
python main.py
```

## Development

- Edit files on the host in `/home/luiz/.python/`
- Run code in the container
- Use `uv` for fast package management
README_EOF

USER_SETUP

# Enable SSH
systemctl enable ssh

# Set up motd
cat > /etc/motd << 'MOTD_EOF'
Debian Python Development Container
- Real Debian Trixie with apt/dpkg
- Python 3.11+ with uv package manager
- User: debian (password: debian)
- SSH enabled

Shared directories:
  Host /home/luiz/.python → Container /home/debian/.python
  Host /home/luiz/.cache/uv → Container /home/debian/.cache/uv

Quick start:
  cd .python/sample-project
  uv venv && source .venv/bin/activate
  uv pip install -e .
  python main.py
MOTD_EOF

echo "Debian Python development container setup completed!"
echo "Default user: debian"
echo "Default password: debian"
echo "Sample project created at: /home/debian/.python/sample-project"
EOF
          
          sudo chmod +x "$CONTAINER_PATH/root/python-setup.sh"
          
          echo "Container created successfully!"
          echo "Run 'debian-python-dev setup' to configure it."
          ;;
        setup)
          if [ ! -d "$CONTAINER_PATH" ]; then
            echo "Container not found. Run 'debian-python-dev create' first."
            exit 1
          fi
          echo "Running Python development setup inside Debian container..."
          sudo systemd-nspawn -D "$CONTAINER_PATH" /root/python-setup.sh
          ;;
        create-project)
          if [ -z "$2" ]; then
            echo "Usage: debian-python-dev create-project <project-name>"
            exit 1
          fi
          PROJECT_NAME="$2"
          PROJECT_DIR="/home/luiz/.python/$PROJECT_NAME"
          
          echo "Creating Python project: $PROJECT_NAME"
          mkdir -p "$PROJECT_DIR"
          
          # Create pyproject.toml
          cat > "$PROJECT_DIR/pyproject.toml" << EOF
[project]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "Python project created in Debian container"
dependencies = [
    # Add your dependencies here
    # "requests>=2.28.0",
    # "flask>=2.2.0",
    # "fastapi>=0.100.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
EOF
          
          # Create main.py
          cat > "$PROJECT_DIR/main.py" << 'EOF'
#!/usr/bin/env python3
"""
Main module for the project.
"""

def main():
    print(f"Hello from {__file__}!")

if __name__ == "__main__":
    main()
EOF
          
          # Create README.md
          cat > "$PROJECT_DIR/README.md" << EOF
# $PROJECT_NAME

Python project created in Debian container.

## Setup

\`\`\`bash
# In the container:
cd .python/$PROJECT_NAME
uv venv
source .venv/bin/activate
uv pip install -e .

# Run the project
python main.py
\`\`\`
EOF
          
          echo "Project created at: $PROJECT_DIR"
          echo "Files created: pyproject.toml, main.py, README.md"
          echo ""
          echo "To work on this project:"
          echo "  1. debian-python-dev shell"
          echo "  2. cd .python/$PROJECT_NAME"
          echo "  3. uv venv && source .venv/bin/activate"
          echo "  4. uv pip install -e ."
          ;;
        remove)
          if [ ! -d "$CONTAINER_PATH" ]; then
            echo "Container not found."
            exit 1
          fi
          echo "Removing Debian Python development container..."
          sudo rm -rf "$CONTAINER_PATH"
          echo "Container removed."
          ;;
        status)
          if [ -d "$CONTAINER_PATH" ]; then
            echo "Container exists at: $CONTAINER_PATH"
            echo "Size: $(sudo du -sh $CONTAINER_PATH | cut -f1)"
            if [ -f "$CONTAINER_PATH/etc/debian_version" ]; then
              echo "Debian version: $(sudo cat $CONTAINER_PATH/etc/debian_version)"
            fi
            echo "Projects in /home/luiz/.python/:"
            ls -la /home/luiz/.python/ 2>/dev/null || echo "  No projects found"
          else
            echo "Container does not exist."
          fi
          ;;
        *)
          echo "Usage: debian-python-dev {create|setup|start|shell|create-project|remove|status}"
          echo ""
          echo "Commands:"
          echo "  create          - Create new Debian Python development container"
          echo "  setup           - Run initial Python development setup"
          echo "  start           - Start container with bind mounts"
          echo "  shell           - Get shell in container with bind mounts"
          echo "  create-project  - Create new Python project"
          echo "  remove          - Remove container completely"
          echo "  status          - Show container and project information"
          echo ""
          echo "Example workflow:"
          echo "  debian-python-dev create"
          echo "  debian-python-dev setup"
          echo "  debian-python-dev create-project my-web-app"
          echo "  debian-python-dev shell"
          echo "  # In container: cd .python/my-web-app && uv venv && source .venv/bin/activate"
          ;;
      esac
    '')
  ];
}