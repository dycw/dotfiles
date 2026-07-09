# shellcheck shell=sh
for _base in "${HOME}/work" "${HOME}/work/derek"; do
	_dotfiles="${_base}/qrt-dotfiles"
	if [ ! -d "${_dotfiles}" ]; then continue; fi
	_yaml="${_dotfiles}/tea/config.yml"
	if [ -f "${_yaml}" ]; then
		mkdir -p "${HOME}/.config/tea"
		ln -sfn "${_yaml}" "${HOME}/.config/tea/config.yml"
	fi
done
unset _base _dotfiles _yaml
