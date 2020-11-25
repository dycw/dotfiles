" =============================================================================
" settings
" =============================================================================
set autoread
set clipboard=unnamed
set colorcolumn=80
set completeopt+=noselect                                          " MUcomplete
set expandtab
set gdefault
set ignorecase
set linebreak
set list
set mouse=
set noshowmode
set noswapfile
set number
set pastetoggle=<F2>
set relativenumber
set scrolloff=5
set shiftwidth=2
set shortmess+=c                                                   " MUcomplete
set showtabline=2
set smartcase
set smartindent
set splitbelow
set splitright
set tabstop=2

" =============================================================================
" mappings
" =============================================================================
" clear first
mapclear

" leader
let mapleader=' '

" hotkeys - normal + visual + operator
noremap n F|   " left to character
noremap N T|   " left past character
noremap o f|   " right to character
noremap O t|   " right past character
noremap m ;|   " left/right search forwards
noremap M ,|   " left/right search backwards
noremap f e|   " next end-of-word
noremap F E|   " next end-of-WORD
noremap gf ge| " previous end-of-word
noremap gF gE| " previous end-of-WORD
noremap k n|   " search again
noremap K N|   " search reverse
noremap Y y$|  " yank to end of line

" hotkeys - normal + visual
nnoremap e j|   " down 1 line
vnoremap e j
nnoremap ge gj| " down 1 display line
vnoremap ge gj
nnoremap i k|   " up 1 line
vnoremap i k
nnoremap gi gk| " up 1 display line
vnoremap gi gk
nnoremap E <C-d>|     " down 1/2 screen
vnoremap E <C-d>
nnoremap I <C-U>|     " up 1/2 screen
vnoremap I <C-U>
nnoremap j m|         " mark set
vnoremap j m
nnoremap J `|         " mark jump
vnoremap J `
nnoremap l o|         " open below
vnoremap l o
inoremap <C-l> <Esc>o
nnoremap L O|         " open above
vnoremap L O

" hotkeys - normal + insert
nnoremap <C-s> :write<CR>|      " write
inoremap <C-s> <Esc>:write<CR>i

" hotkeys - normal
nnoremap h i|  " insert
nnoremap H I|  " insert at beginning
nnoremap Q @q| "stop ex-mode

nnoremap <F3> :nohlsearch<CR>

" hotkeys - windows
nnoremap <C-w>n :set spr!<Bar>:vsp<Bar>:set spr!<CR>| " new window left
nnoremap <C-w>e :split<CR>|                           " new window down
nnoremap <C-w>i :set sb!<Bar>:sp<Bar>:set sb!<CR>|    " new window up
nnoremap <C-w>o :vsplit<CR>|                          " new window right
nnoremap <C-n> <C-w>h|       " select window left
nnoremap <C-e> <C-w><C-w>|   " select window down
nnoremap <C-i> <C-w>W|       " select window up
nnoremap <C-o> <C-w>l|       " select window right
nnoremap <C-l> <C-w>p|       " select window previous

" hotkeys - visual
vnoremap s :s/| " substitute
vnoremap <C-r> "hy:,$s/<C-r>h//gc<Left><Left><Left>| " replace seleced
vnoremap < <gv| " dedent retaining selection
vnoremap > >gv| " indent retaining selection

" hotkeys - insert
inoremap hh <Esc>|      " normal mode

" functions
nnoremap <Leader>rr :source ~/.vimrc<CR>:filetype detect<CR>
  \ :execute ":echo '~/.vimrc reloaded'"<CR>

" tabs
nnoremap <C-t> :tabnew<CR>
nnoremap t1 1gt
nnoremap t2 2gt
nnoremap t3 3gt
nnoremap t4 4gt
nnoremap t5 5gt
nnoremap t6 6gt
nnoremap t7 7gt
nnoremap t8 8gt
nnoremap t9 9gt
nnoremap to gt
nnoremap tn gT
nnoremap tt :execute 'tabn '.g:lasttab<CR>
if !exists('g:lasttab')
  let g:lasttab = 1
endif
autocmd TabLeave * let g:lasttab = tabpagenr()

" quitting
nnoremap <C-q> :q<CR>
vnoremap <C-q> <Esc>
inoremap <C-q> <Esc>:q<CR>
nnoremap <Leader>q <Esc>:q<CR>
nnoremap <Leader>Q <Esc>:qa!<CR>

" terminal back to normal mode
tnoremap <Esc> <C-\><C-n>

" color
colorscheme elflord

" =============================================================================
" plugins
" =============================================================================
" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" auto-pairs
Plug 'jiangmiao/auto-pairs'

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
  elseif executable('ag')
    nnoremap <Leader>l :Ag<CR>
  else
    nnoremap <Leader>l :Lines<CR>
  endif
  nnoremap <Leader>L :BLines<CR>

" NERDCommenter
Plug 'preservim/nerdcommenter'
  let g:NERDCreateDefaultMappings = 0
  nnoremap <Leader>- :call NERDComment(0, "toggle")<CR>
  vnoremap <Leader>- :call NERDComment(0, "toggle")<CR>

" NERDTree
Plug 'preservim/nerdtree'
  nnoremap <Leader>nt :NERDTreeToggle<CR>
  let g:NERDTreeMenuDown = 'e'
  let g:NERDTreeMenuUp = 'i'
  let g:NERDTreeNaturalSort = 1

" scratch.vim
Plug 'mtth/scratch.vim'
  let g:scratch_no_mappings = 1

" vim-bufkill
Plug 'qpkorr/vim-bufkill'
  let g:BufKillCreateMappings = 0
  nnoremap <C-c> :BD<CR>

" vim-eunuch
Plug 'tpope/vim-eunuch'

" vim-exchange
Plug 'tommcdo/vim-exchange'

" vim-mucomplete
Plug 'lifepillar/vim-mucomplete'

" vim-repeat
Plug 'tpope/vim-repeat'

" vim-fugitive
Plug 'tpope/vim-fugitive'
  nnoremap gd :Gdiff<CR>
  nnoremap gs :Gstatus<CR>
  nnoremap gp :Gpush<CR>

" vim-lastplace
Plug 'farmergreg/vim-lastplace'

" vim-lightline
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

" vim-mergetool
Plug 'samoshkin/vim-mergetool'
  let g:mergetool_layout = 'bmr'
  nnoremap <Leader>mt :MergetoolToggle<CR>
  nnoremap <Leader>mn :MergetoolDiffExchangeLeft<CR>
  nnoremap <Leader>mo :MergetoolDiffExchangeRight<CR>

" vim-sensible
Plug 'tpope/vim-sensible'

" vim-signify
Plug 'mhinz/vim-signify'
  highlight SignifySignAdd    ctermfg=green  guifg=#00ff00 cterm=NONE gui=NONE
  highlight SignifySignDelete ctermfg=red    guifg=#ff0000 cterm=NONE gui=NONE
  highlight SignifySignChange ctermfg=yellow guifg=#ffff00 cterm=NONE gui=NONE

" vim-speeddating
Plug 'tpope/vim-speeddating'

" vim-startify
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

" vim-surround
Plug 'tpope/vim-surround'

call plug#end()
