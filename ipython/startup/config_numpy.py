from __future__ import annotations


try:
    from numpy import set_printoptions
except ModuleNotFoundError:
    pass
else:
    set_printoptions(suppress=True)
