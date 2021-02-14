try:
    from ray import init
except ModuleNotFoundError:
    pass
else:
    init(ignore_reinit_error=True)
