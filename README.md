# `dotfiles`

Dotfiles

## Install

The setup script installs the QRT CA certificate if needed, then clones from
GitHub.

### GitHub

```sh
curl -fsSL \
  https://raw.githubusercontent.com/dycw/dotfiles/refs/heads/master/setup.sh \
  | sh
```

### Gitea

Works on machines where the QRT CA certificate is already trusted.

```sh
curl -fsSL \
  https://gitea.ai/derek/dotfiles/raw/branch/master/setup.sh \
  | sh
```
