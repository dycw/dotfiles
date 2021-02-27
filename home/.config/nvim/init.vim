" =============================================================================
" settings
" =============================================================================
" casing
set ignorecase
set smartcase

" column
set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

" coc.nvim
set cmdheight=2
set hidden
set nobackup
set nowritebackup
set shortmess+=c
set signcolumn=yes
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" folding
set foldlevel=99
set foldmethod=indent

" history
set viminfo='1000

" line numbers
set number
set relativenumber

" pasting (https://bit.ly/3pwr6yE)
nnoremap <F2> :call TogglePaste()<CR>
function! TogglePaste()
  if(&paste == 0)
    set paste
  else
    set nopaste
  endif
  set expandtab
endfunction

" scrolling
set scrolloff=20
set sidescrolloff=5

" spaces and tabs
set expandtab
set list
set shiftwidth=2
set smartindent
set softtabstop=2
set tabstop=2

" status bar
set noshowmode
set noruler
set laststatus=0
set noshowcmd

" substitute globally
set gdefault

" swap files
set noswapfile

" tab pages
set showtabline=2

" update time
set updatetime=50

" =============================================================================
" mappings
" =============================================================================
" leader
let mapleader=' '
let maplocalleader='\\'

" command mode
nnoremap <CR> :
vnoremap <CR> :

" insert -> normal mode
inoremap jk <Esc>
inoremap kj <Esc>

" quit
nnoremap <C-q> :q<CR>

" save
nnoremap <C-s> :w<CR>
vnoremap <C-s> <Esc>:w<CR>
inoremap <C-s> <Esc>:w<CR>

" search
nnoremap <Esc> :nohlsearch<CR>
vnoremap <Esc> :nohlsearch<CR>

" shift blocks visually (https://bit.ly/3alZUhL)
vnoremap > >gv
vnoremap < <gv

" source
nnoremap <leader>in :source $XDG_CONFIG_HOME/nvim/init.vim<Bar>
  \ :echo '$XDG_CONFIG_HOME/nvim/init.vim sourced'<CR>

" unneeded
nnoremap K <Nop>
vnoremap K <Nop>
nnoremap Q <Nop>
vnoremap Q <Nop>

" windows
nnoremap <C-w>h     :set nosplitright<Bar>:vsplit<Bar>:set splitright<CR>
nnoremap <C-w><C-h> :set nosplitright<Bar>:vsplit<Bar>:set splitright<CR>
nnoremap <C-w>j     :split<CR>
nnoremap <C-w><C-j> :split<CR>
nnoremap <C-w>k     :set nosplitbelow<Bar>:split<Bar>:set splitbelow<CR>
nnoremap <C-w><C-k> :set nosplitbelow<Bar>:split<Bar>:set splitbelow<CR>
nnoremap <C-w>l     :vsplit<CR>
nnoremap <C-w><C-l> :vsplit<CR>
nnoremap <C-w>w     <C-w><C-p>
nnoremap <C-w><C-w> <C-w><C-p>
nnoremap <C-w>m     <C-w>_<C-w><Bar>
nnoremap <C-w><C-m> <C-w>_<C-w><Bar>

" wrapped lines (https://bit.ly/2Zwqnmg)
nnoremap k  gk
vnoremap k  gk
nnoremap j  gj
vnoremap j  gj
nnoremap gk k
vnoremap gk k
nnoremap gj j
vnoremap gj j
nnoremap ^  g^
vnoremap ^  g^
nnoremap g^ ^
vnoremap g^ ^
nnoremap _  g_
vnoremap _  g_

" yank (https://bit.ly/2M2qG5n)
nnoremap Y y$
vnoremap Y y$

" =============================================================================
" python host
" =============================================================================
if has('nvim')
  let bin_python = $XDG_CACHE_HOME . '/pynvim/bin/python'
  if filereadable(bin_python)
    let g:python3_host_prog = bin_python
  endif
endif

" =============================================================================
" plugins
" =============================================================================
if has('nvim')
  call plug#begin(stdpath('data') . '/plugged')
else
  call plug#begin('~/.vim/plugged')
endif

Plug 'tpope/vim-sensible'

if has('nvim')
" =============================================================================
" plugins: ALE
" =============================================================================
Plug 'dense-analysis/ale'
  let g:ale_cache_executable_check_failures = 1
  let g:ale_disable_lsp = 1| " https://bit.ly/2ZfmdPM
  let g:ale_fix_on_save = 1
  let g:ale_fixers = {
  \ 'python': ['autoimport', 'reorder-python-imports'],
  \ }
  let g:ale_linters = {
    \ }
  let g:ale_linters_explicit = 1
  let g:ale_sign_column_always = 1
  let g:ale_use_global_executables = 1
  let g:ale_warn_about_trailing_blank_lines = 0
  let g:ale_warn_about_trailing_whitespace = 0

" =============================================================================
" plugins: coc.nvim
" =============================================================================
Plug 'neoclide/coc.nvim', {
  \ 'do': { -> coc#util#install() },
  \ 'branch': 'release',
  \ 'tag': '*',
  \ }

let g:coc_global_extensions = [
  \ 'coc-actions',
  \ 'coc-browser',
  \ 'coc-css',
  \ 'coc-diagnostic',
  \ 'coc-dictionary',
  \ 'coc-fzf-preview',
  \ 'coc-highlight',
  \ 'coc-html',
  \ 'coc-json',
  \ 'coc-just-complete',
  \ 'coc-lists',
  \ 'coc-markdownlint',
  \ 'coc-marketplace',
  \ 'coc-pairs',
  \ 'coc-prettier',
  \ 'coc-pyright',
  \ 'coc-sh',
  \ 'coc-snippets',
  \ 'coc-sql',
  \ 'coc-stylelint',
  \ 'coc-syntax',
  \ 'coc-tag',
  \ 'coc-toml',
  \ 'coc-vimlsp',
  \ 'coc-word',
  \ 'coc-yaml',
  \ 'coc-yank',
  \ ]

" use tab to trigger completion
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" GoTo code navigation.
nmap gdf <Plug>(coc-definition)
nmap gdk <Plug>(coc-diagnostic-prev)
nmap gdj <Plug>(coc-diagnostic-next)
nmap gi  <Plug>(coc-implementation)
nmap gt  <Plug>(coc-type-definition)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rf <Plug>(coc-refactor)
nmap <leader>rr <Plug>(coc-rename)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ?
  \ coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ?
  \ coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ?
  \ "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ?
  \ "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ?
  \ coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ?
  \ coc#float#scroll(0) : "\<C-b>"

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" coc.nvim: sql
let g:LanguageClient_serverCommands = {
  \ 'sql': ['sql-language-server', 'up', '--method', 'stdio'],
  \ }

" project wide rename (https://bit.ly/2ZNTCkL)
nnoremap <leader>pwr :CocSearch <C-r>=expand('<cword>')<CR><CR>

" =============================================================================
" plugins: fzf
" =============================================================================
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
  let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }
  let g:fzf_preview_window = ['down:50%', 'ctrl-/']
  nnoremap <Leader><Leader> :Commands<CR>
  nnoremap <Leader>ht :<C-u>Helptags!<CR>
  nnoremap <Leader>mp :<C-u>Maps<CR>
  nnoremap <Leader>rg :<C-u>Rg<CR>
  " https://bit.ly/3q5KZwQ
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --hidden --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
    \   fzf#vim#with_preview(), <bang>0)

Plug 'chengzeyi/fzf-preview.vim', { 'as': 'fzf-preview.vim-chengzeyi' }
  nnoremap <Leader>ch :<C-u>FZFHistory:<CR>| " command history
  nnoremap <Leader>fh :<C-u>FZFHistory<CR> | " file history
  nnoremap <Leader>gg :<C-u>FZFGGrep<CR>
  nnoremap <Leader>mm :<C-u>FZFMarks<CR>
  nnoremap <Leader>sh :<C-u>FZFHistory/<CR>| " search history
  nnoremap <Leader>ww :<C-u>FZFWindows<CR>

Plug 'yuki-yano/fzf-preview.vim', {
  \ 'as': 'fzf-preview.vim-yuki-yano',
  \ 'branch': 'release/remote',
  \ 'do': ':UpdateRemotePlugins',
  \ }
  let g:fzf_preview_command = 'bat --color=always --plain {-1}'
  let g:fzf_preview_filelist_command =
    \ 'rg --files --hidden --follow --no-messages -g \!"* *"'
  let g:fzf_preview_lines_command = 'bat --color=always --plain --number'
  nnoremap <Leader>ab  :<C-u>FzfPreviewAllBuffers<CR>
  nnoremap <Leader>bb  :<C-u>FzfPreviewBuffers<CR>
  nnoremap <Leader>bl  :<C-u>FzfPreviewBufferLines<CR>
  nnoremap <Leader>bt  :<C-u>FzfPreviewVistaBufferCtags<CR>
  nnoremap <Leader>cp  :<C-u>FzfPreviewCommandPalette<CR>
  nnoremap <Leader>df  :<C-u>FzfPreviewDirectoryFiles<CR>
  nnoremap <Leader>ga  :<C-u>FzfPreviewGitActions<CR>
  nnoremap <Leader>gf  :<C-u>FzfPreviewGitFiles<CR>
  nnoremap <Leader>gs  :<C-u>FzfPreviewGitStatus<CR>
  nnoremap <Leader>j   :<C-u>FzfPreviewJumps<CR>
  nnoremap <Leader>ll  :<C-u>FzfPreviewLines<CR>
  nnoremap <Leader>lo  :<C-u>FzfPreviewLocationList<CR>
  nnoremap <Leader>mn  :<C-u>FzfPreviewMarks<CR>
  nnoremap <Leader>of  :<C-u>FzfPreviewOldFiles<CR>
  nnoremap <Leader>pf  :<C-u>FzfPreviewProjectFiles<CR>
  " nnoremap <Leader>pg  :<C-u>FzfPreviewProjectGrep<Space>
  " xnoremap <Leader>pg  "sy:FzfPreviewProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
  nnoremap <Leader>pof :<C-u>FzfPreviewProjectOldFiles<CR>
  nnoremap <Leader>puf :<C-u>FzfPreviewProjectMruFiles<CR>
  nnoremap <Leader>pwf :<C-u>FzfPreviewProjectMrwFiles<CR>
  nnoremap <Leader>qf  :<C-u>FzfPreviewQuickFix<CR>
  nnoremap <Leader>t   :<C-u>FzfPreviewVistaCtags<CR>
  nnoremap <Leader>uf  :<C-u>FzfPreviewMruFiles<CR>
  nnoremap <Leader>wf  :<C-u>FzfPreviewMrwFiles<CR>
  nnoremap <Leader>/   :<C-u>FzfPreviewLines<CR>

" =============================================================================
" plugins: coc.nvim + fzf
" =============================================================================
Plug 'antoinemadec/coc-fzf'
  let g:coc_fzf_preview = 'down:50%'
  nnoremap <Leader>cc :<C-u>CocFzfList commands<CR>
  nnoremap <Leader>cl :<C-u>CocFzfList<CR>
  nnoremap <Leader>co :<C-u>CocFzfList outline<CR>
  nnoremap <Leader>cs :<C-u>CocFzfList symbols<CR>
  nnoremap <Leader>y  :<C-u>CocFzfList yank<CR>

" yuki-yano/fzf-preview.vim
  nnoremap <Leader>cd :<C-u>CocCommand fzf-preview.CocCurrentDiagnostics<CR>
  nnoremap <Leader>cr :<C-u>CocCommand fzf-preview.CocReferences<CR>
  nnoremap <Leader>ci :<C-u>CocCommand fzf-preview.CocImplementations<CR>
  nnoremap <Leader>ct :<C-u>CocCommand fzf-preview.CocTypeDefinitions<CR>
  nnoremap <Leader>dd :<C-u>CocCommand fzf-preview.CocDiagnostics<CR>

" =============================================================================
" plugins: rest
" =============================================================================
" database
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-completion'

" editing
Plug 'tpope/vim-abolish'
Plug 'chrisbra/NrrwRgn'
Plug 'luochen1990/rainbow'
  let g:rainbow_active = 1
Plug 'AndrewRadev/splitjoin.vim'
Plug 'mbbill/undotree'
  nnoremap U :UndotreeToggle<CR>
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-commentary'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-endwise'
  let g:endwise_no_mappings = 1| " https://bit.ly/3dmrs8z
Plug 'tommcdo/vim-exchange'
Plug 'Jorengarenar/vim-MvVis'
Plug 'honza/vim-snippets'
Plug 'mg979/vim-visual-multi'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

" directories, files and buffers
Plug 'francoiscabrol/ranger.vim'
  Plug 'rbgrouleff/bclose.vim'
  let g:ranger_map_keys = 0
  nnoremap <leader>rn :Ranger<CR>
Plug 'djoshea/vim-autoread'
Plug 'qpkorr/vim-bufkill'
Plug 'wsdjeg/vim-fetch'
Plug 'farmergreg/vim-lastplace'
Plug 'airblade/vim-rooter'
Plug 'mhinz/vim-startify'
  let g:startify_lists = [
    \ { 'type': 'dir',       'header': ['MRU '. getcwd()] },
    \ { 'type': 'files',     'header': ['MRU']            },
    \ { 'type': 'sessions',  'header': ['Sessions']       },
    \ { 'type': 'bookmarks', 'header': ['Bookmarks']      },
    \ { 'type': 'commands',  'header': ['Commands']       },
    \ ]
  let g:startify_custom_indices = map(range(1,100), 'string(v:val)')
  let g:ascii = []
  let g:startify_custom_header = ['Hello, Derek']

" general
Plug 'glidenote/memolist.vim'
  let g:memolist_path = '$HOME/.memolist'
Plug 'tpope/vim-repeat'

" git
Plug 'rhysd/committia.vim'
  let g:committia_edit_window_width=50
  let g:committia_min_window_width=100
Plug 'rhysd/conflict-marker.vim'
Plug 'rhysd/git-messenger.vim'
Plug 'junegunn/gv.vim'
Plug 'tpope/vim-fugitive'
  nnoremap <Leader>G :Git<CR>

" navigation
Plug 'airblade/vim-matchquote'
Plug 'andymass/vim-matchup'
Plug 'kshenoy/vim-signature'
Plug 'psliwka/vim-smoothie'
Plug 'justinmk/vim-sneak'
  let g:sneak#label = 1
  let g:sneak#s_next = 1
  map f <Plug>Sneak_f
  map F <Plug>Sneak_F
  map t <Plug>Sneak_t
  map T <Plug>Sneak_T
Plug 'vim-utils/vim-vertical-move'

" searching
Plug 'mhinz/vim-grepper'
Plug 'bronson/vim-visual-star-search'

" sessions
Plug 'tpope/vim-obsession'

" status bar
Plug 'vim-airline/vim-airline'
  let g:airline#extensions#ale#enabled = 1
  let g:airline#extensions#hunks#non_zero_only = 1

" style
Plug 'morhetz/gruvbox'
  autocmd vimenter * ++nested colorscheme gruvbox
Plug 'ryanoasis/vim-devicons'

" syntax
Plug 'sheerun/vim-polyglot'

" tags
Plug 'soramugi/auto-ctags.vim'
  let g:auto_ctags = 1
  let g:auto_ctags_set_tags_option = 1
Plug 'liuchengxu/vista.vim'
  function! NearestMethodOrFunction() abort
    return get(b:, 'vista_nearest_method_or_function', '')
  endfunction
  set statusline+=%{NearestMethodOrFunction()}
  autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
  let g:vista_fzf_preview = ['right:50%']
  nnoremap <Leader>v :Vista<CR>
  vnoremap <Leader>v :Vista<CR>

" tests
Plug 'vim-test/vim-test'

" text objects
Plug 'wellle/line-targets.vim'
Plug 'wellle/targets.vim'
Plug 'coderifous/textobj-word-column.vim'
Plug 'terryma/vim-expand-region'
Plug 'michaeljsmith/vim-indent-object'
Plug 'jeetsukumaran/vim-indentwise'
Plug 'justinmk/vim-ipmotion'
Plug 'tommcdo/vim-ninja-feet'
Plug 'rhysd/vim-textobj-anyblock'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-user'| " used by others

" tmux
Plug 'christoomey/vim-tmux-navigator'
Plug 'wellle/tmux-complete.vim'
  Plug 'prabirshrestha/async.vim'
  Plug 'prabirshrestha/asyncomplete.vim'

" unix
Plug 'tpope/vim-eunuch'
Plug 'jez/vim-superman'

" viewing
Plug 'wellle/context.vim'
Plug 'Yggdroot/indentLine'
  let g:indentLine_char = '▏'
  let g:indentLine_setConceal = 0
Plug 'RRethy/vim-illuminate'
Plug 'wellle/visual-split.vim'
Plug 'simeji/winresizer'
  let g:winresizer_start_key = 'Q'
  let g:winresizer_vert_resize = 5

endif
call plug#end()
