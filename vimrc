" vim-plug settings
call plug#begin()
if has('win32')
  source $HOME/vimfiles/windows-plugin.vimelse
endif
Plug 'scrooloose/nerdtree'
"Plug 'endel/vim-github-colorscheme'
"Plug 'akiicat/vim-github-theme'
Plug 'cormacrelf/vim-colors-github'
"Plug 'pangloss/vim-javascript'
"Plug 'mxw/vim-jsx'
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/coc.nvim'
Plug 'Raimondi/delimitMate'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'

call plug#end()

"
" A (not so) minimal vimrc.
"

" You want Vim, not vi. When Vim finds a vimrc, 'nocompatible' is set anyway.
" We set it explicitely to make our position clear!
set nocompatible

filetype plugin indent on  " Load plugins according to detected filetype.
syntax on                  " Enable syntax highlighting.

set autoindent             " Indent according to previous line.
set expandtab              " Use spaces instead of tabs.
set softtabstop =4         " Tab key indents by 4 spaces.
set shiftwidth  =4         " >> indents by 4 spaces.
set shiftround             " >> indents to next multiple of 'shiftwidth'.

set backspace   =indent,eol,start  " Make backspace work as you would expect.
set hidden                 " Switch between buffers without having to save first.
set laststatus  =2         " Always show statusline.
set display     =lastline  " Show as much as possible of the last line.

set showmode               " Show current mode in command-line.
set showcmd                " Show already typed keys when more are expected.

set incsearch              " Highlight while searching with / or ?.
set hlsearch               " Keep matches highlighted.

set ttyfast                " Faster redrawing.
set lazyredraw             " Only redraw when necessary.

set splitbelow             " Open new windows below the current window.
set splitright             " Open new windows right of the current window.

set cursorline             " Find the current line quickly.
set wrapscan               " Searches wrap around end-of-file.
set report      =0         " Always report changed lines.
set synmaxcol   =200       " Only highlight the first 200 columns.

set list                   " Show non-printable characters.
if has('multi_byte') && &encoding ==# 'utf-8'
  let &listchars = 'tab:▸ ,extends:❯,precedes:❮,nbsp:±'
else
  let &listchars = 'tab:> ,extends:>,precedes:<,nbsp:.'
endif

" The fish shell is not very compatible to other shells and unexpectedly
" breaks things that use 'shell'.
if &shell =~# 'fish$'
  set shell=/bin/bash
endif

" Put all temporary files under the same directory.
" https://github.com/mhinz/vim-galore#temporary-files
set backup
if has('win32')
  set backupdir   =$HOME/vimfiles/backup/
  set directory   =$HOME/vimfiles/swap/
  set undodir     =$HOME/vimfiles/files/undo/
  set viminfo     ='100,n$HOME/vimfiles/files/info/viminfo
else
  set backupdir   =$HOME/.vim/files/backup/
  set directory   =$HOME/.vim/files/swap/
  set undodir     =$HOME/.vim/files/undo/
  set viminfo     ='100,n$HOME/.vim/files/info/viminfo
endif
set backupext   =-vimbackup
set backupskip  =
set updatecount =100
set undofile

" My custom setting
" Theme
set termguicolors
set background=light
colorscheme github

" Line number and clipboard
set number
set clipboard=unnamed

" Remove error bell
set belloff=all

" NERDTREE
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p
autocmd BufEnter * if &modifiable | NERDTreeFind | wincmd p | endif
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif

" Cursor restore to same place after reopen
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview 

" coc.nvim
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

