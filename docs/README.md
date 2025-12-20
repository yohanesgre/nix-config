# Documentation

Comprehensive guides for using and customizing this Nix configuration.

## Quick Start

- **New to this config?** Start with [../README.md](../README.md)
- **Choosing a profile?** See [PROFILES.md](PROFILES.md)
- **Platform-specific setup?** Check [PLATFORM_COMPATIBILITY.md](PLATFORM_COMPATIBILITY.md)

## All Documentation

### Essential Guides

1. **[PROFILES.md](PROFILES.md)** - Flake profiles reference
   - Available profiles: `#archlinux`, `#macos`, etc.
   - How to switch between profiles
   - Platform-specific differences

2. **[PLATFORM_COMPATIBILITY.md](PLATFORM_COMPATIBILITY.md)** - Platform setup
   - Arch Linux setup guide
   - macOS setup guide
   - Platform differences

3. **[ARCHITECTURE.md](ARCHITECTURE.md)** - How it works
   - Configuration structure
   - Inline platform profiles
   - Customization patterns

### Platform-Specific

4. **[PACMAN_PACKAGES.md](PACMAN_PACKAGES.md)** - Arch Linux only
   - What to install via pacman
   - What to install via Nix
   - Package installation script

5. **[VSCODE_OPTIONS.md](VSCODE_OPTIONS.md)** - Arch Linux only
   - VSCode via Nix vs pacman
   - Pros and cons of each
   - How to switch

### Optional Features

6. **[FLUTTER_SETUP.md](FLUTTER_SETUP.md)** - Flutter development
   - Enabling Flutter support
   - Android SDK setup
   - Troubleshooting

7. **[SECRETS_MANAGEMENT.md](SECRETS_MANAGEMENT.md)** - Security
   - Managing sensitive data
   - Using environment variables
   - Encryption options

## Navigation

```
docs/
├── README.md (you are here)
├── PROFILES.md              ← Start here for profile selection
├── PLATFORM_COMPATIBILITY.md ← Platform-specific setup
├── ARCHITECTURE.md          ← How the config works
├── PACMAN_PACKAGES.md       ← Arch: Package management
├── VSCODE_OPTIONS.md        ← Arch: VSCode options
├── FLUTTER_SETUP.md         ← Optional: Flutter dev
└── SECRETS_MANAGEMENT.md    ← Security best practices
```

## Common Questions

### Which profile should I use?

See [PROFILES.md](PROFILES.md) - Use:
- `#archlinux` for Arch Linux x86_64
- `#macos` for macOS Apple Silicon

### How do I install packages on Arch?

See [PACMAN_PACKAGES.md](PACMAN_PACKAGES.md) - Most packages via pacman, minimal via Nix.

### Can I use VSCode from Nix on Arch?

Yes! See [VSCODE_OPTIONS.md](VSCODE_OPTIONS.md) for how to enable it.

### How do I enable Flutter?

See [FLUTTER_SETUP.md](FLUTTER_SETUP.md) - Set `enableFlutter = true` in `config.nix`.

### Where do I put API keys?

See [SECRETS_MANAGEMENT.md](SECRETS_MANAGEMENT.md) - Use environment variables or `secrets.nix`.

## External Resources

- [Nix Package Search](https://search.nixos.org/packages)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Language Basics](https://nixos.org/manual/nix/stable/language/)
- [Arch Wiki: Nix](https://wiki.archlinux.org/title/Nix)
