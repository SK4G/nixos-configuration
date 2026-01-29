# modules/dev-containers/ubuntu-lineageos-container.nix
{ config, lib, pkgs, ... }:

{
  # Make debootstrap available on host
  environment.systemPackages = with pkgs; [
    debootstrap

    (writeShellScriptBin "ubuntu-lineageos-dev" ''
      CONTAINER_NAME="ubuntu-lineageos-dev"
      CONTAINER_PATH="/var/lib/machines/$CONTAINER_NAME"

      mkdir -p "$HOME/.lineageos" "$HOME/.ccache" "$HOME/.android" 2>/dev/null || true

      case "$1" in
        create)
          if sudo test -d "$CONTAINER_PATH"; then
            echo "Container already exists."
            exit 1
          fi
          echo "Creating Ubuntu 20.04 container..."

          sudo mkdir -p "$CONTAINER_PATH"

          # Ensure host has resolv.conf
          if [ ! -s /etc/resolv.conf ]; then
            echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
          fi

          # Create a temporary chroot with DNS
          sudo mkdir -p "$CONTAINER_PATH/etc"
          sudo cp /etc/resolv.conf "$CONTAINER_PATH/etc/"

          # Now run debootstrap with verified packages
          if ! sudo ${pkgs.debootstrap}/bin/debootstrap \
            --include=apt,dpkg,bash,coreutils,debianutils,systemd-sysv,sudo,adduser,ca-certificates,findutils,gzip,login,sed,sysvinit-utils,tar,util-linux,procps,netbase,passwd \
            focal "$CONTAINER_PATH" http://archive.ubuntu.com/ubuntu; then
            echo "❌ debootstrap failed. Container may be corrupted."
            echo "Run 'ubuntu-lineageos-dev remove' to clean up and try again."
            exit 1
          fi

          # Clean up resolv.conf
          sudo rm -f "$CONTAINER_PATH/etc/resolv.conf"

          # Basic filesystem setup
          sudo mkdir -p "$CONTAINER_PATH/etc" "$CONTAINER_PATH/tmp"

          # Set UTC timezone to avoid tzdata installation issues
          sudo mkdir -p "$CONTAINER_PATH/etc"
          echo "UTC" | sudo tee "$CONTAINER_PATH/etc/timezone" > /dev/null
          sudo ln -sf /usr/share/zoneinfo/UTC "$CONTAINER_PATH/etc/localtime"

          # Clean up and recreate home directory properly
          sudo rm -rf "$CONTAINER_PATH/home/lineage"
          sudo mkdir -p "$CONTAINER_PATH/home/lineage"
          sudo chown 0:0 "$CONTAINER_PATH/home/lineage"
          sudo chmod 755 "$CONTAINER_PATH/home/lineage"

          # Copy host git config if it exists (simpler approach)
          if [ -f "$HOME/.config/git/config" ]; then
            sudo mkdir -p "$CONTAINER_PATH/home/lineage/.config/git"
            sudo cp "$HOME/.config/git/config" "$CONTAINER_PATH/home/lineage/.config/git/config"
          elif [ -f "$HOME/.gitconfig" ]; then
            sudo cp "$HOME/.gitconfig" "$CONTAINER_PATH/home/lineage/.gitconfig"
          fi

          # Hostname and hosts file for proper resolution
          echo "ubuntu-lineageos-dev" | sudo tee "$CONTAINER_PATH/etc/hostname" > /dev/null
          echo "127.0.0.1 localhost ubuntu-lineageos-dev" | sudo tee "$CONTAINER_PATH/etc/hosts" > /dev/null

          # APT sources (focal + security/updates)
          sudo tee "$CONTAINER_PATH/etc/apt/sources.list" > /dev/null <<'EOF'
deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-security main restricted universe multiverse
EOF

          # Setup script inside container
          sudo tee "$CONTAINER_PATH/root/lineageos-setup.sh" > /dev/null <<'EOF'
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
export PATH="/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin"

/bin/apt-get update

# Install exact packages from LineageOS guide for Ubuntu 20.04
/bin/apt-get install -y \
    bc bison build-essential ccache curl flex \
    g++-multilib gcc-multilib git git-lfs gnupg gpg gperf \
    imagemagick lib32readline-dev lib32z1-dev libelf-dev \
    liblz4-tool lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils \
    lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev \
    libncurses5 libncurses5-dev lib32ncurses5-dev \
    python3 python3-pip python-is-python3 openjdk-11-jdk \
    sudo vim htop tree wget nano

# Create build user and home directory properly (only if user doesn't exist)
export DEBIAN_FRONTEND=noninteractive
if ! id -u lineage >/dev/null 2>&1; then
    echo "Creating lineage user..."
    useradd -m -s /bin/bash -G sudo lineage
    echo "Setting password..."
    echo "lineage:lineage" | chpasswd
    echo "User created successfully."
else
    echo "Lineage user already exists."
fi
echo "Current users:"
id lineage
cat /etc/passwd | grep -E "^(lineage|root)"

# Check groups and install repo tool
echo "Checking groups..."
groups
echo "Installing repo tool..."
if [ ! -d /home/lineage/bin ]; then
    mkdir -p /home/lineage/bin
fi
curl https://storage.googleapis.com/git-repo-downloads/repo > /home/lineage/bin/repo
chmod +x /home/lineage/bin/repo

# Set up environment (avoid duplicate entries)
if ! grep -q 'export PATH="$HOME/bin:$PATH"' /home/lineage/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> /home/lineage/.bashrc
fi
if ! grep -q 'export USE_CCACHE=1' /home/lineage/.bashrc 2>/dev/null; then
    echo 'export USE_CCACHE=1' >> /home/lineage/.bashrc
fi

# Initialize ccache (only if ccache is installed)
if command -v ccache >/dev/null 2>&1; then
    echo "Initializing ccache..."
    ccache -M 50G 2>/dev/null || echo "Warning: Failed to set ccache size"
else
    echo "Warning: ccache not installed, skipping cache setup"
fi

# Create user-specific directories with proper ownership
echo "Setting up user environment..."
mkdir -p /home/lineage/.lineageos/lineage-22.1
chown -R lineage:lineage /home/lineage/.lineageos

if [ ! -f /home/lineage/.lineageos/lineage-22.1/README.md ]; then
    cat > /home/lineage/.lineageos/lineage-22.1/README.md <<'README'
# LineageOS 22.1 for marlin

Initialize:
  repo init -u https://github.com/LineageOS/android.git -b lineage-22.1 --git-lfs

Sync:
  repo sync -c -j$(nproc)

Build:
  source build/envsetup.sh
  breakfast marlin
  brunch marlin
README
fi

# Add PATH to user profile (avoid duplicate entries)
if ! grep -q 'export PATH="/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin:$HOME/bin"' /home/lineage/.bashrc 2>/dev/null; then
    echo 'export PATH="/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin:$HOME/bin"' >> /home/lineage/.bashrc
fi

# Set proper ownership for all lineage user files
chown -R lineage:lineage /home/lineage
echo "Lineage user environment setup completed"
EOF

          sudo chmod +x "$CONTAINER_PATH/root/lineageos-setup.sh"
          # Execute the setup script inside the container
          sudo systemd-nspawn -D "$CONTAINER_PATH" \
            --bind-ro=/etc/resolv.conf:/etc/resolv.conf \
            /root/lineageos-setup.sh
          echo "✅ LineageOS 22.1 build environment ready!"
          
          # Verify container was created successfully
          if sudo test -d "$CONTAINER_PATH" && sudo test -f "$CONTAINER_PATH/bin/apt-get"; then
            echo "✅ Container created successfully. Run 'ubuntu-lineageos-dev setup' next."
          else
            echo "❌ Container verification failed. Please try again."
            exit 1
          fi
          ;;

        setup)
          if ! sudo test -d "$CONTAINER_PATH"; then
            echo "Container not found. Run 'create' first."
            exit 1
          fi
          echo "Running LineageOS setup inside container..."
          sudo systemd-nspawn -D "$CONTAINER_PATH" \
            --bind-ro=/etc/resolv.conf:/etc/resolv.conf \
            /root/lineageos-setup.sh
          ;;

        shell)
          if ! sudo test -d "$CONTAINER_PATH"; then
            echo "Container not found. Run 'create' and 'setup' first."
            exit 1
          fi
          # Default to lineage user if created, otherwise use root
          if sudo systemd-nspawn -D "$CONTAINER_PATH" id lineage >/dev/null 2>&1; then
            sudo systemd-nspawn -D "$CONTAINER_PATH" \
              --user=lineage \
              --bind="$HOME/.lineageos:/home/lineage/.lineageos" \
              --bind="$HOME/.ccache:/home/lineage/.ccache" \
              --bind="$HOME/.android:/home/lineage/.android" \
              --bind="$HOME/.ssh:/home/lineage/.ssh" \
              --setenv="PATH=/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin" \
              --console=interactive
          else
            echo "Lineage user not found, using root..."
            sudo systemd-nspawn -D "$CONTAINER_PATH" \
              --bind="$HOME/.lineageos:/root/.lineageos" \
              --bind="$HOME/.ccache:/root/.ccache" \
              --bind="$HOME/.android:/root/.android" \
              --bind="$HOME/.ssh:/root/.ssh" \
              --setenv="PATH=/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin" \
              --console=interactive
          fi
          ;;

        start)
          if ! sudo test -d "$CONTAINER_PATH"; then
            echo "Container not found. Run 'create' and 'setup' first."
            exit 1
          fi
          # Default to lineage user if created, otherwise use root
          if sudo systemd-nspawn -D "$CONTAINER_PATH" id lineage >/dev/null 2>&1; then
            sudo systemd-nspawn -D "$CONTAINER_PATH" \
              --boot \
              --user=lineage \
              --network-veth \
              --bind="$HOME/.lineageos:/home/lineage/.lineageos" \
              --bind="$HOME/.ccache:/home/lineage/.ccache" \
              --bind="$HOME/.android:/home/lineage/.android" \
              --bind="$HOME/.ssh:/home/lineage/.ssh" \
              --setenv="PATH=/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin"
          else
            sudo systemd-nspawn -D "$CONTAINER_PATH" \
              --boot \
              --network-veth \
              --bind="$HOME/.lineageos:/root/.lineageos" \
              --bind="$HOME/.ccache:/root/.ccache" \
              --bind="$HOME/.android:/root/.android" \
              --bind="$HOME/.ssh:/root/.ssh" \
              --setenv="PATH=/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin"
          fi
          ;;

        init-device)
          if [ -z "$2" ]; then
            echo "Usage: ubuntu-lineageos-dev init-device <device>"
            echo "Example: ubuntu-lineageos-dev init-device marlin"
            exit 1
          fi
          DEVICE="$2"
          BUILD_DIR="$HOME/.lineageos/lineage-22.1"
          mkdir -p "$BUILD_DIR"
          cat > "$BUILD_DIR/build-$DEVICE.sh" <<EOF
#!/bin/bash
set -euo pipefail
cd "\$(dirname "\$0")"
if [ ! -d .repo ]; then
  repo init -u https://github.com/LineageOS/android.git -b lineage-22.1 --git-lfs
fi
repo sync -c -j\$(nproc --all) --force-sync --prune
source build/envsetup.sh
breakfast $DEVICE
brunch $DEVICE
EOF
          chmod +x "$BUILD_DIR/build-$DEVICE.sh"
          echo "✅ Build script: $BUILD_DIR/build-$DEVICE.sh"
          ;;

        build)
          if [ -z "$2" ]; then
            echo "Usage: ubuntu-lineageos-dev build <device>"
            exit 1
          fi
          DEVICE="$2"
          SCRIPT="$HOME/.lineageos/lineage-22.1/build-$DEVICE.sh"
          if [ ! -f "$SCRIPT" ]; then
            echo "Build script not found. Run 'init-device $DEVICE' first."
            exit 1
          fi
          # Use lineage user if available, otherwise use root
          if sudo systemd-nspawn -D "$CONTAINER_PATH" id lineage >/dev/null 2>&1; then
            USER_PATH="/home/lineage/.lineageos/lineage-22.1"
            USER_NAME="lineage"
          else
            USER_PATH="/root/.lineageos/lineage-22.1"
            USER_NAME="root"
          fi

          sudo systemd-nspawn -D "$CONTAINER_PATH" \
            --bind="$HOME/.lineageos:$USER_PATH" \
            --bind="$HOME/.ccache:/home/lineage/.ccache" \
            --bind="$HOME/.android:/home/lineage/.android" \
            --bind="$HOME/.ssh:/home/lineage/.ssh" \
            --setenv="PATH=/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin" \
            --user="$USER_NAME" \
            --chdir="$USER_PATH" \
            ./build-$DEVICE.sh
          ;;

        remove)
          sudo rm -rf "$CONTAINER_PATH"
          echo "✅ Container removed."
          ;;

        status)
          if sudo test -d "$CONTAINER_PATH"; then
            echo "✅ Container: $CONTAINER_PATH"
            echo "Size: $(sudo du -sh "$CONTAINER_PATH" 2>/dev/null | cut -f1 || echo 'unknown')"
            [ -d "$HOME/.lineageos" ] && echo "Source: $(du -sh "$HOME/.lineageos" 2>/dev/null | cut -f1 || echo 'empty')"
            [ -d "$HOME/.ccache" ] && echo "Ccache: $(du -sh "$HOME/.ccache" 2>/dev/null | cut -f1 || echo 'empty')"
          else
            echo "❌ Container not created"
          fi
          ;;

        *)
          echo "Usage: ubuntu-lineageos-dev {create|setup|shell|start|init-device|build|remove|status}"
          echo
          echo "Workflow:"
          echo "  ubuntu-lineageos-dev create"
          echo "  ubuntu-lineageos-dev setup"
          echo "  ubuntu-lineageos-dev init-device marlin"
          echo "  ubuntu-lineageos-dev build marlin"
          ;;
      esac
    '')
  ];

  # Enable systemd-nspawn service (optional but clean)
  systemd.services."systemd-nspawn@" = {
    enable = true;
  };
}