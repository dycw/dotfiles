from __future__ import annotations


try:
    from ray import init
except ModuleNotFoundError:
    pass
else:
    init(ignore_reinit_error=True)
