set dotenv-load := true
set fallback := true
set positional-arguments := true

# set up

@set-up-dev-server *args:
  python3 -m install.machines.dev_server {{args}}

@set-up-mac-book *args:
  python3 -m install.machines.macbook {{args}}

@set-up-mac-mini *args:
  python3 -m install.machines.mac_mini {{args}}

@set-up-swift *args:
  python3 -m install.machines.swift {{args}}
