# `dotfiles`

Dotfiles

## Install

The setup script installs the QRT CA certificate if needed, then clones from
Gitea if reachable or from GitHub otherwise.

### GitHub

Works on any machine, including a fresh install with no QRT CA certificate.

```sh
curl -fsSL \
  https://raw.githubusercontent.com/dycw/dotfiles/refs/heads/master/setup.sh \
  | sh
```

### Gitea

Works on machines where the QRT CA certificate is already trusted (e.g. after
running the GitHub command once, or on a managed device).

```sh
curl -fsSL \
  https://gitea.ai/derek/dotfiles/raw/branch/master/setup.sh \
  | sh
```
