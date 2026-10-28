#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

system_nvim_bin=$(command -v nvim || true)
tmp=$(make_temp_dir)
trap 'cleanup_temp_dir "${tmp}"' EXIT HUP INT TERM

bin_dir="${tmp}/bin"
command_log="${tmp}/commands.log"
mkdir -p "${bin_dir}"

cat >"${bin_dir}/truncate" <<'EOF'
#!/bin/sh
for arg in "$@"; do
	printf 'truncate:%s\n' "${arg}" >>"${COMMAND_LOG}"
done
EOF

cat >"${bin_dir}/nvim" <<'EOF'
#!/bin/sh
for arg in "$@"; do
	printf 'nvim:%s\n' "${arg}" >>"${COMMAND_LOG}"
done
EOF

chmod +x "${bin_dir}/truncate" "${bin_dir}/nvim"

COMMAND_LOG="${command_log}" PATH="${bin_dir}:${PATH}" sh -c \
	'. "${1}/configs/bash/bashrc.d/nvim.sh"; trunc_nvim "$2" "$3"' \
	sh "${test_root}" first-file 'second file'

expected_log='truncate:-s0
truncate:first-file
truncate:second file
nvim:first-file
nvim:second file'
assert_eq "$(cat "${command_log}")" "${expected_log}"

editor=$(PATH="${bin_dir}:${PATH}" bash --noprofile -c \
	'. "${1}/configs/bash/profile.d/editor.sh"; printf "%s|%s" "${EDITOR}" "${VISUAL}"' \
	bash "${test_root}")
assert_eq "${editor}" 'nvim|nvim'

home_dir="${tmp}/home"
mkdir -p "${home_dir}/.bashrc.d"
ln -s "${test_root}/configs/bash/bashrc.d/nvim.sh" "${home_dir}/.bashrc.d/nvim.sh"
: >"${command_log}"
COMMAND_LOG="${command_log}" HOME="${home_dir}" PATH="${bin_dir}:${PATH}" \
	bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic 'trunc-nvim alias-file' \
	>/dev/null 2>/dev/null

expected_log='truncate:-s0
truncate:alias-file
nvim:alias-file'
assert_eq "$(cat "${command_log}")" "${expected_log}"

if [ -n "${system_nvim_bin}" ]; then
	runtime_home="${tmp}/runtime home"
	runtime_config="${tmp}/runtime config"
	runtime_data="${tmp}/runtime data"
	cargo_home="${tmp}/cargo home"
	runtime_result="${tmp}/runtime result"
	mkdir -p "${runtime_config}" "${runtime_data}/nvim/lazy/lazy.nvim/lua/lazy" "${cargo_home}/bin"
	ln -s "${test_root}/configs/neovim" "${runtime_config}/nvim"
	printf '#!/bin/sh\nexit 0\n' >"${cargo_home}/bin/rust-analyzer"
	chmod +x "${cargo_home}/bin/rust-analyzer"
	cat >"${runtime_data}/nvim/lazy/lazy.nvim/lua/lazy/init.lua" <<'EOF'
return {
	setup = function()
		local plugin_files = vim.fn.globpath(vim.fn.stdpath("config") .. "/lua/plugins", "*.lua", true, true)
		for _, plugin_file in ipairs(plugin_files) do
			local spec = assert(loadfile(plugin_file))()
			assert(type(spec) == "table", plugin_file)
		end
	end,
}
EOF
	HOME="${runtime_home}" \
		XDG_CONFIG_HOME="${runtime_config}" \
		XDG_DATA_HOME="${runtime_data}" \
		CARGO_HOME="${cargo_home}" \
		PATH='/usr/bin:/bin' \
		"${system_nvim_bin}" --headless \
		-c "lua vim.fn.writefile({tostring(vim.fn.executable('rust-analyzer')), vim.env.PATH, tostring(vim.o.undofile), vim.o.undodir}, '${runtime_result}')" \
		-c 'qa!'
	assert_eq "$(sed -n '1p' "${runtime_result}")" '1'
	assert_eq "$(sed -n '2p' "${runtime_result}" | cut -d: -f1)" "${cargo_home}/bin"
	assert_eq "$(sed -n '3p' "${runtime_result}")" 'true'
	assert_file_exists "$(sed -n '4p' "${runtime_result}")"
else
	printf '%s\n' 'Skipping Neovim runtime test: Neovim is unavailable' >&2
fi
