# dotfiles

## Introduction

My dotfiles, with the topical organization structure inspired by [Zach Holman](https://github.com/holman/dotfiles).
There are two special files:

- `bashrc` (as I am a `bash` user) will:

  1. Add all folders named `bin/` to your `PATH`,
  2. Source all files named `init.sh`, then
  3. Source all files named `aliases.sh`.

  Note that the:

  1. files/folders can be freely placed in the repo, and
  2. repo itself can be freely located in your `$HOME`.

  Thus, it is very easy to maintain a topical organization structure.
  That is, you can keep all `git` related binaries,
  initialization and aliases under a single `git/` folder (though this is not enforced).
  What is important is that your dotfiles can easily grow and evolve.

- `install`, an executable, will:

  1. Set up `git`,
  2. Set up my SSH key,
  3. Clone the repo,
  4. Set up all symlinks, and
  5. Run all files named `install.sh`.

  By construction, `install`:

  1. is what is used to bootstrap the system, and
  2. runs only what is needed (i.e., it is [idempotent](https://en.wikipedia.org/wiki/Idempotence)),
     and thus is also used to install incremental updates.
  3. looks for symlinks described by lines of the form `symlink=~...`
     in files named `*.symlink*`.
     For example, `bashrc`:

     - Is actually named `bashrc.symlink.sh` in this repo, and
     - Contains the line `# symlink=~/.bashrc`.

     It follows that `install` will link `~/.bashrc` to the file.
     Again, note that the files can still be freely placed in the repo,
     making it very easy to maintain a topical organization structure.
     Simply run `install` again once you have moved your files.

## Installation

```bash
tmp_dir="$(mktemp -d -t dotfiles-XXXXXX)"
wget "https://raw.githubusercontent.com/dycw/dotfiles/master/install" -P "$tmp_dir"
chmod u+x "$tmp_dir/$name"
source "$tmp_dir/$name"
```
