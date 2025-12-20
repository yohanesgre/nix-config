# Configuration Architecture

This Nix configuration uses **inline platform-specific profiles** - the recommended pattern for multi-platform Home Manager configurations.

## How It Works

The configuration automatically detects your platform and applies the appropriate profile:

```nix
# Platform detection
isLinux = pkgs.stdenv.isLinux;
isDarwin = pkgs.stdenv.isDarwin;

# Conditional package installation
home.packages = with pkgs; [
  # Common packages (all platforms)
  claude-code
  nix-index
  fastfetch
] ++ lib.optionals isDarwin [
  # macOS-specific packages
  git, curl, vim, vscode, ghostty, ...
] ++ lib.optionals isLinux [
  # Linux-specific packages (minimal on Arch)
];
```

## Platform Profiles

### Arch Linux Profile

**Location:** `home.nix` lines 54-59

**Philosophy:** Hybrid Nix + pacman management
- Nix: claude-code, nix-index, fastfetch
- Pacman: Everything else (git, curl, vim, fonts, GUI apps)

**Environment:**
- `FZF_BASE = "/usr/share/fzf"` (system path)
- `LOCALE_ARCHIVE` (Arch Wiki recommendation)
- `XDG_DATA_DIRS` (desktop integration)

**Aliases:**
- Arch-specific: `update`, `cleanup`, `rmpkg`, `jctl`
- Pacman helpers

**Scripts:**
- `fix-royuan-keyboard` (hardware-specific)

### macOS Profile

**Location:** `home.nix` lines 36-54

**Philosophy:** Full Nix package management
- All packages via Nix (no pacman available)

**Environment:**
- `FZF_BASE = "${pkgs.fzf}/share/fzf"` (Nix path)
- `TERMINAL = "ghostty"`

**Aliases:**
- macOS-specific: `update` (brew), CPU detection via `sysctl`

**Scripts:**
- None (no hardware-specific scripts needed)

## Why Inline Profiles?

### Advantages ✅
1. **Single source of truth** - One file to maintain
2. **No infinite recursion** - Nix doesn't support conditional imports well
3. **Recommended pattern** - Used by Home Manager examples
4. **Easy to understand** - Clear `lib.optionals` blocks
5. **DRY principle** - Common config defined once

### Why Not Separate Files? ❌
1. Conditional imports cause infinite recursion in Nix
2. More complex to maintain
3. Harder to see the full picture
4. Not the idiomatic Nix way

## Configuration Hierarchy

```
config.nix                    # User settings (enableFlutter, enableGaming, etc.)
    ↓
home.nix                      # Main configuration
    ├── Common packages       # All platforms
    ├── macOS profile         # lib.optionals isDarwin [...]
    ├── Linux profile         # lib.optionals isLinux [...]
    ├── Flutter packages      # lib.optionals enableFlutter [...]
    └── Gaming packages       # lib.optionals (isLinux && enableGaming) [...]
    ↓
nix.conf                      # Arch-optimized Nix settings
```

## Customization Per Platform

### Adding Arch-only Packages
```nix
] ++ lib.optionals isLinux [
  # Add your package here
  my-arch-package
]
```

### Adding macOS-only Packages
```nix
] ++ lib.optionals isDarwin [
  # Add your package here
  my-macos-package
]
```

### Platform-specific Environment Variables
```nix
} // lib.optionalAttrs isDarwin {
  MY_VAR = "macOS value";
} // lib.optionalAttrs isLinux {
  MY_VAR = "Linux value";
}
```

### Platform-specific Aliases
```nix
} // lib.optionalAttrs isLinux {
  my-alias = "linux-command";
} // lib.optionalAttrs isDarwin {
  my-alias = "macos-command";
}
```

## Package Count by Platform

### Arch Linux
- **Nix packages:** 3 (claude-code, nix-index, fastfetch)
- **Pacman packages:** ~15+ (git, curl, vim, fonts, etc.)
- **Total:** Hybrid management

### macOS
- **Nix packages:** ~20 (everything)
- **Homebrew:** 0 (optional, user choice)
- **Total:** Full Nix management

## Best Practices

1. ✅ **Keep common config at the top** - Shared by all platforms
2. ✅ **Use `lib.optionals`** - Platform-specific packages
3. ✅ **Use `lib.optionalAttrs`** - Platform-specific environment vars
4. ✅ **Comment your sections** - Explain why each block exists
5. ✅ **Test on both platforms** - Ensure no breakage

## Further Reading

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Language Basics](https://nixos.org/manual/nix/stable/language/)
- [PLATFORM_COMPATIBILITY.md](./PLATFORM_COMPATIBILITY.md) - Usage guide
- [PACMAN_PACKAGES.md](./PACMAN_PACKAGES.md) - Arch package strategy
