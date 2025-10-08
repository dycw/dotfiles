set dotenv-load := true
set positional-arguments := true

@setup-mac-book *args:
  python3 -m install.machines.macbook "$@"

@setup-mac-mini *args:
  python3 -m install.machines.mac_mini "$@"

@setup-swift *args:
  python3 -m install.machines.swift "$@"
