# NixOS Configuration with Hyprland

This repository contains my declarative NixOS configurations for multiple machines using flakes and home-manager. The configuration features Hyprland as the window manager with a complete desktop environment setup.

## Repository Structure

```
nixos/
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Lock file (auto-generated)
├── .gitignore                   # Excludes hardware configs
├── README.md                    # This file
├── hosts/
│   ├── work-laptop/
│   │   ├── configuration.nix    # System configuration
│   │   ├── hardware-configuration.nix  # (not in git)
│   │   └── home.nix            # User environment
│   └── home-laptop/
│       ├── configuration.nix
│       ├── hardware-configuration.nix  # (not in git)
│       └── home.nix
├── nixosModules/
│   ├── common.nix              # Shared system settings
│   ├── desktop.nix             # Hyprland desktop setup
│   ├── development.nix         # Dev tools for work laptop
│   └── gaming.nix              # Gaming setup for home laptop
└── shared/
    ├── hyprland.conf           # Shared Hyprland configuration
    └── waybar/
        ├── config.json         # Base waybar config (for reference)
        └── style.css           # Shared waybar styling
```

**Note:** Each host has its own `waybar-config.json` for machine-specific customizations.

## Features

### Common Features (Both Laptops)
- **Hyprland** - Modern Wayland compositor
- **Waybar** - Status bar with system information
- **Kitty** - GPU-accelerated terminal
- **Rofi** - Application launcher
- **Network Manager** - Network connectivity
- **PipeWire** - Modern audio system
- **Nix Flakes** - Reproducible builds

### Work Laptop
- Development tools (Node.js, Python, Rust, Go)
- Docker
- PostgreSQL
- VS Code
- Communication tools (Slack, Zoom)
- Browser (Firefox, Chrome)

### Home Laptop
- Gaming setup (Steam, Lutris, GameMode)
- Entertainment apps (Discord, Spotify)
- Media tools (VLC, GIMP)

## Initial Setup

### 1. Install NixOS

Follow the official [NixOS installation guide](https://nixos.org/manual/nixos/stable/index.html#sec-installation).

### 2. Clone This Repository

```bash
cd ~
git clone <your-repo-url>
cd nixos
```

### 3. Copy Hardware Configuration

After installation, copy your hardware configuration to the appropriate host directory:

```bash
# For work laptop
sudo cp /etc/nixos/hardware-configuration.nix ~/nixos/hosts/work-laptop/

# For home laptop
sudo cp /etc/nixos/hardware-configuration.nix ~/nixos/hosts/home-laptop/
```

**Important:** Hardware configurations are machine-specific and should NOT be committed to git.

### 4. Customize Your Configuration

Before building, update the following:

#### Personal Information
Edit the appropriate files for your laptop:

**System Configuration** (`hosts/*/configuration.nix`):
- Update `users.users.youruser` with your actual username
- Update `description` with your name
- Change `initialPassword` (you'll change this after first login)

**Home Manager Configuration** (`hosts/*/home.nix`):
- Update `home.username` with your actual username
- Update `home.homeDirectory` with your home path
- Update Git configuration:
  - `userName`: Your name
  - `userEmail`: Your email

**Common Configuration** (`nixosModules/common.nix`):
- Update `time.timeZone` to your timezone (e.g., "America/Los_Angeles", "Europe/London")
- Update locale settings if needed

### 5. Build Your Configuration

```bash
# For work laptop
sudo nixos-rebuild switch --flake ~/nixos#work-laptop

# For home laptop
sudo nixos-rebuild switch --flake ~/nixos#home-laptop
```

### 6. Reboot

```bash
sudo reboot
```

## Daily Usage

### Updating Your System

```bash
# Quick rebuild (uses existing flake.lock)
nixos-rebuild-work    # or nixos-rebuild-home

# Full update (updates all packages)
nixos-update
```

### Hyprland Keybindings

Default keybindings (SUPER = Windows key):

- `SUPER + Q` - Open terminal (Kitty)
- `SUPER + C` - Close active window
- `SUPER + M` - Exit Hyprland
- `SUPER + E` - Open file manager (Yazi)
- `SUPER + V` - Toggle floating window
- `SUPER + R` - Open application launcher (Rofi)
- `SUPER + L` - Lock screen
- `SUPER + 1-9` - Switch to workspace 1-9
- `SUPER + SHIFT + 1-9` - Move window to workspace 1-9
- `SUPER + h/j/k/l` - Move focus (vim keys)
- `SUPER + arrow keys` - Move focus
- `Print` - Screenshot to clipboard
- `SHIFT + Print` - Screenshot to file

See [shared/hyprland.conf](shared/hyprland.conf) for all keybindings.

## Customization

### Adding Packages

**System-wide packages** (all users):
- Edit `hosts/*/configuration.nix` and add to `environment.systemPackages`

**User-specific packages**:
- Edit `hosts/*/home.nix` and add to `home.packages`

**Shared packages** (all machines):
- Edit `nixosModules/common.nix` for common system packages
- Create a new module in `nixosModules/` for specific feature sets

### Modifying Hyprland Configuration

Edit [shared/hyprland.conf](shared/hyprland.conf) to customize:
- Keybindings
- Appearance (gaps, borders, colors)
- Animations
- Monitor configuration
- Startup applications

Changes will apply to both laptops on next rebuild.

### Customizing Waybar

**Per-Machine Configuration:**
- Work laptop: Edit `hosts/work-laptop/waybar-config.json` (includes Slack/Zoom shortcuts)
- Home laptop: Edit `hosts/home-laptop/waybar-config.json` (includes Discord/Spotify shortcuts)

**Shared Styling:**
- Edit `shared/waybar/style.css` to change colors, fonts, and appearance
- Styles apply to both machines

**Adding Custom Modules:**
```json
"custom/myapp": {
    "format": " ",
    "on-click": "myapp",
    "tooltip": true,
    "tooltip-format": "Open My App"
}
```

Then add `"custom/myapp"` to the `modules-right` array in your machine's config.

### Switching Between Stable and Unstable

Edit [flake.nix](flake.nix) and change the nixpkgs input:

```nix
# For unstable (latest packages)
nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

# For stable (e.g., 24.11)
nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
```

## Troubleshooting

### Build Fails

```bash
# Check flake inputs
nix flake metadata

# Update flake lock file
nix flake update
```

### Hyprland Won't Start

Check logs:
```bash
journalctl -u display-manager -b
```

Try starting Hyprland manually from TTY:
```bash
# Press Ctrl+Alt+F2 to get to TTY
Hyprland
```

### Home Manager Issues

```bash
# Rebuild just home manager
home-manager switch --flake ~/nixos#youruser@work-laptop
```

## Git Workflow

### Initial Commit

```bash
cd ~/nixos
git add .
git commit -m "Initial NixOS configuration"
git remote add origin <your-repo-url>
git push -u origin main
```

### Making Changes

```bash
# Make your changes to configuration files
git add .
git commit -m "Description of changes"
git push
```

### On Another Machine

```bash
cd ~/nixos
git pull
sudo nixos-rebuild switch --flake .#<hostname>
```

## Security Notes

1. **Hardware Configurations**: NOT committed to git (machine-specific)
2. **Initial Password**: Change after first login with `passwd`
3. **SSH Keys**: Generate new keys per machine, don't commit private keys
4. **Secrets**: Use [sops-nix](https://github.com/Mic92/sops-nix) or [agenix](https://github.com/ryantm/agenix) for secrets management

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Nix Package Search](https://search.nixos.org/)
- [NixOS Discourse](https://discourse.nixos.org/)

## License

MIT License - Feel free to use and modify for your own systems.