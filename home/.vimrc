" Switch syntax highlighting on
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
set tabstop=4
set softtabstop=4
set shiftwidth=4
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
colorscheme jellybeans
