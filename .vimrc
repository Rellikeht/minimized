" helpers {{{

" }}}

" settings {{{

set nocompatible " why does this even exist
set number relativenumber " <3
set smarttab " just in case really
set expandtab " use spaces instead of tabs
set ignorecase " for smartcase to work
set smartcase " <3
set incsearch " <3
set showmatch " show matching brackets when inserting
set hidden " allow leaving buffers unwritten when jumping
set modeline " it may be useful sometimes
set secure " just in case something is wrong with modelines
set autoindent " auto indent after <CR> in insert mode
set cindent " TODO
set wildmenu " TODO
set termguicolors " TODO
set undofile " undo history persistent throughout editor on and off
set ruler " show line and column in bottom
set autochdir " TODO
set splitright
set splitbelow
set wrap

set notimeout " wait for next key in combination until it is pressed
set noshelltemp " TODO
set noautoread " TODO
set noswapfile " TODO
set noautoread " disable automatic read file when changed from outside

set scrolloff=5 " lines from edge when scrolling
set splitkeep=screen " TODO
set shortmess=atsOF " less annoying messages
set mouse=a " enable full mouse experience
set backspace=indent,eol,start " normal backspace behavior unlike default
set wildchar=<Tab> " TODO
set wildmode=list:longest,full " TODO
set wildoptions=fuzzy,tagfile " TODO
set complete=w,b,s,i,d,.,k " helpful (and not too costly) complete sources
" best completion options out there
set completeopt=menu,menuone,noselect,noinsert,fuzzy
set omnifunc=syntaxcomplete#Complete " <C-x>o complete
set cmdwinheight=25 " more commands in command line window
set redrawtime=5000 " wait longer for drawging (helpful in bigger files)
set pumwidth=50 " to see anything in completion window
set switchbuf+=usetab,useopen " TODO

" TODO document
set listchars+=tab:-->
set listchars+=lead:.
" TODO document
set formatoptions-=j,t
set formatoptions+=croqlwn

set softtabstop=4 " amount of spaces when pressing tab
set shiftwidth=4 " amount of spaces for other indentation
set tabstop=4 " width of tab characters
"set textwidth=80 " TODO does this matter
set maxmempattern=200000 " computers are fast enough for big patterns
set fileencoding=utf8 " why isn't this a default
set updatetime=2000 " waiting for CursorHold and writing to swap 
set conceallevel=1 " show concealled characters under cursor
set foldmethod=marker " I don't like automatic folding
set foldmarker=\ {{{,\ }}} " just in case
set showbreak=>\  " wrap indicator
set wrapmargin=1 " size of margin on the right
set undolevels=12000
set history=10000

" those make <Esc> work instantly
set ttimeout
set ttimeoutlen=100

set cedit=<C-j> " key to open command-line window in command mode
let mapleader = ','
let maplocalleader = '_' " TODO do this better

if has('win32') " windows friendly options, just in case {{{ 
  set shell=powershell.exe
  set shellxquote=
  let &shellcmdflag='-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
  let &shellquote=''
  let &shellpipe='| Out-File -Encoding UTF8 %s'
  let &shellredir='| Out-File -Encoding UTF8 %s'
endif " }}} 

"set background=dark

highlight MatchParen cterm=bold gui=bold

" better diff colors
highlight DiffAdd
            \ ctermbg=DarkGreen guibg=#0d5826
            \ ctermfg=NONE guifg=NONE
highlight DiffText
            \ ctermbg=Gray guibg=#566670
            \ ctermfg=NONE guifg=NONE
highlight DiffChange
            \ ctermbg=DarkBlue guibg=#0f1a7f
            \ ctermfg=NONE guifg=NONE
highlight DiffDelete
            \ ctermbg=DarkRed guibg=#800620
            \ ctermfg=NONE guifg=NONE

let g:markdown_recommended_style = 0
let g:markdown_minlines = 500

" }}}

" bindings {{{

" TODO temporary until vim-sneak is configured properly
map <C-p> ,
map <C-n> ;

map <C-h> <C-]>
nnoremap <C-w><C-h> :<C-u>exe 'tab tag '.Expand('<cword>')<CR>

" n and N do zv when not mapped manually to anything
" and don't when mapped
nnoremap n nzzzv
nnoremap N Nzzzv

" just in case
snoremap <BS> <BS>i

" Primeagen's moving visually selected lines
xnoremap J :m '>+1<CR>gv=gv
xnoremap K :m '<-2<CR>gv=gv

" CTRL-X CTRL-D complete defined identifiers
" CTRL-X CTRL-F complete file names
" CTRL-X CTRL-I complete identifiers
" CTRL-X CTRL-K complete identifiers from dictionary
" CTRL-X CTRL-L complete whole lines
" CTRL-X CTRL-O omni completion
" CTRL-X CTRL-T complete identifiers from thesaurus
" CTRL-X CTRL-U complete with 'completefunc'
" CTRL-X CTRL-V complete like in : command line
" CTRL-X CTRL-] complete tags
inoremap <C-x>d <C-x><C-d>
inoremap <C-x>f <C-x><C-f>
inoremap <C-x>i <C-x><C-i>
inoremap <C-x>k <C-x><C-k>
inoremap <C-x>l <C-x><C-l>
inoremap <C-x>o <C-x><C-o>
inoremap <C-x>t <C-x><C-t>
inoremap <C-x>u <C-x><C-u>
inoremap <C-x>v <C-x><C-v>
inoremap <C-x>j <C-x><C-]>

inoremap <C-Space> <C-@>
inoremap <expr> <C-@> (pumvisible()) ?
      \ '<C-n>' : (&omnifunc == '') ? '<C-n>' : '<C-x><C-o>'

map <Space> <Nop>
map <Space>qh :<C-u>set hlsearch!<CR>
map <Space>qw :<C-u>set wrap!<CR>

" }}}

" {{{

" sometimes it is better to have 2 spaces instead of 4
autocmd FileType
      \ python,nix,lua,vim,zig,nim,markdown,ocaml,elixir,haskell,kbd
      \ setlocal softtabstop=2 shiftwidth=2

runtime! ftplugin/man.vim
filetype plugin on
filetype indent on

" syntax on can take long time and slow down startup
" this hack makes this faster (only) visually
augroup ft_syn
  autocmd!
  autocmd BufEnter *
        \ syntax on
        \ | augroup ft_syn
        \ | autocmd!
        \ | augroup END
augroup END

" }}}

function s:FullConfig() abort

  " vim-plug setup {{{ 

  let g:plug_threads = 32
  let g:vim_share_dir = '~/.local/share/vim'
  let g:vim_plug_dir = g:vim_share_dir..'/plugged'

  " auto install
  let plug_src = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  let g:data_dir = has('nvim') ? stdpath('config') : '~/.vim'
  if empty(glob(g:data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo '.g:data_dir.
          \'/autoload/plug.vim --create-dirs '.plug_src
    autocmd VimEnter * 
          \ PlugInstall --sync | source $MYVIMRC
  endif

  execute "source ".g:data_dir."/autoload/plug.vim"

  " }}} 

  call plug#begin(g:vim_plug_dir) " TODO {{{

  Plug 'Rellikeht/arglist-plus'
  Plug 'Rellikeht/vim-extras'
  Plug 'mbbill/undotree'
  Plug 'justinmk/vim-sneak',
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-abolish'
  Plug 'tpope/vim-eunuch'
  Plug 'tpope/vim-tbone'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-repeat' " ??
  Plug 'wellle/targets.vim'
  Plug 'machakann/vim-sandwich'
  Plug 'ryvnf/readline.vim'

  " ??
  "andymass/vim-matchup"
  "mhinz/vim-signify"
  "junegunn/fzf"
  "junegunn/fzf.vim"
  "Rellikeht/lazy-utils"
  "Rellikeht/fzf-vim-extras"

  " ???
  " https://github.com/whiteinge/diffconflicts

  call plug#end() " }}}

endfunction

command! Full call s:FullConfig()

" TODO plugin configs {{{

" TODO can this be done just here

" }}}

if filereadable(expand('~/.local.vimrc'))
  source ~/.local.vimrc
endif
