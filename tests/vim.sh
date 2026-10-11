#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2154

set -eu

. "$(dirname -- "$0")/_lib.sh"

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

cat >"${bin_dir}/vim" <<'EOF'
#!/bin/sh
for arg in "$@"; do
	printf 'vim:%s\n' "${arg}" >>"${COMMAND_LOG}"
done
EOF

chmod +x "${bin_dir}/truncate" "${bin_dir}/vim"

COMMAND_LOG="${command_log}" PATH="${bin_dir}:${PATH}" sh -c \
	'. "${1}/configs/bash/bashrc.d/vim.sh"; trunc_vim "$2" "$3"' \
	sh "${test_root}" first-file 'second file'

expected_log='truncate:-s0
truncate:first-file
truncate:second file
vim:first-file
vim:second file'
actual_log=$(cat "${command_log}")
assert_eq "${actual_log}" "${expected_log}"

home_dir="${tmp}/home"
mkdir -p "${home_dir}/.bashrc.d"
ln -s "${test_root}/configs/bash/bashrc.d/vim.sh" "${home_dir}/.bashrc.d/vim.sh"
: >"${command_log}"
COMMAND_LOG="${command_log}" HOME="${home_dir}" PATH="${bin_dir}:${PATH}" \
	bash --noprofile --rcfile "${test_root}/configs/bash/bashrc" -ic 'trunc-vim alias-file' \
	>/dev/null 2>/dev/null

expected_log='truncate:-s0
truncate:alias-file
vim:alias-file'
actual_log=$(cat "${command_log}")
assert_eq "${actual_log}" "${expected_log}"

if vim_bin=$(command -v vim); then
	vim_home="${tmp}/vim home"
	cargo_home="${tmp}/cargo home"
	vim_result="${tmp}/vim result"
	mkdir -p "${vim_home}/.vim/autoload" "${cargo_home}/bin"
	cat >"${vim_home}/.vim/autoload/plug.vim" <<'EOF'
function! plug#begin(...) abort
	let g:plugs = {}
	command! -nargs=* Plug echo
endfunction

function! plug#end() abort
endfunction
EOF
	printf '#!/bin/sh\nexit 0\n' >"${cargo_home}/bin/rust-analyzer"
	chmod +x "${cargo_home}/bin/rust-analyzer"
	HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH='/usr/bin:/bin' "${vim_bin}" \
		-Nu "${test_root}/configs/vimrc" -n -es \
		-c "call writefile([string(executable('rust-analyzer')), \$PATH, join(g:ale_linters.rust, ','), string(g:ale_rust_cargo_use_check), g:ale_lint_on_text_changed], '${vim_result}')" \
		-c 'qa!'
	vim_path_status=$(sed -n '1p' "${vim_result}")
	vim_path=$(sed -n '2p' "${vim_result}")
	vim_rust_linters=$(sed -n '3p' "${vim_result}")
	vim_rust_cargo_use_check=$(sed -n '4p' "${vim_result}")
	vim_lint_on_text_changed=$(sed -n '5p' "${vim_result}")
	assert_eq "${vim_path_status}" '1'
	assert_eq "${vim_path%%:*}" "${cargo_home}/bin"
	assert_eq "${vim_rust_linters}" 'analyzer,cargo'
	assert_eq "${vim_rust_cargo_use_check}" '1'
	assert_eq "${vim_lint_on_text_changed}" 'always'

	vim_autosave_file="${tmp}/vim autosave file"
	vim_autosave_marker="${tmp}/vim autosave marker"
	vim_autosave_script="${tmp}/vim autosave test.vim"
	printf 'initial\n' >"${vim_autosave_file}"
	cat >"${vim_autosave_script}" <<-'EOF'
		autocmd BufWritePost * call writefile(['saved'], $VIM_AUTOSAVE_MARKER, 'a')
		execute 'edit ' . fnameescape($VIM_AUTOSAVE_FILE)
		call setline(1, 'updated')
		doautocmd InsertLeave
		qa!
	EOF
	VIM_AUTOSAVE_FILE="${vim_autosave_file}" \
		VIM_AUTOSAVE_MARKER="${vim_autosave_marker}" \
		HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH='/usr/bin:/bin' \
		"${vim_bin}" -Nu "${test_root}/configs/vimrc" -n -es -S "${vim_autosave_script}"
	assert_eq "$(cat "${vim_autosave_file}")" 'updated'
	assert_eq "$(cat "${vim_autosave_marker}")" 'saved'
else
	printf '%s\n' 'Skipping Vim PATH runtime test: Vim is unavailable' >&2
fi
