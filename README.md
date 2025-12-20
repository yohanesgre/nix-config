# Nix Configuration

My personal [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) configuration for managing dotfiles and packages across Linux and macOS.

## 📚 Documentation

- **[docs/GUIDE.md](docs/GUIDE.md)** - User guide (profiles, platform setup)
- **[docs/REFERENCE.md](docs/REFERENCE.md)** - Technical reference (architecture, packages)
- **[docs/ADVANCED.md](docs/ADVANCED.md)** - Advanced topics (Flutter, secrets, auto-run)

## Features

- **Cross-platform support**: Works on Linux (x86_64, ARM64) and macOS (Intel, Apple Silicon)
- **Declarative package management**: All packages and configurations in one place
- **Consistent environment**: Same setup across all devices
- **Git-based dotfiles**: Version-controlled configuration
- **Automated SSH setup**: Script for easy SSH key generation and GitHub integration
- **Environment-based configuration**: Use Nix expressions for easy feature toggling

## What's Included

### Packages
- **Development**: git, gh (GitHub CLI), vim, vscode, claude-code
- **Shell**: zsh with oh-my-zsh, starship prompt, fzf
- **Terminal**: ghostty
- **System tools**: btop, fastfetch, nix-index
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono, Meslo LG)
- **Linux-only**: flatpak
- **Gaming (optional)**: steam, wine, protontricks (Linux only)

### Programs Configured
- **Git**: User info and settings
- **SSH**: GitHub/GitLab ready, security-focused config
- **Zsh**: Auto-suggestions, syntax highlighting, history search
- **Starship**: Beautiful prompt with Catppuccin Mocha theme

### Scripts
- `setup-ssh-key`: Interactive SSH key setup for GitHub
- `fix-royuan-keyboard` (Linux): Fix for ROYUAN OLV75 keyboard
- `setup-android-sdk` (Optional): Android SDK setup for Flutter development

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

2. **Customize configuration** (edit `config.nix`):
   ```nix
   {
     # Enable optional features
     enableFlutter = true;
     enableGaming = true;
   }
   ```

3. **Set up Git user info** (add to `~/.zshrc` or create `~/.zshrc.local`):
   ```bash
   export GIT_AUTHOR_EMAIL="your-email@example.com"
   export GIT_AUTHOR_NAME="Your Name"
   export GIT_COMMITTER_EMAIL="your-email@example.com"
   export GIT_COMMITTER_NAME="Your Name"
   ```

4. **Apply the configuration**:
   ```bash
   # On Linux x86_64 (default)
   home-manager switch --flake ~/.config/nix#default

   # On Linux ARM64
   home-manager switch --flake ~/.config/nix#archlinux-arm

   # On macOS Intel
   home-manager switch --flake ~/.config/nix#macos-intel

   # On macOS ARM (Apple Silicon)
   home-manager switch --flake ~/.config/nix#macos
   ```

## Available Profiles

- `archlinux` - x86_64 Arch Linux
- `archlinux-arm` - ARM64 Arch Linux
- `macos` - ARM64 macOS (Apple Silicon)
- `macos-intel` - x86_64 macOS (Intel)
- `default` - x86_64 Arch Linux (same as `archlinux`)

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

- `hm` - Apply Home Manager configuration (`home-manager switch --flake ~/.config/nix#default`)
- `hme` - Edit home.nix
- `c` - Clear terminal
- Linux: `update`, `cleanup`, `jctl`, `rip`
- macOS: `update` (brew)

## Configuration Options

All optional features can be enabled/disabled in `config.nix`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enableFlutter` | boolean | `false` | Install Flutter SDK, Android Studio, and JDK 17 |
| `enableGaming` | boolean | `false` | Install Steam, Wine, and gaming tools (Linux only) |
| `flutterSdkUrl` | string | Latest stable | Flutter SDK download URL |
| `androidCmdlineToolsUrl` | string | Latest Linux tools | Android SDK command-line tools download URL |

See [docs/ADVANCED.md](docs/ADVANCED.md) for Flutter-specific setup instructions.

### Git Configuration

Git user information is configured via environment variables in your shell:

```bash
# Add to ~/.zshrc or ~/.zshrc.local
export GIT_AUTHOR_EMAIL="your-email@example.com"
export GIT_AUTHOR_NAME="Your Name"
export GIT_COMMITTER_EMAIL="your-email@example.com"
export GIT_COMMITTER_NAME="Your Name"
```

This keeps your personal git information out of version control while allowing git to use these values automatically.

## File Structure

```
.
├── flake.nix                   # Main flake configuration
├── flake.lock                  # Locked dependencies
├── home.nix                    # Home Manager configuration
├── config.nix                  # User configuration file
├── nix.conf                    # Nix daemon settings
├── README.md                   # This file
├── .gitignore                  # Git ignore rules
├── docs/                       # Documentation
│   ├── GUIDE.md                # User guide
│   ├── REFERENCE.md            # Technical reference
│   └── ADVANCED.md             # Advanced topics
└── scripts/                    # Helper scripts
    ├── setup-ssh-key.sh
    ├── fix-royuan-keyboard.sh
    ├── setup-android-sdk.sh
    └── install-arch-packages.sh
```

## Updating

```bash
# Update flake inputs
nix flake update ~/.config/nix

# Apply updates
home-manager switch --flake ~/.config/nix#default
```

## Platform-Specific Notes

### Linux (Arch/CachyOS)
- **Hybrid package management**: Essential packages via pacman, Nix-specific tools via Nix
- **Optimized for Arch**: Follows Arch Wiki best practices for Nix integration
- **Performance optimizations**: Multi-core builds, locale fixes
- Includes flatpak with auto-updates
- Optional gaming packages (Steam, Wine) via `enableGaming`
- CachyOS-inspired aliases and settings
- See [docs/REFERENCE.md](docs/REFERENCE.md) for package management strategy

### macOS
- **Full Nix package management**: All packages installed via Nix
- Automatically detects platform
- Uses appropriate CPU count for make/ninja
- Homebrew integration via alias
- No conflicts with system package managers

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
