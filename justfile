set dotenv-load := true
set positional-arguments := true

@setup-mac-book *args:
  just update
  python3 -m install.machines.macbook "$@"

@setup-mac-mini *args:
  just update
  python3 -m install.machines.mac_mini "$@"

@setup-swift *args:
  just update
  python3 -m install.machines.swift "$@"

@update:
  git pull --force
  git submodule update --init --recursive
  git submodule foreach --recursive 'git checkout -- . && git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed "s#.*/##") && git pull --ff-only'
