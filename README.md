# dotfiles

## Installation

```bash
tmp_dir="$(mktemp -d -t dotfiles-XXXXXX)"
name=install
wget "https://raw.githubusercontent.com/dycw/dotfiles/master/$name" -P "$tmp_dir"
cd "$tmp_dir" || exit
chmod u+x "$name"
source "$name"
```
