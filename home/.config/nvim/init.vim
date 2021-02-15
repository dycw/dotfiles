" settings: casing
set ignorecase
set smartcase

" settings: folding
set foldlevel=99
set foldmethod=indent

" settings: line numbers
set number
set relativenumber

" settings: read files automatically
set autoread

" settings: scrolling
set scrolloff=5
set sidescrolloff=5

" settings: status bar
set noshowmode
set noruler
set laststatus=0
set noshowcmd
set shortmess=F

" settings: substitute globally
set gdefault

" settings: spaces and tabs
set list
set expandtab
set nosmarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2

" settings: tab pages
set showtabline=2

" neovim: python host
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

" mappings: leader
let mapleader=' '

" mappings: clear search highlights
nnoremap <Esc> :nohlsearch<return><Esc>

" mappings: command mode
nnoremap ; :
vnoremap ; :

" mappings: ex mode disabled
noremap Q <Nop>

" mappings: normal mode
imap jk <Esc>
imap kj <Esc>

" settings: pasting
nnoremap <F2> :set pastetoggle<Bar>:set expandtab<CR>

" mappings: save
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
vnoremap <C-s> <Esc>:w<CR>

" mappings: shift blocks visually (https://bit.ly/3alZUhL)
vnoremap > >gv
vnoremap < <gv

" mappings: substitute
vnoremap s :s/
vnoremap <C-r> "hy:,$s/<C-r>h//gc<Left><Left><Left>

" mappings: windows
nnoremap <C-w>h     :set nosplitright<Bar>:vsplit<Bar>:set splitright<CR>
nmap     <C-w><C-h> <C-w>h
nnoremap <C-w>j     :split<CR>
nmap     <C-w><C-j> <C-w>j
nnoremap <C-w>k     :set nosplitbelow<Bar>:split<Bar>:set splitbelow<CR>
nmap     <C-w><C-k> <C-w>k
nnoremap <C-w>l     :vsplit<CR>
nmap     <C-w><C-l> <C-w>l
nnoremap <C-h>      <C-w>h
nnoremap <C-j>      <C-w><C-w>
nnoremap <C-k>      <C-w>W
nnoremap <C-l>      <C-w>l
nnoremap <C-w>w     <C-w>p
nmap     <C-w><C-w> <C-w>w

" mappings: quit
nnoremap <C-q> :q<CR>

" ALE and coc.nvim (https://bit.ly/2ZfmdPM)
let g:ale_disable_lsp = 1

" vim-plug
call plug#begin(stdpath('data') . '/plugged')

" plugins: coc.nvim
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
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

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
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

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
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

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
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#foat#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>l

" plugins: coc.nvim: sql
let g:LanguageClient_serverCommands = {
  \ 'sql': ['sql-language-server', 'up', '--method', 'stdio'],
  \ }

" plugins: editing
Plug 'tpope/vim-abolish'

Plug 'jiangmiao/auto-pairs'

Plug 'tpope/vim-commentary'

Plug 'svermeulen/vim-cutlass'
nnoremap m d
xnoremap m d
nnoremap mm dd
nnoremap M D

Plug 'tpope/vim-speeddating'

Plug 'svermeulen/vim-subversive'
nmap s <plug>(SubversiveSubstitute)
nmap ss <plug>(SubversiveSubstituteLine)
nmap S <plug>(SubversiveSubstituteToEndOfLine)

Plug 'tpope/vim-surround'

Plug 'tpope/vim-unimpaired'

Plug 'svermeulen/vim-yoink'
let g:yoinkIncludeDeleteOperations=1
nmap <c-n> <plug>(YoinkPostPasteSwapBack)
nmap <c-p> <plug>(YoinkPostPasteSwapForward)
nmap p <plug>(YoinkPaste_p)
nmap P <plug>(YoinkPaste_P)

" plugins: editing: database
Plug 'tpope/vim-dadbod'

Plug 'kristijanhusak/vim-dadbod-completion'

" plugins: fzf
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

" plugins: general
Plug 'tpope/vim-repeat'

Plug 'tpope/vim-sensible'

" plugins: git
Plug 'tpope/vim-fugitive'

Plug 'mhinz/vim-signify'

" plugins: gruvbox
Plug 'morhetz/gruvbox'
autocmd vimenter * ++nested colorscheme gruvbox

" plugins: linting
Plug 'dense-analysis/ale'
let g:ale_fixers = {'python': ['autoimport', 'black', 'reorder-python-imports']}
let g:ale_fix_on_save = 1
let g:ale_linters = {'python': ['flake8', 'mypy']}

nnoremap <F10> :ALEFix<CR>
nnoremap <F11> <Plug>(ale_previous_wrap)
nnoremap <silent> <C-j> <Plug>(ale_next_wrap)

  " use <c-space>for trigger completion
  inoremap <silent><expr> <c-space> coc#refresh()

  " use <Tab> to navigate the completion list
  inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" plugins: navigation
Plug 'scrooloose/nerdtree'

Plug 'farmergreg/vim-lastplace'

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

" plugins: status bar
Plug 'vim-airline/vim-airline'
let g:airline#extensions#ale#enabled = 1

" plugins: tags
Plug 'liuchengxu/vista.vim'

""""""""""""""""""""""""""""""
" plugins: unclassified
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-eunuch'
Plug 'christoomey/vim-tmux-navigator'

call plug#end()
