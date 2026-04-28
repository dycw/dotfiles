#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$(realpath -- "$0")")/lib.sh"

setup_shell_hooks() {
	log "Setting up shell hooks..."
	posix_dir="${xdg_config_home}/posix"
	mkdir -p "${posix_dir}"
	find "${configs}" -maxdepth 2 -type f -name shell.sh | sort | while IFS= read -r script; do
		name=$(basename -- "$(dirname -- "${script}")")
		ln -sfn "${script}" "${posix_dir}/${name}.sh"
	done
	link_config "${configs}/shell/shell.sh" posix/shell.sh
}

setup_static_configs() {
	log "Setting up static configs..."
	link_config "${configs}/bottom/bottom.toml" bottom/bottom.toml
	link_config "${configs}/direnv/direnv.toml" direnv/direnv.toml
	link_config "${configs}/fd/ignore" fd/ignore
	link_config "${configs}/git/config" git/config
	link_config "${configs}/git/ignore" git/ignore
	link_config "${configs}/pgcli/config" pgcli/config
	link_config "${configs}/ripgrep/ripgreprc" ripgrep/ripgreprc
	link_config "${configs}/starship/starship.toml" starship.toml
	link_config "${configs}/tmux/.tmux/.tmux.conf" tmux/tmux.conf
	link_config "${configs}/tmux/tmux.conf.local" tmux/tmux.conf.local
	link_config "${configs}/wezterm/wezterm.lua" wezterm/wezterm.lua
	link_direct "${configs}/ipython/ipython_config.py" "${HOME}/.ipython/profile_default/ipython_config.py"
	link_direct "${configs}/ipython/startup.py" "${HOME}/.ipython/profile_default/startup/startup.py"
	link_direct "${configs}/jupyter/jupyter_lab_config.py" "${xdg_config_home}/jupyter/jupyter_lab_config.py"
	link_direct "${configs}/jupyter/apputils/notification.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/apputils-extension/notification.jupyterlab-settings"
	link_direct "${configs}/jupyter/apputils/themes.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings"
	link_direct "${configs}/jupyter/codemirror/plugin.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/codemirror-extension/plugin.jupyterlab-settings"
	link_direct "${configs}/jupyter/completer/manager.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/completer-extension/manager.jupyterlab-settings"
	link_direct "${configs}/jupyter/console/tracker.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/console-extension/tracker.jupyterlab-settings"
	link_direct "${configs}/jupyter/docmanager/plugin.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/docmanager-extension/plugin.jupyterlab-settings"
	link_direct "${configs}/jupyter/filebrowser/browser.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/filebrowser-extension/browser.jupyterlab-settings"
	link_direct "${configs}/jupyter/fileeditor/plugin.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings"
	link_direct "${configs}/jupyter/jupyterlab_code_formatter/settings.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/jupyterlab_code_formatter/settings.jupyterlab-settings"
	link_direct "${configs}/jupyter/notebook/tracker.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings"
	link_direct "${configs}/jupyter/shortcuts/shortcuts.jsonc" "${xdg_config_home}/jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings"
	link_home "${configs}/pdb/pdbrc" .pdbrc
	link_home "${configs}/psql/psqlrc" .psqlrc
	link_config "${configs}/pudb/pudb.cfg" pudb/pudb.cfg
}

main() {
	log "Setting up '$(hostname)'..."
	setup_bash
	setup_ssh
	setup_shell_hooks
	setup_static_configs
	rm -rf -- "${xdg_config_home}/fish"
}

main
