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
	cat >"${cargo_home}/bin/prek" <<'EOF'
#!/bin/sh
set -eu
printf '%s\n' "$*" >>"${PREK_TEST_LOG}"
case "$*" in
	*'list --output-format json'*)
		case "${PREK_TEST_MODE}" in
		missing) printf '%s\n' '[{"alias":"vim-shfmt"}]' ;;
		taplo) printf '%s\n' '[{"alias":"vim-taplo"}]' ;;
		*) printf '%s\n' '[{"alias":"vim-rustfmt"}]' ;;
		esac
		;;
	*'run --stage manual vim-rustfmt --files'*|*'run --stage manual vim-taplo --files'*)
		file=
		previous=
		for arg in "$@"; do
			if [ "${previous}" = '--files' ]; then
				file=${arg}
				break
			fi
			previous=${arg}
		done
		[ -n "${file}" ] || exit 2
		case "${PREK_TEST_MODE}" in
		skip) printf 'formatter...Skipped\n' ;;
		failure)
			printf 'partial-format\n' >"${file}"
			printf 'formatter failed\n'
			exit 1
			;;
		*) printf 'prek-formatted\n' >"${file}" ;;
		esac
		;;
	*) exit 2 ;;
esac
EOF
	chmod +x "${cargo_home}/bin/rust-analyzer" "${cargo_home}/bin/prek"
	mkdir -p "${vim_home}/.vim/autoload/ale/fixers"
	cat >"${vim_home}/.vim/autoload/ale/fixers/rustfmt.vim" <<'EOF'
function! ale#fixers#rustfmt#Fix(buffer) abort
	return ['native-formatted']
endfunction
EOF
	cat >"${vim_home}/.vim/autoload/ale/fixers/taplo.vim" <<'EOF'
function! ale#fixers#taplo#Fix(buffer) abort
	return ['native-toml-formatted']
endfunction
EOF
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

	vim_filetype_source="${tmp}/vim filetype source.rs"
	vim_filetype_result="${tmp}/vim filetype result"
	printf 'fn main() {}\n' >"${vim_filetype_source}"
	HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH='/usr/bin:/bin' "${vim_bin}" \
		-Nu "${test_root}/configs/vimrc" -n -es "${vim_filetype_source}" \
		-c "call writefile([&filetype], '${vim_filetype_result}')" -c 'qa!'
	assert_eq "$(cat "${vim_filetype_result}")" 'rust'

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

	vim_prek_project="${tmp}/prek project"
	vim_prek_source="${vim_prek_project}/src/source file.rs"
	vim_prek_result="${tmp}/vim prek result"
	vim_prek_log="${tmp}/vim prek log"
	vim_prek_script="${tmp}/vim prek test.vim"
	mkdir -p "${vim_prek_project}/src"
	: >"${vim_prek_project}/prek.toml"
	printf 'fn main() {}\n' >"${vim_prek_source}"
	cat >"${vim_prek_script}" <<-'EOF'
		let result = call(g:ale_fixers.rust[0], [bufnr('%'), ['unformatted']])
		let temp_files = globpath($VIM_PREK_PROJECT . '/src', 'vim-prek-*', 0, 1)
		call writefile(result + ['temp-count=' . string(len(temp_files))], $VIM_PREK_RESULT)
		qa!
	EOF
	PREK_TEST_MODE=rustfmt PREK_TEST_LOG="${vim_prek_log}" \
		VIM_PREK_PROJECT="${vim_prek_project}" VIM_PREK_RESULT="${vim_prek_result}" \
		HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH="${cargo_home}/bin:/usr/bin:/bin" \
		"${vim_bin}" -Nu "${test_root}/configs/vimrc" -n -es "${vim_prek_source}" -S "${vim_prek_script}"
	assert_eq "$(sed -n '1p' "${vim_prek_result}")" 'prek-formatted'
	assert_eq "$(sed -n '2p' "${vim_prek_result}")" 'temp-count=0'

	PREK_TEST_MODE=missing PREK_TEST_LOG="${vim_prek_log}" \
		VIM_PREK_PROJECT="${vim_prek_project}" VIM_PREK_RESULT="${vim_prek_result}" \
		HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH="${cargo_home}/bin:/usr/bin:/bin" \
		"${vim_bin}" -Nu "${test_root}/configs/vimrc" -n -es "${vim_prek_source}" -S "${vim_prek_script}"
	assert_eq "$(sed -n '1p' "${vim_prek_result}")" 'native-formatted'
	assert_eq "$(sed -n '2p' "${vim_prek_result}")" 'temp-count=0'

	PREK_TEST_MODE=skip PREK_TEST_LOG="${vim_prek_log}" \
		VIM_PREK_PROJECT="${vim_prek_project}" VIM_PREK_RESULT="${vim_prek_result}" \
		HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH="${cargo_home}/bin:/usr/bin:/bin" \
		"${vim_bin}" -Nu "${test_root}/configs/vimrc" -n -es "${vim_prek_source}" -S "${vim_prek_script}"
	assert_eq "$(sed -n '1p' "${vim_prek_result}")" 'native-formatted'
	assert_eq "$(sed -n '2p' "${vim_prek_result}")" 'temp-count=0'

	PREK_TEST_MODE=failure PREK_TEST_LOG="${vim_prek_log}" \
		VIM_PREK_PROJECT="${vim_prek_project}" VIM_PREK_RESULT="${vim_prek_result}" \
		HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH="${cargo_home}/bin:/usr/bin:/bin" \
		"${vim_bin}" -Nu "${test_root}/configs/vimrc" -n -es "${vim_prek_source}" -S "${vim_prek_script}"
	assert_eq "$(sed -n '1p' "${vim_prek_result}")" 'unformatted'
	assert_eq "$(sed -n '2p' "${vim_prek_result}")" 'temp-count=0'

	vim_prek_toml_source="${vim_prek_project}/src/settings file.toml"
	vim_prek_toml_result="${tmp}/vim prek toml result"
	vim_prek_toml_script="${tmp}/vim prek toml test.vim"
	printf 'key = "value"\n' >"${vim_prek_toml_source}"
	cat >"${vim_prek_toml_script}" <<-'EOF'
		let result = call(g:ale_fixers.toml[0], [bufnr('%'), ['unformatted']])
		let temp_files = globpath($VIM_PREK_PROJECT . '/src', 'vim-prek-*', 0, 1)
		call writefile(result + ['temp-count=' . string(len(temp_files))], $VIM_PREK_RESULT)
		qa!
	EOF
	PREK_TEST_MODE=taplo PREK_TEST_LOG="${vim_prek_log}" \
		VIM_PREK_PROJECT="${vim_prek_project}" VIM_PREK_RESULT="${vim_prek_toml_result}" \
		HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH="${cargo_home}/bin:/usr/bin:/bin" \
		"${vim_bin}" -Nu "${test_root}/configs/vimrc" -n -es "${vim_prek_toml_source}" -S "${vim_prek_toml_script}"
	assert_eq "$(sed -n '1p' "${vim_prek_toml_result}")" 'prek-formatted'
	assert_eq "$(sed -n '2p' "${vim_prek_toml_result}")" 'temp-count=0'

	PREK_TEST_MODE=missing PREK_TEST_LOG="${vim_prek_log}" \
		VIM_PREK_PROJECT="${vim_prek_project}" VIM_PREK_RESULT="${vim_prek_toml_result}" \
		HOME="${vim_home}" CARGO_HOME="${cargo_home}" PATH="${cargo_home}/bin:/usr/bin:/bin" \
		"${vim_bin}" -Nu "${test_root}/configs/vimrc" -n -es "${vim_prek_toml_source}" -S "${vim_prek_toml_script}"
	assert_eq "$(sed -n '1p' "${vim_prek_toml_result}")" 'native-toml-formatted'
	assert_eq "$(sed -n '2p' "${vim_prek_toml_result}")" 'temp-count=0'
else
	printf '%s\n' 'Skipping Vim PATH runtime test: Vim is unavailable' >&2
fi
