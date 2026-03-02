# iLinux - Linux in a macOS Theme

A custom Debian-based Linux distribution featuring an Xfce desktop environment
themed to look and feel like macOS.

## Features

- **Xfce Desktop** with macOS-style top panel (global menu bar)
- **WhiteSur GTK Theme** (Light + Dark) for window decorations and controls
- **WhiteSur Icon Theme** with macOS-style icons
- **WhiteSur Cursors** matching the macOS aesthetic
- **Plank Dock** at the bottom (macOS-style dock with zoom)
- **Picom Compositor** for shadows, rounded corners, and transparency
- **Inter Font** as the default system font (closest to San Francisco)
- **Custom LightDM greeter** styled to match the theme
- **macOS-style window buttons** (close/minimize/maximize on the left)
- **x86_64 (amd64)** architecture
- Based on **Debian Bookworm** (stable)

## Building the ISO

### Requirements

- A **Debian or Ubuntu** system (native, VM, or WSL2)
- Root access
- ~10 GB free disk space
- Internet connection

### Quick Build

```bash
# Clone or copy this project to your Linux system
cd iLinux

# Make build script executable
chmod +x build.sh

# Build the ISO (requires root)
sudo ./build.sh
```

The build takes 15-45 minutes depending on your internet speed and hardware.
The finished ISO will be at `ilinux-1.0-amd64.iso` in the project root.

### Testing the ISO

```bash
# With QEMU
qemu-system-x86_64 -m 2G -cdrom ilinux-1.0-amd64.iso

# With VirtualBox: create a new VM and attach the ISO as a CD

# Write to USB drive
sudo dd if=ilinux-1.0-amd64.iso of=/dev/sdX bs=4M status=progress
```

## Project Structure

```
iLinux/
├── build.sh                           # Main build script
├── config/
│   ├── package-lists/
│   │   └── ilinux.list.chroot         # Packages to install
│   ├── hooks/live/
│   │   └── 0500-ilinux-theme.hook.chroot  # Theme installer (runs during build)
│   ├── bootloaders/grub-pc/
│   │   └── grub.cfg                   # GRUB boot menu
│   └── includes.chroot/               # Files copied into the live filesystem
│       ├── etc/
│       │   ├── skel/.config/          # Default user config
│       │   │   ├── xfce4/             # Xfce panel, desktop, WM settings
│       │   │   ├── gtk-3.0/           # GTK theme settings
│       │   │   ├── plank/             # Dock configuration
│       │   │   └── autostart/         # Plank, Picom, Welcome autostart
│       │   └── lightdm/               # Login screen theme
│       └── usr/
│           ├── share/ilinux/          # Branding files
│           └── local/bin/             # iLinux scripts
└── README.md
```

## Customization

### Switch to Dark Mode

Edit `xsettings.xml` and `settings.ini` — change `WhiteSur-Light` to `WhiteSur-Dark`.
Also update `xfwm4.xml` theme to `WhiteSur-Dark`.

### Change Wallpaper

Replace or add images in `config/includes.chroot/usr/share/backgrounds/ilinux/`
and update the path in `xfce4-desktop.xml`.

### Add/Remove Packages

Edit `config/package-lists/ilinux.list.chroot`.

## Credits

- [WhiteSur GTK Theme](https://github.com/vinceliuice/WhiteSur-gtk-theme) by vinceliuice
- [WhiteSur Icon Theme](https://github.com/vinceliuice/WhiteSur-icon-theme) by vinceliuice
- [WhiteSur Cursors](https://github.com/vinceliuice/WhiteSur-cursors) by vinceliuice
- [Plank Dock](https://launchpad.net/plank)
- [Debian Live Build](https://live-team.pages.debian.net/live-manual/)
- [Xfce Desktop](https://xfce.org/)

## License

Build scripts and configuration: MIT License.
Themes retain their original licenses (GPL).
