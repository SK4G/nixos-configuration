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

          # Copy host git config from .config/git/config
          sudo mkdir -p "$CONTAINER_PATH/home/lineage"
          if [ -f "$HOME/.config/git/config" ]; then
            sudo mkdir -p "$CONTAINER_PATH/home/lineage/.config/git"
            sudo cp "$HOME/.config/git/config" "$CONTAINER_PATH/home/lineage/.config/git/config"
          elif [ -f "$HOME/.gitconfig" ]; then
            sudo cp "$HOME/.gitconfig" "$CONTAINER_PATH/home/lineage/.gitconfig"
          fi
          # Create default git config if none exists
          if [ ! -f "$CONTAINER_PATH/home/lineage/.gitconfig" ] && [ ! -f "$CONTAINER_PATH/home/lineage/.config/git/config" ]; then
            cat > "$CONTAINER_PATH/home/lineage/.gitconfig" << 'EOF'
[user]
    email = builder@example.com
    name = Lineage Builder
EOF
          fi

          # Hostname
          echo "ubuntu-lineageos-dev" | sudo tee "$CONTAINER_PATH/etc/hostname" > /dev/null

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
    g++-multilib gcc-multilib git git-lfs gnupg gperf \
    imagemagick lib32readline-dev lib32z1-dev libelf-dev \
    liblz4-tool lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils \
    lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev \
    libncurses5 libncurses5-dev lib32ncurses5-dev \
    python3 python3-pip python-is-python3 openjdk-11-jdk \
    vim htop tree wget nano

# Create build user
useradd -m -s /bin/bash -G sudo lineage
echo "lineage:lineage" | chpasswd

# Fix permissions for existing files
chown -R lineage:lineage /home/lineage

# User environment
sudo -u lineage bash <<'USER_SETUP'
cd /home/lineage

git config --global user.email "builder@example.com"
git config --global user.name "Lineage Builder"
git config --global trailer.changeid.key "Change-Id"

mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod +x ~/bin/repo
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
echo 'export USE_CCACHE=1' >> ~/.bashrc

mkdir -p .lineageos/lineage-22.1
cat > .lineageos/lineage-22.1/README.md <<'README'
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

# Add PATH to user profile
echo 'export PATH="/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin"' >> ~/.bashrc
USER_SETUP

# Initialize ccache
ccache -M 50G

echo "✅ LineageOS 22.1 build environment ready!"
EOF

          sudo chmod +x "$CONTAINER_PATH/root/lineageos-setup.sh"
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
          sudo systemd-nspawn -D "$CONTAINER_PATH" \
            --bind="$HOME/.lineageos:/home/lineage/.lineageos" \
            --bind="$HOME/.ccache:/home/lineage/.ccache" \
            --bind="$HOME/.android:/home/lineage/.android" \
            --bind="$HOME/.ssh:/home/lineage/.ssh" \
            --bind="$HOME/.config/git/config:/home/lineage/.config/git/config" \
            --setenv="PATH=/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin" \
            --console=interactive
          ;;

        start)
          if ! sudo test -d "$CONTAINER_PATH"; then
            echo "Container not found. Run 'create' and 'setup' first."
            exit 1
          fi
          sudo systemd-nspawn -D "$CONTAINER_PATH" \
            --boot \
            --network-veth \
            --bind="$HOME/.lineageos:/home/lineage/.lineageos" \
            --bind="$HOME/.ccache:/home/lineage/.ccache" \
            --bind="$HOME/.android:/home/lineage/.android" \
            --bind="$HOME/.ssh:/home/lineage/.ssh" \
            --bind="$HOME/.gitconfig:/home/lineage/.gitconfig" 2>/dev/null || true \
            --setenv="PATH=/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin"
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
          sudo systemd-nspawn -D "$CONTAINER_PATH" \
            --bind="$HOME/.lineageos:/home/lineage/.lineageos" \
            --bind="$HOME/.ccache:/home/lineage/.ccache" \
            --bind="$HOME/.android:/home/lineage/.android" \
            --bind="$HOME/.ssh:/home/lineage/.ssh" \
            --bind="$HOME/.gitconfig:/home/lineage/.gitconfig" 2>/dev/null || true \
            --setenv="PATH=/bin:/usr/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin:/bin" \
            --user=lineage \
            --chdir=/home/lineage/.lineageos/lineage-22.1 \
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