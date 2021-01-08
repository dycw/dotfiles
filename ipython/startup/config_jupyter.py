import json
from itertools import chain
from pathlib import Path
from re import findall
from typing import Any
from typing import Dict
from typing import Optional
from urllib.request import urlopen


try:
    from ipykernel import get_connection_file
    from notebook import notebookapp
except ModuleNotFoundError:
    pass
else:

    def get_notebook_path() -> Optional[Path]:
        (kernel_id,) = findall(r"kernel-([\w-]+)\.json$", get_connection_file())

        def parse_server(server: Dict[str, Any]) -> Optional[Path]:
            notebook_dir = server["notebook_dir"]
            token = server["token"]
            url = "".join(
                chain(
                    [server["url"], "api/sessions"],
                    []
                    if token == "" and not server["password"]  # noqa:S105
                    else [f"?token={token}"],
                ),
            )
            response = urlopen(url)  # noqa:S310
            sessions = json.load(response)
            session_results = [
                parse_session(session, notebook_dir) for session in sessions
            ]
            session_results = [
                result for result in session_results if result is not None
            ]
            try:
                (session_result,) = session_results
            except ValueError:
                return None
            else:
                return session_result

        def parse_session(
            session: Dict[str, Any],
            notebook_dir: str,
        ) -> Optional[Path]:
            if session["kernel"]["id"] == kernel_id:
                return Path(notebook_dir, session["notebook"]["path"])
            else:
                return None

        server_results = [
            parse_server(server)
            for server in notebookapp.list_running_servers()
        ]
        server_results = [
            result for result in server_results if result is not None
        ]
        (server_result,) = server_results
        return server_result
