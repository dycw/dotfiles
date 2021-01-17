from contextlib import suppress
from pathlib import Path


with open(Path(__file__).resolve().parent.parent.joinpath("imports.py")) as file:
    for line in file:
        try:
            code = compile(line.rstrip("\n"), "", "exec")  # noqa:DUO110
        except SyntaxError:
            pass
        else:
            with suppress(ModuleNotFoundError):
                exec(code)  # noqa:DUO105,S102
