#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
ISO_NAME="ilinux-1.0-amd64.iso"

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'

banner() {
    echo -e "${CYAN}${BOLD}"
    cat << 'LOGO'
  _ _     _
 (_) |   (_)
  _| |    _ _ __  _   ___  __
 | | |   | | '_ \| | | \ \/ /
 | | |___| | | | | |_| |>  <
 |_|_____|_|_| |_|\__,_/_/\_\

  Linux in a macOS Theme
LOGO
    echo -e "${NC}"
}

check_deps() {
    echo -e "${CYAN}[1/4]${NC} Checking dependencies..."
    for cmd in lb debootstrap xorriso mksquashfs; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Installing required packages..."
            apt-get update -qq
            apt-get install -y live-build debootstrap xorriso squashfs-tools
            break
        fi
    done
    echo -e "${GREEN}  All dependencies satisfied.${NC}"
}

configure() {
    echo -e "${CYAN}[2/4]${NC} Configuring live-build..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    lb config \
        --distribution bookworm \
        --debian-installer live \
        --debian-installer-gui true \
        --archive-areas "main contrib non-free non-free-firmware" \
        --architectures amd64 \
        --binary-images iso-hybrid \
        --bootappend-live "boot=live components quiet splash" \
        --iso-application "iLinux" \
        --iso-publisher "iLinux Project" \
        --iso-volume "iLinux 1.0" \
        --memtest none \
        --win32-loader false

    cp "${SCRIPT_DIR}/config/package-lists/ilinux.list.chroot" config/package-lists/

    if [ -d "${SCRIPT_DIR}/config/includes.chroot" ]; then
        cp -a "${SCRIPT_DIR}/config/includes.chroot/"* config/includes.chroot/ 2>/dev/null || true
    fi
    if [ -d "${SCRIPT_DIR}/config/hooks/live" ]; then
        mkdir -p config/hooks/live
        cp -a "${SCRIPT_DIR}/config/hooks/live/"* config/hooks/live/ 2>/dev/null || true
    fi
    if [ -f "${SCRIPT_DIR}/config/bootloaders/grub-pc/grub.cfg" ]; then
        mkdir -p config/bootloaders/grub-pc
        cp "${SCRIPT_DIR}/config/bootloaders/grub-pc/grub.cfg" config/bootloaders/grub-pc/
    fi

    echo -e "${GREEN}  Configuration complete.${NC}"
}

build_iso() {
    echo -e "${CYAN}[3/4]${NC} Building ISO (this will take 15-45 min)..."
    cd "$BUILD_DIR"
    lb build 2>&1 | tee "${SCRIPT_DIR}/build.log"
    echo -e "${GREEN}  Build finished.${NC}"
}

deliver() {
    echo -e "${CYAN}[4/4]${NC} Finalizing..."
    local iso
    iso=$(find "$BUILD_DIR" -maxdepth 1 -name '*.iso' | head -1)
    if [ -n "$iso" ]; then
        cp "$iso" "${SCRIPT_DIR}/${ISO_NAME}"
        local size
        size=$(du -h "${SCRIPT_DIR}/${ISO_NAME}" | cut -f1)
        echo ""
        echo -e "${GREEN}${BOLD}  ISO ready: ${SCRIPT_DIR}/${ISO_NAME} (${size})${NC}"
        echo "  Test:  qemu-system-x86_64 -m 2G -cdrom ${ISO_NAME}"
        echo "  USB:   sudo dd if=${ISO_NAME} of=/dev/sdX bs=4M status=progress"
    else
        echo -e "${RED}  ERROR: No ISO found. Check build.log${NC}"
        exit 1
    fi
}

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}ERROR: Must run as root. Usage: sudo ./build.sh${NC}"
    exit 1
fi

banner
check_deps
configure
build_iso
deliver
echo -e "${GREEN}${BOLD}  iLinux build complete!${NC}"
