# Nix Configuration

My personal [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) configuration for managing dotfiles and packages across Linux and macOS.

## Features

- **Cross-platform support**: Works on Linux (x86_64, ARM64) and macOS (Intel, Apple Silicon)
- **Declarative package management**: All packages and configurations in one place
- **Consistent environment**: Same setup across all devices
- **Git-based dotfiles**: Version-controlled configuration
- **Automated SSH setup**: Script for easy SSH key generation and GitHub integration

## What's Included

### Packages
- **Development**: git, gh (GitHub CLI), vim, vscode, claude-code
- **Shell**: zsh with oh-my-zsh, starship prompt, fzf
- **Terminal**: ghostty
- **System tools**: btop, fastfetch, nix-index
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono, Meslo LG)
- **Linux-only**: flatpak, steam, wine, protontricks

### Programs Configured
- **Git**: User info and settings
- **SSH**: GitHub/GitLab ready, security-focused config
- **Zsh**: Auto-suggestions, syntax highlighting, history search
- **Starship**: Beautiful prompt with Catppuccin Mocha theme

### Scripts
- `setup-ssh-key`: Interactive SSH key setup for GitHub
- `fix-royuan-keyboard` (Linux): Fix for ROYUAN OLV75 keyboard

## Installation

### Prerequisites

Install Nix with flakes support:

```bash
# On Linux or macOS
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (add to ~/.config/nix/nix.conf or /etc/nix/nix.conf)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Setup

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/nix-config.git ~/.config/nix
   cd ~/.config/nix
   ```

2. **Customize for your user** (edit `flake.nix`):
   ```nix
   # Change this line to your username
   username = "yohanes";
   ```

3. **Update personal info** (edit `home.nix`):
   ```nix
   programs.git = {
     settings = {
       user.email = "your-email@example.com";
       user.name = "Your Name";
     };
   };
   ```

4. **Apply the configuration**:
   ```bash
   # On Linux x86_64
   home-manager switch --flake ~/.config/nix#yohanes@linux

   # On macOS ARM (Apple Silicon)
   home-manager switch --flake ~/.config/nix#yohanes@darwin-arm

   # Or use the default (x86_64 Linux)
   home-manager switch --flake ~/.config/nix#yohanes
   ```

## Available Configurations

- `username@linux` - x86_64 Linux
- `username@linux-arm` - ARM64 Linux
- `username@darwin` - x86_64 macOS (Intel)
- `username@darwin-arm` - ARM64 macOS (Apple Silicon)
- `username` - Default (x86_64 Linux)

## SSH Key Setup

After installation, set up SSH keys for GitHub:

```bash
setup-ssh-key
```

The script will:
- Prompt for a device name
- Generate an ed25519 SSH key
- Add it to GitHub automatically
- Test the connection

## Useful Aliases

Defined in the configuration:

- `hm` - Apply Home Manager configuration
- `hme` - Edit home.nix
- `c` - Clear terminal
- Linux: `update`, `cleanup`, `jctl`, `rip`
- macOS: `update` (brew)

## File Structure

```
.
├── flake.nix           # Main flake configuration
├── flake.lock          # Locked dependencies
├── home.nix            # Home Manager configuration
├── scripts/            # Helper scripts
│   ├── setup-ssh-key.sh
│   └── fix-royuan-keyboard.sh
└── README.md
```

## Updating

```bash
# Update flake inputs
nix flake update ~/.config/nix

# Apply updates
home-manager switch --flake ~/.config/nix#yohanes
```

## Platform-Specific Notes

### Linux
- Includes flatpak with auto-updates
- Gaming packages (Steam, Wine)
- CachyOS-inspired aliases and settings

### macOS
- Automatically detects platform
- Uses appropriate CPU count for make/ninja
- Homebrew integration via alias

## Customization

1. **Add packages**: Edit `home.packages` in `home.nix`
2. **Platform-specific packages**: Use `lib.optionals isLinux` or `lib.optionals isDarwin`
3. **Add dotfiles**: Add entries to `home.file`
4. **Configure programs**: Add to `programs.*` sections

## Troubleshooting

**Dirty git tree warning**:
```bash
git add -A
git commit -m "Update configuration"
```

**File not tracked by Git**:
```bash
git add path/to/file
```

**SSH issues**:
- Ensure `gh` is authenticated: `gh auth login`
- Test connection: `ssh -T git@github.com`

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix Packages Search](https://search.nixos.org/packages)

## License

MIT
