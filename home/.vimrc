set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'preservim/nerdtree'
Plugin 'ryanoasis/vim-devicons'
Plugin 'hashivim/vim-terraform'
Plugin 'ayu-theme/ayu-vim'
Plugin 'Yggdroot/indentLine'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'mg979/vim-visual-multi', {'branch': 'master'}

" python plugins
"Plugin 'psf/black'
"autocmd BufWritePre *.py execute ':Black'

call vundle#end()

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" NERDTree
" show hidden files (toggle with shift+I)
let NERDTreeShowHidden=1
let NERDTreeShowLineNumbers=0
autocmd FileType nerdtree set nonumber
autocmd FileType nerdtree set nolist

" character used for vertical divider
"set fillchars+=vert:\▏
set fillchars+=vert:▏,stl:─,stlnc:─

" start NERDTree and leave the cursor in it.
"autocmd VimEnter * NERDTree
" jump to the main window.
"autocmd VimEnter * wincmd p

" close vim (incl. nerd tree) if no documents remain open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

" Path completion with custom source command
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('fd')
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')

" Word completion with custom spec with popup layout option
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

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
"set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
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
let g:indentLine_char = ''
let g:indentLine_first_char = ''
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_setColors = 1

"let ayucolor="light"
"let ayucolor="dark"
let ayucolor="mirage"
colorscheme ayu

hi NERDTreeFlags ctermfg=10 guifg=white
hi StatusLineNC ctermbg=10 guibg=darkgray guifg=white
hi StatusLine ctermbg=10 guibg=darkgray guifg=white
hi VertSplit guibg=default guifg=Gray ctermbg=6 ctermfg=0
hi Normal guibg=000000

" syntax highlighting
augroup filetypedetect
  au BufRead,BufNewFile config_* setfiletype dosini
  au BufRead,BufNewFile *.conf setfiletype config
  au BufRead,BufNewFile *.toml setfiletype dosini
augroup END

" key shortcuts
"let mapleader = ','
nnoremap <F9> :!%:p<Enter><Enter>
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
nnoremap <C-q> :q!<Enter>
nnoremap <leader>z :undo<CR>
nnoremap <leader>t :tabnew<Enter>
nnoremap <leader>w :tabclose<Enter>
nnoremap <leader>f :Files<Enter>
noremap <leader>s :BLines<Enter>

nnoremap <leader>- :sp<Enter>
nnoremap <leader>_ :vsp<Enter>

" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>
