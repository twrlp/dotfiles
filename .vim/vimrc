" Packages
packadd! dracula

" Config
set nocompatible
filetype plugin indent on
syntax on
set hidden

set number
set relativenumber

set wrap
set textwidth=120

set title

set backspace=indent,eol,start

set scrolloff=3
set laststatus=2

set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set copyindent
set expandtab
set noshiftround

set hlsearch
set incsearch
set showmatch
set smartcase

set showmode
set showcmd

" Movement
nnoremap j gj
nnoremap k gk

" Leader
nnoremap <Space> <nop>
let mapleader=" "

" Colors
set termguicolors
set background=dark
"" Custom theme settings
function! s:dracula_tweaks()
  hi link VimwikiHeader2 DraculaOrangeBold
  hi link VimwikiHeader3 DraculaPurpleBold
  hi link VimwikiHeader4 DraculaCyanItalic
endfunction
autocmd! ColorScheme dracula call s:dracula_tweaks()
"" Set colorscheme
colorscheme dracula
"" Disable Background Color Erase
set t_ut=

" Vimwiki
let g:vimwiki_list = [{'path': '~/self/', 'syntax': 'markdown', 'ext': '.md'}]
autocmd! BufRead,BufNewFile *.md :Goyo 120

" Goyo
command! Focus :Goyo 120

function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
  autocmd! TabLeave Focus
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

