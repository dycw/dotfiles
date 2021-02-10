" symlink=~/.config/nvim/init.vim

set number
set pastetoggle=<F2>
set relativenumber

" =============================================================================
" mappings
" =============================================================================
" clear first
mapclear

" leader
let mapleader=' '

" =============================================================================
" plugins
" =============================================================================
" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

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

" vim-fugitive
Plug 'tpope/vim-fugitive'
	nnoremap gd :Gdiff<CR>
	nnoremap gs :Gstatus<CR>
	nnoremap gp :Gpush<CR>

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

call plug#end()
