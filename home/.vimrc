set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'preservim/nerdtree'
Plugin 'ryanoasis/vim-devicons'
Plugin 'ayu-theme/ayu-vim'
Plugin 'Yggdroot/indentLine'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'mg979/vim-visual-multi', {'branch': 'master'}

call vundle#end() 

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" NERDTree
" show hidden files (toggle with shift+I)
let NERDTreeShowHidden=1

" character used for vertical divider
set fillchars+=vert:\▏

" start NERDTree and leave the cursor in it.
"autocmd VimEnter * NERDTree

" close vim (incl. nerd tree) if no documents remain open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" switch syntax highlighting on
syntax on

" always show ruler at bottom
set ruler

" don't make foo~ files
set nobackup

" enable line numbers
set nu

" searching
set ignorecase
set smartcase
set hlsearch
set incsearch

" indentation
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
if has("autocmd")
  filetype on
  filetype indent on
  filetype plugin on
endif

" whitespace
if has("multi_byte")
  set encoding=utf-8
  set list listchars=tab:»·,trail:·
else
  set list listchars=tab:>-,trail:.
endif

" enable mouse & backspace
set mouse=a
set bs=2

" enable system clipboard
set clipboard=unnamed

" set theme
set termguicolors " enable true colors support
let g:indentLine_char = ''
let g:indentLine_first_char = ''
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_setColors = 0

"let ayucolor="light"
"let ayucolor="dark"
let ayucolor="mirage"
colorscheme ayu

hi NERDTreeFlags ctermfg=13 guifg=#ffcb65

" syntax highlighting
augroup filetypedetect
  au BufRead,BufNewFile config_* setfiletype dosini
  au BufRead,BufNewFile *.conf setfiletype config
  au BufRead,BufNewFile *.toml setfiletype dosini
augroup END

" key shortcuts
nnoremap <F9> :!%:p<Enter><Enter>
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
nnoremap <C-z> :undo<CR>
nnoremap <leader>q :wq<Enter>
nnoremap <leader>t :tabnew<Enter>
nnoremap <leader>f :Files<Enter>
nnoremap <leader>s :BLines<Enter>

