set dotenv-load := true
set positional-arguments := true

@setup-macbook *args:
  python3 -m install.machines.macbook "$@"
