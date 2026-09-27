# `dotfiles`

Dotfiles

## Install

```sh
curl -fsSL \
  https://raw.githubusercontent.com/dycw/dotfiles/refs/heads/master/setup.sh \
  | sh
```

## Packages

### macOS

This setup includes common development tools and applications for macOS.
Notable packages include:

- **tea**: Package manager for Gitea packages (installed automatically on
  macOS)

### Linux

The setup supports Debian x86_64 only; other Linux distributions and
architectures are rejected. Linux
uses Debian packages and user-scoped Rust, Python, and Node.js tools rather than
Homebrew. It is validated on Debian 13. Rust CLI tools use prebuilt binaries
only; cargo-binstall's source-compilation fallback is disabled. Taplo uses its
upstream prebuilt release.

- Development tools: Rust, Go, Node.js, Python tools
- System utilities: Docker, PostgreSQL, Redis, Tailscale
- CLI tools: gh, git, tmux, vim, and common Rust utilities

See `setup.sh` for the complete list of packages.
