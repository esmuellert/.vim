" vim-plug settings
call plug#begin()
if has('win32')
    if has('nvim')
        source $HOME/AppData/Local/nvim/plugin.vim
    else
        source $HOME/vimfiles/plugin.vim
    endif
else
    if has('nvim')
        source $HOME/.config/nvim/plugin.vim
    else
        source $HOME/.vim/plugin.vim
    endif
endif
"Plug 'scrooloose/nerdtree'
"Plug 'endel/vim-github-colorscheme'
"Plug 'akiicat/vim-github-theme'
"Plug 'pangloss/vim-javascript'
"Plug 'mxw/vim-jsx'
"Plug 'sheerun/vim-polyglot'
"Plug 'Raimondi/delimitMate'
"Plug 'tpope/vim-sleuth'
"Plug 'vim-airline/vim-airline'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-surround'
if !has('nvim')
    Plug 'cormacrelf/vim-colors-github'
else
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'projekt0n/github-nvim-theme'
endif
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
if !has('nvim')
    if has('win32')
        set backupdir   =$HOME/vimfiles/tmp
        set directory   =$HOME/vimfiles/tmp
        set undodir     =$HOME/vimfiles/tmp
        set viminfo     =%,<800,'10,/50,:100,h,f0,n$HOME/vimfiles/viminfo
    else
        set backupdir   =$HOME/.vim/tmp
        set directory   =$HOME/.vim/tmp
        set undodir     =$HOME/.vim/tmp
        set viminfo     =%,<800,'10,/50,:100,h,f0,n$HOME/.vim/viminfo
    endif
else
    if has('win32')
        set backupdir   =~/AppData/Local/nvim/tmp
        set directory   =~/AppData/Local/nvim/tmp
        set undodir     =~/AppData/Local/nvim/tmp
    else
        set backupdir=~/.config/nvim/tmp
        set directory=~/.config/nvim/tmp
        set undodir=~/.config/nvim/tmp
    endif
    set shada=%,'10,<800,:100,/50,h,f0
endif
set backupext   =-vimbackup
set backupskip  =
set updatecount =100
set undofile

" My custom setting
" Theme
set termguicolors
set background=light
if !has('nvim')
    colorscheme github
else
    colorscheme github_light
endif
" Line number and clipboard
set number
set clipboard=unnamed

" Remove error bell
set belloff=all

" Automatically change pwd
"set acd

" Cursor restore to same place after reopen
"augroup AutoSaveGroup
"  autocmd!
"  " view files are about 500 bytes
"  " bufleave but not bufwinleave captures closing 2nd tab
"  " nested is needed by bufwrite* (if triggered via other autocmd)
"  " BufHidden for compatibility with `set hidden`
"  autocmd BufWinLeave,BufLeave,BufWritePost,BufHidden,QuitPre ?* nested silent! mkview!
"  autocmd BufWinEnter ?* silent! loadview
"augroup end

" Automatically reload file
augroup AutoRead
    autocmd!
    autocmd CursorHold * if getcmdwintype() == '' | checktime | endif
augroup END

" Automatically save the session into .vscode
" Capture the directory where Vim was invoked
let g:initial_cwd = getcwd()
" Function to save session when closing Vim
function! SaveVimSession()
    " Check if the .vscode directory exists in the initial directory
    if isdirectory(g:initial_cwd . "/.vscode")
        " Save the session to .vscode/session.vim in the initial directory
        exe 'mksession! ' . g:initial_cwd . '/.vscode/session.vim'
    endif
endfunction
" Automatically save session when exiting Vim
autocmd VimLeavePre * call SaveVimSession()
" Automatically load session when starting Vim if .vscode folder exists
autocmd VimEnter * nested if isdirectory(g:initial_cwd . "/.vscode") && filereadable(g:initial_cwd . "/.vscode/session.vim") | exe 'source ' . g:initial_cwd . '/.vscode/session.vim' | endif

" Path settings
"let &path = getcwd() . '/**'
" set wildignore+=*/node_modules/*,*/.git/*,*/.DS_Store,*/coverage/*,*/dist/*,*/build/*
"let g:netrw_list_hide=netrw_gitignore#Hide()
"execute 'set wildignore+='.substitute(g:netrw_list_hide.',**/.git/*','/,','/**,','g')

" Use PowerShell as Windows shell
if has('win32')
    "  if filereadable('C:\\Program\ Files\\PowerShell\\7\\pwsh.exe')
    "    set shell=C:\\Program Files\\PowerShell\\7\\pwsh.exe
    "  else
    "    set shell=C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe
    "  endif
    " Custom command to run PowerShell commands
    command! -nargs=1 Pwsh execute ':!pwsh -command "& <args>"'
    set shell=cmd
endif

" Bind leaders
let mapleader = ' '

" set ignorecase and smartcase
set ignorecase smartcase

" --------------------------------------------------------------------------
" 🌟 NERDTree
" --------------------------------------------------------------------------
"autocmd VimEnter * NERDTree
"autocmd VimEnter * wincmd p
"autocmd BufEnter * if &modifiable | NERDTreeFind | wincmd p | endif
" Exit Vim if NERDTree is the only window remaining in the only tab.
"autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif
" Close the tab if NERDTree is the only window remaining in it.
"autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif

" --------------------------------------------------------------------------
" 🌟 coc.nvim - Modern LSP for Vim
" --------------------------------------------------------------------------
" :CocInstall coc-tsserver coc-json coc-vimlsp coc-marketplace coc-pairs coc-spell-checker coc-html coc-yaml coc-xml coc-powershell
" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes           

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>fm  <Plug>(coc-format-selected)
nmap <leader>fm  <Plug>(coc-format-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)

" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)

" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)
" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')
" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')
" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> ,a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> ,e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> ,c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> ,o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> ,s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> ,j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> ,k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> ,p  :<C-u>CocListResume<CR>

" --------------------------------------------------------------------------
" 🌟 fzf
" --------------------------------------------------------------------------
nnoremap <leader>p :execute 'Files '.g:initial_cwd<CR>
nnoremap <leader>f :Rg<CR>
nnoremap <leader>b :Buffers<CR>
"if has('win32')
"    let g:fzf_vim.preview_window = []
"    let g:fzf_vim = {}
"    let g:fzf_vim.preview_bash = 'C:\Program Files\Git\usr\bin\bash.exe'
"endif

" --------------------------------------------------------------------------
" 💡 lightline configuration 💡
" --------------------------------------------------------------------------
let g:lightline = {
            \ 'colorscheme': 'ayu_light',
            \ }

" 📖 lua configuration for nvim 📖
" --------------------------------------------------------------------------
if has('nvim')
    if has('win32')
        luafile $HOME/AppData/Local/nvim/nvim.lua
    else
        luafile $HOME/.config/nvim/nvim.lua
    endif
endif
