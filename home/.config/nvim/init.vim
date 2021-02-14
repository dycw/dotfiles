" settings: casing
set ignorecase
set smartcase

" settings: line numbers
set number
set relativenumber

" settings: read files automatically
set autoread

" settings: scrolling
set scrolloff=5
set sidescrolloff=5

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

" mappings: shift blocks visually
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
nnoremap <C-w><C-w> <C-w>p

" mappings: quit
nnoremap <C-q> :q<CR>

" vim-plug
call plug#begin(stdpath('data') . '/plugged')

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

" ncm2
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" NOTE: you need to install completion sources to get completions. Check
" our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'

" suppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" wrap existing omnifunc
" Note that omnifunc does not run in background and may probably block the
" editor. If you don't want to be blocked by omnifunc too often, you could
" add 180ms delay before the omni wrapper:
"  'on_complete': ['ncm2#on_complete#delay', 180,
"               \ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
au User Ncm2Plugin call ncm2#register_source({
        \ 'name' : 'css',
        \ 'priority': 9,
        \ 'subscope_enable': 1,
        \ 'scope': ['css','scss'],
        \ 'mark': 'css',
        \ 'word_pattern': '[\w\-]+',
        \ 'complete_pattern': ':\s*',
        \ 'on_complete': ['ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
        \ })

" make it fast
let ncm2#popup_delay = 5
let ncm2#complete_length = [[1, 1]]

" Use new fuzzy based matches
let g:ncm2#matcher = 'substrfuzzy'

" plugins: nerdcommenter
Plug 'preservim/nerdcommenter'

" plugins:
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-eunuch'
Plug 'farmergreg/vim-lastplace'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'christoomey/vim-tmux-navigator'

" plugins: vim-fugitive
Plug 'tpope/vim-fugitive'
nnoremap gd :Gdiff<CR>
nnoremap gs :Gstatus<CR>
nnoremap gp :Git push<CR>

" plugins: vim-lightline
Plug 'itchyny/lightline.vim'
let g:lightline = {'component_function': {'filename': 'LightlineFilename'}}

function! LightlineFilename()
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  else
    return expand('%')
  endif
endfunction

call plug#end()
