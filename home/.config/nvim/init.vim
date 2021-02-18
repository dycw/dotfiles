" =============================================================================
" settings
" =============================================================================
" casing
set ignorecase
set smartcase

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

" line numbers
set number
set relativenumber

" pasting
nnoremap <F2> :set pastetoggle<Bar>:set expandtab<CR>

" scrolling
set scrolloff=5
set sidescrolloff=5

" spaces and tabs
set expandtab
set list
set shiftwidth=2
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

" update (coc.nvim, vim-signify)
set updatetime=100

" =============================================================================
" mappings
" =============================================================================
" leader
let mapleader=' '

" ex mode disabled
noremap Q <Nop>

" insert -> normal mode
inoremap jk <Esc>
inoremap kj <Esc>

" quit
nnoremap <C-q> :q<CR>

" save
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
vnoremap <C-s> <Esc>:w<CR>

" shift blocks visually (https://bit.ly/3alZUhL)
vnoremap > >gv
vnoremap < <gv

" windows
nnoremap <C-w>h     :set nosplitright<Bar>:vsplit<Bar>:set splitright<CR>
nmap     <C-w><C-h> <C-w>h
nnoremap <C-w>j     :split<CR>
nmap     <C-w><C-j> <C-w>j
nnoremap <C-w>k     :set nosplitbelow<Bar>:split<Bar>:set splitbelow<CR>
nmap     <C-w><C-k> <C-w>k
nnoremap <C-w>l     :vsplit<CR>
nmap     <C-w><C-l> <C-w>l
nnoremap <C-w>w     <C-w><C-p>
nmap     <C-w><C-w> <C-w>w

" yank (https://bit.ly/2M2qG5n)
nnoremap Y y$
vnoremap Y y$

" =============================================================================
" python host
" =============================================================================
let conda_default_env = $CONDA_DEFAULT_ENV
if conda_default_env == 'base'
  let env_name = 'neovim'
else
  let env_name = conda_default_env
endif
let bin_python = expand('~') . '/miniconda3/envs/' . env_name . '/bin/python'
if filereadable(bin_python)
  let g:python3_host_prog = bin_python
endif

" =============================================================================
" plugins
" =============================================================================
call plug#begin(stdpath('data') . '/plugged')

" =============================================================================
" plugins: coc.nvim
" =============================================================================
Plug 'neoclide/coc.nvim', {
  \ 'do': { -> coc#util#install() },
  \ 'branch': 'release',
  \ 'tag': '*',
  \ }

let g:coc_global_extensions = [
  \ 'coc-css',
  \ 'coc-dictionary',
  \ 'coc-git',
  \ 'coc-highlight',
  \ 'coc-html',
  \ 'coc-json',
  \ 'coc-lists',
  \ 'coc-pairs',
  \ 'coc-prettier',
  \ 'coc-pyright',
  \ 'coc-sh',
  \ 'coc-snippets',
  \ 'coc-sql',
  \ 'coc-stylelint',
  \ 'coc-syntax',
  \ 'coc-tag',
  \ 'coc-yaml',
  \ 'coc-yank',
  \ ]

" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
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

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

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
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

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
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

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

" Mappings for CoCList
nnoremap <silent><nowait> <space>a :<C-u>CocList diagnostics<cr>| " Show all diagnostics.
nnoremap <silent><nowait> <space>e :<C-u>CocList extensions<cr> | " Manage extensions.
nnoremap <silent><nowait> <space>c :<C-u>CocList commands<cr>   | " Show commands.
nnoremap <silent><nowait> <space>o :<C-u>CocList outline<cr>    | " Find symbol of current document.
nnoremap <silent><nowait> <space>s :<C-u>CocList -I symbols<cr> | " Search workspace symbols.
nnoremap <silent><nowait> <space>j :<C-u>CocNext<CR>            | " Do default action for next item.
nnoremap <silent><nowait> <space>k :<C-u>CocPrev<CR>            | " Do default action for previous item.
nnoremap <silent><nowait> <space>p :<C-u>CocListResume<CR>l     | " Resume latest coc list.

" =============================================================================
" plugins: rest
" =============================================================================
" coc.nvim: sql
let g:LanguageClient_serverCommands = {
  \ 'sql': ['sql-language-server', 'up', '--method', 'stdio'],
  \ }

" command level
Plug 'tpope/vim-eunuch'

" Plug 'airblade/vim-rooter'
let g:rooter_patterns = ['.git']
let g:rooter_change_directory_for_non_project_files = 'current'

" diff
Plug 'will133/vim-dirdiff'

" editing
Plug 'tpope/vim-abolish'

Plug 'jiangmiao/auto-pairs'

Plug 'luochen1990/rainbow'
let g:rainbow_active = 1

" Plug 'junegunn/rainbow_parentheses.vim'

Plug 'AndrewRadev/splitjoin.vim'

Plug 'mbbill/undotree'
nnoremap U :UndotreeToggle<CR>

" set undofile

Plug 'tpope/vim-commentary'

Plug 'junegunn/vim-easy-align'

Plug 'tpope/vim-endwise'
let g:endwise_no_mappings = 1| " https://bit.ly/3dmrs8z

Plug 'tommcdo/vim-exchange'

Plug 'tpope/vim-speeddating'

Plug 'svermeulen/vim-subversive'
" nmap s <plug>(SubversiveSubstitute)            | " figure out where to go
" nmap ss <plug>(SubversiveSubstituteLine)
" nmap S <plug>(SubversiveSubstituteToEndOfLine)

Plug 'tpope/vim-surround'

Plug 'tpope/vim-unimpaired'

Plug 'svermeulen/vim-yoink'
let g:yoinkIncludeDeleteOperations=1
nmap <c-n> <plug>(YoinkPostPasteSwapBack)
nmap <c-p> <plug>(YoinkPostPasteSwapForward)
nmap p <plug>(YoinkPaste_p)
nmap P <plug>(YoinkPaste_P)

" editing: database
Plug 'tpope/vim-dadbod'

Plug 'kristijanhusak/vim-dadbod-completion'

" files and buffers
Plug 'qpkorr/vim-bufkill'

Plug 'wsdjeg/vim-fetch'

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

" fzf
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>c :Commands<CR>
nnoremap <Leader>C :History<CR>
nnoremap <Leader>f :GFiles<CR>
nnoremap <Leader>F :Files<CR>
nnoremap <Leader>h :History<CR>
nnoremap <Leader>H :Helptags!<CR>
nnoremap <Leader>m :Marks<CR>
nnoremap <Leader>M :Maps<CR>
nnoremap <Leader>t :Tags<CR>
nnoremap <Leader>T :BTags<CR>
nnoremap <Leader>w :Windows<CR>
if executable('rg')
  nnoremap <Leader>l :Rg<CR>
else
  nnoremap <Leader>l :Lines<CR>
endif
nnoremap <Leader>L :BLines<CR>

" general
Plug 'tpope/vim-repeat'

Plug 'tpope/vim-sensible'

" git
Plug 'rhysd/committia.vim'
let g:committia_min_window_width=100
let g:committia_edit_window_width=50

Plug 'rhysd/conflict-marker.vim'

Plug 'rhysd/git-messenger.vim'

Plug 'junegunn/gv.vim'

Plug 'tpope/vim-fugitive'
nnoremap <leader>gd :Gvdiff<CR>| " https://bit.ly/3u7Z3ci
nnoremap gdh :diffget //2<CR>|   " ......................
nnoremap gdl :diffget //3<CR>|   " ......................

Plug 'mhinz/vim-signify'

" gruvbox
Plug 'morhetz/gruvbox'
autocmd vimenter * ++nested colorscheme gruvbox

" linting
Plug 'dense-analysis/ale'
let g:ale_disable_lsp = 1| " https://bit.ly/2ZfmdPM
let g:ale_fixers = {'python': ['autoimport', 'black', 'reorder-python-imports']}
let g:ale_fix_on_save = 1
let g:ale_linters = {'python': ['flake8', 'mypy']}
nnoremap <F10> :ALEFix<CR>
nnoremap <F11> <Plug>(ale_previous_wrap)
nnoremap <silent> <C-j> <Plug>(ale_next_wrap)

" navigation
Plug 'preservim/nerdtree'

Plug 'farmergreg/vim-lastplace'

Plug 'andymass/vim-matchup'

Plug 'junegunn/vim-slash'
noremap <plug>(slash-after) zz

Plug 'justinmk/vim-sneak'
let g:sneak#label = 1
let g:sneak#s_next = 1
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" registers
Plug 'junegunn/vim-peekaboo'

" sessions
Plug 'tpope/vim-obsession'

" status bar
Plug 'vim-airline/vim-airline'
let g:airline#extensions#ale#enabled = 1

" style
Plug 'ryanoasis/vim-devicons'

" tags
Plug 'majutsushi/tagbar'
nnoremap <F8> :TagbarToggle<CR>

Plug 'liuchengxu/vista.vim'

" text objects
Plug 'wellle/targets.vim'

Plug 'terryma/vim-expand-region'

Plug 'michaeljsmith/vim-indent-object'

Plug 'justinmk/vim-ipmotion'

Plug 'rhysd/vim-textobj-anyblock'
Plug 'kana/vim-textobj-user' | " vim-textobj-anyblock

" tmux
Plug 'christoomey/vim-tmux-navigator'

Plug 'wellle/tmux-complete.vim'
Plug 'prabirshrestha/async.vim'        | " for tmux-complete
Plug 'prabirshrestha/asyncomplete.vim' | " for tmux-complete

" viewing
Plug 'wellle/context.vim'
let g:indentLine_char = '▏'

Plug 'Yggdroot/indentLine'

Plug 'wellle/visual-split.vim'

call plug#end()
