# Managing Sensitive Data in Nix Configuration

Since `config.nix` is tracked in git, **never** put sensitive information directly in it.

## What counts as sensitive?
- API keys and tokens
- Passwords
- Email addresses (if privacy is a concern)
- SSH keys
- Personal identifiers
- Any credentials

## Recommended Approaches

### 1. Environment Variables
Use environment variables for runtime secrets:

```nix
# In config.nix
{
  programs.git = {
    userEmail = builtins.getEnv "GIT_EMAIL";
  };
}
```

Set the variable in your shell profile:
```bash
export GIT_EMAIL="your-email@example.com"
```

### 2. Separate Untracked File
Create a `secrets.nix` file that's gitignored:

```nix
# secrets.nix (add to .gitignore)
{
  email = "your-email@example.com";
  apiKey = "your-api-key";
}
```

Import it in `config.nix`:
```nix
# config.nix
let
  secrets = import ./secrets.nix;
in
{
  programs.git = {
    userEmail = secrets.email;
  };
}
```

Add to `.gitignore`:
```
secrets.nix
```

Create `secrets.nix.example` as a template:
```nix
# secrets.nix.example
{
  email = "user@example.com";
  apiKey = "your-api-key-here";
}
```

### 3. sops-nix (Recommended for Advanced Users)
Encrypts secrets in git using age or PGP keys.

Install:
```nix
# In your flake.nix inputs
sops-nix.url = "github:Mic92/sops-nix";
```

Usage:
```nix
# Create encrypted secrets file
sops secrets.yaml

# Reference in config
sops.secrets.example-key = {};
```

See: https://github.com/Mic92/sops-nix

### 4. agenix
Similar to sops-nix, uses age encryption.

See: https://github.com/ryantm/agenix

## Quick Reference

| Method | Complexity | Best For |
|--------|------------|----------|
| Environment Variables | Low | Runtime configs, simple secrets |
| Untracked File | Low | Personal configs, development |
| sops-nix | Medium | Team environments, multiple machines |
| agenix | Medium | NixOS systems, declarative secrets |

## For This Repository

This repo uses the **separate untracked file** approach:
- Create `secrets.nix` with your sensitive data
- Import it in `config.nix` where needed
- Never commit `secrets.nix` to git
