# Development Containers

This directory contains configurations for **real Debian containers** using systemd-nspawn. These containers run actual Debian Trixie with `apt`, `dpkg`, and traditional Linux package management.

## Available Containers

### 1. **Basic Debian Container** (`debian-container.nix`)
- Minimal Debian Trixie setup
- Essential packages (git, vim, python3, etc.)
- User: `debian` (password: `debian`)
- Command: `debian-container`

### 2. **Python Development Container** (`debian-python-dev-container.nix`)
- Full Python development environment
- Multiple Python versions, uv package manager
- Development tools (vim, neovim, tmux, etc.)
- Database clients (PostgreSQL, MySQL, SQLite, Redis)
- Node.js for web development
- File sharing with host via bind mounts
- User: `debian` (password: `debian`)
- Command: `debian-python-dev`

### 3. **Manual Setup Script** (`setup-debian-container.sh`)
- Standalone script to create Debian containers
- Uses debootstrap directly
- For manual container management

## Quick Start

### Python Development Container

1. **Add to your NixOS configuration:**
   ```nix
   # In flake.nix extraModules:
   ./modules/dev-containers/debian-python-dev-container.nix
   ```

2. **Rebuild NixOS:**
   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-configuration/#deck
   ```

3. **Create and setup container:**
   ```bash
   debian-python-dev create
   debian-python-dev setup
   ```

4. **Create a Python project:**
   ```bash
   debian-python-dev create-project my-web-app
   ```

5. **Start developing:**
   ```bash
   debian-python-dev shell
   cd .python/my-web-app
   uv venv && source .venv/bin/activate
   uv pip install flask
   ```

## Container Features

### **Real Debian Environment**
- Actual Debian Trixie with full package ecosystem
- Use `apt install` to add packages
- Traditional Linux development experience
- Full systemd and service management

### **File Sharing**
- Host `/home/luiz/.python/` → Container `/home/debian/.python/`
- Host `/home/luiz/.cache/uv/` → Container `/home/debian/.cache/uv/`
- Edit files on host, run in container
- Persistent storage across container restarts

### **Modern Python Development**
- **uv**: Ultra-fast Python package installer (10-100x faster than pip)
- **pyproject.toml**: Modern Python project configuration
- **Multiple Python versions**: Test compatibility easily
- **Virtual environments**: Isolated dependencies per project

## Commands Reference

### Python Development Container
```bash
debian-python-dev create          # Create new container
debian-python-dev setup           # Install development environment
debian-python-dev start           # Start with bind mounts
debian-python-dev shell           # Get shell in container
debian-python-dev create-project  # Create new Python project
debian-python-dev status          # Show container info
debian-python-dev remove          # Remove container completely
```

### Basic Debian Container
```bash
debian-container create    # Create new container
debian-container setup     # Install basic packages
debian-container start     # Start container
debian-container shell     # Get shell in container
debian-container status    # Show container info
debian-container remove    # Remove container
```

## Project Structure

When you create Python projects, they're organized like this:

```
/home/luiz/.python/
├── my-web-app/
│   ├── pyproject.toml    # Project configuration
│   ├── main.py          # Main application
│   ├── README.md        # Documentation
│   └── .venv/           # Virtual environment (created by uv)
├── data-analysis/
│   ├── pyproject.toml
│   ├── analysis.py
│   └── .venv/
└── flask-api/
    ├── pyproject.toml
    ├── app.py
    └── .venv/
```

## Why Debian Containers?

### **Advantages over NixOS containers:**
- **Familiar**: Traditional Linux package management with `apt`
- **Ecosystem**: Full access to Debian package repository
- **Isolation**: Keep development mess separate from clean NixOS host
- **Flexibility**: Install any Debian package without NixOS configuration
- **Learning**: Practice Linux administration safely

### **Use cases:**
- **Python development**: Multiple projects with conflicting dependencies
- **Web development**: Test different package versions
- **Learning**: Experiment with Linux without affecting host
- **Legacy software**: Run older packages not available in NixOS
- **Packaging**: Build packages for Debian-based distributions

## Container Management

### Starting Containers
```bash
# Manual start with shell access
sudo systemd-nspawn -D /var/lib/machines/debian-trixie

# Start as a service (runs in background)
sudo systemctl start systemd-nspawn@debian-trixie

# Connect to running service
sudo machinectl shell debian-trixie
```

### Stopping Containers

#### **Method 1: From Inside Container**
```bash
# If you're inside the container, just exit
exit
# or press Ctrl+D
```

#### **Method 2: Escape Sequence (Recommended)**
```bash
# Press Ctrl+] three times within 1 second
# (This is the systemd-nspawn escape sequence)
```

#### **Method 3: Using machinectl (Most Reliable)**
```bash
# Terminate the container gracefully
sudo machinectl terminate debian-trixie

# Or force stop it
sudo machinectl poweroff debian-trixie

# Check if it's still running
sudo machinectl list
```

#### **Method 4: Using systemctl (if running as service)**
```bash
# Stop the container service
sudo systemctl stop systemd-nspawn@debian-trixie

# Check status
sudo systemctl status systemd-nspawn@debian-trixie
```

#### **Method 5: Find and Kill Process**
```bash
# Find the systemd-nspawn process
ps aux | grep systemd-nspawn | grep debian-trixie

# Kill it (replace PID with actual process ID)
sudo kill <PID>

# Or force kill if needed
sudo kill -9 <PID>
```

### Container Status
```bash
# List all running containers
sudo machinectl list

# Show detailed status
sudo machinectl status debian-trixie

# Check if container exists
ls -la /var/lib/machines/
```

## Troubleshooting

### Container won't start:
```bash
# Check if container exists
debian-python-dev status

# Remove and recreate
debian-python-dev remove
debian-python-dev create
debian-python-dev setup
```

### Missing packages in container:
```bash
# Get shell and install with apt
debian-python-dev shell
sudo apt update
sudo apt install package-name
```

### File permission issues:
```bash
# Fix ownership on host
sudo chown -R luiz:users /home/luiz/.python/
```

### Container takes too much space:
```bash
# Clean package cache inside container
debian-python-dev shell
sudo apt clean
sudo apt autoremove
```

## Advanced Usage

### Custom package installation:
```bash
# Inside container
sudo apt install postgresql-server-dev-all  # For psycopg2
sudo apt install libmysqlclient-dev         # For MySQL
sudo apt install redis-server               # Local Redis
```

### Multiple Python versions:
```bash
# Inside container
sudo apt install python3.9 python3.10 python3.11 python3.12
python3.11 -m venv .venv311
python3.12 -m venv .venv312
```

### Container networking:
```bash
# Start with custom networking
sudo systemd-nspawn -D /var/lib/machines/debian-python-dev --network-veth
```

For more detailed workflows, see `python-dev-workflow-demo.md`.