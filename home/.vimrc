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
colorscheme jellybeans

" syntax highlighting
augroup filetypedetect
    au BufRead,BufNewFile config_* setfiletype dosini
    au BufRead,BufNewFile *.conf setfiletype config
    au BufRead,BufNewFile *.toml setfiletype dosini
augroup END

" key shortcuts
nnoremap <F9> :!%:p<Enter><Enter>
