from __future__ import annotations


c = get_config()  # type: ignore # noqa: F821
c.InteractiveShellApp.exec_lines = ["%autoreload 2"]
c.InteractiveShellApp.extensions = ["autoreload"]
c.InteractiveShell.ast_node_interactivity = "all"
c.InteractiveShell.autocall = 1
c.InteractiveShell.autoindent = True
c.InteractiveShell.automagic = True
c.InteractiveShell.show_rewritten_input = False
c.TerminalInteractiveShell.confirm_exit = False
c.TerminalInteractiveShell.editing_mode = "vi"
c.TerminalInteractiveShell.editor = "$EDITOR"
c.TerminalInteractiveShell.highlight_matching_brackets = True
