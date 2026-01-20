set dotenv-load := true
set fallback := true
set positional-arguments := true

@setup-dev-server *args:
  just update
  python3 -m install.machines.dev_server "$@"

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
  git pull-default
  git submodule-update
