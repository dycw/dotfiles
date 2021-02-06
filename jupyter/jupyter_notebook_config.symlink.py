# symlink=~/.jupyter/jupyter_notebook_config.py

c = get_config()  # type: ignore # noqa:F821
c.NotebookApp.browser = "firefox"
