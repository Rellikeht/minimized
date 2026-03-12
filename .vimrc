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
set shortmess=atsOF " less annoying messages
set mouse=a " enable full mouse experience
set backspace=indent,eol,start " normal backspace behavior unlike default
set wildchar=<Tab> " TODO
set wildmode=list:longest,full " TODO
set wildoptions=tagfile " TODO
set complete=w,b,s,i,d,.,k " helpful (and not too costly) complete sources
" best completion options out there
set completeopt=menu,menuone,noselect,noinsert
set omnifunc=syntaxcomplete#Complete " <C-x>o complete
set cmdwinheight=999999 " more commands in command line window
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
set foldlevelstart=99 " turns out folds closed by default are slow
set showbreak=>\  " wrap indicator
set wrapmargin=1 " size of margin on the right
set undolevels=12000
set history=10000

" those make <Esc> work instantly
set ttimeout
set ttimeoutlen=100
set regexpengine=1 " fastest option (at least for now)
set t_u7= " fixes problems with ssh from windows

set cedit=<C-j> " key to open command-line window in command mode
let mapleader = ','
let maplocalleader = '_'

if v:version >= 900 || has("nvim-0.9")
  set splitkeep=screen " TODO
  set wildoptions+=fuzzy " TODO
endif
if v:version >= 900 || has("nvim-0.11")
  set completeopt+=fuzzy
endif

let g:grep_grepprg = "grep\\ -HEInr\\ $*\\ /dev/null"
let g:rg_grepprg = "rg\\ --vimgrep\\ --hidden\\ -S\\ $*\\ /dev/null"
let g:ag_grepprg = "ag\\ --vimgrep\\ --hidden\\ -S\\ $*\\ /dev/null"
let g:win_grepprg = "findstr\\ /n\\ $*\\ nul"

if has('win32') " windows friendly options, just in case {{{ 
  set shell=powershell.exe
  set shellxquote=
  let &shellcmdflag='-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
  let &shellquote=''
  let &shellpipe='| Out-File -Encoding UTF8 %s'
  let &shellredir='| Out-File -Encoding UTF8 %s'
  execute "set grepprg=".g:win_grepprg
else
  execute "set grepprg=".g:grep_grepprg
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

" Just in case for gui
" Turn off menu bar
set guioptions-=m
" Turn off toolbar
set guioptions-=T

" }}}

" bindings {{{

noremap <C-p> ,
noremap <C-n> ;

noremap <C-h> <C-]>
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
noremap g<C-t> gt
noremap gt :tabnext<CR>

" }}}

" filetype and syntax trickery {{{

" sometimes it is better to have 2 spaces instead of 4
autocmd FileType
      \ python,nix,lua,vim,zig,nim,markdown,ocaml,elixir,haskell,kbd
      \ setlocal softtabstop=2 shiftwidth=2

runtime! ftplugin/man.vim
" I want K doesn't work anyway and <Leader> (,) and <Leader>K may be 
" useful in some other way
autocmd Filetype sh,bash,zsh,csh,tcsh,fish,tcl,ps1
      \ nnoremap <buffer> K :call dist#man#PreGetPage(0)<CR>
silent! unmap <Leader>K

filetype plugin indent on
syntax on

" }}}

" quickfix/loclist management {{{

let g:qfloc = 1

function QFToggle() abort
  let g:qfloc = (g:qfloc + 1) % 2
  if g:qfloc
    echo "Using location list (local)"
  else
    echo "Using quickfix list (global)"
  endif
endfunction

nnoremap ;t :<C-u>call QFToggle()<CR>
nnoremap <silent> <expr> ;w (g:qfloc ? ":lopen" : ":copen")."<CR>"
nnoremap <silent> <expr> ;w (g:qfloc ? ":lopen" : ":copen")."<CR>"
nnoremap <silent> <expr> ;n
      \ ":<C-u>".v:count1.(g:qfloc ? "lnext" : "cnext")."<CR>"
nnoremap <silent> <expr> ;p
      \ ":<C-u>".v:count1.(g:qfloc ? "lprev" : "cprev")."<CR>"
nnoremap <silent> <expr> ;<
      \ ":<C-u>".v:count1.(g:qfloc ? "lolder" : "colder")."<CR>"
nnoremap <silent> <expr> ;>
      \ ":<C-u>".v:count1.(g:qfloc ? "lnewer" : "cnewer")."<CR>"

function QF_C_H() abort
  let l:qpos = getcurpos()
  let l:wid = win_getid()
  execute "normal \<CR>"
  call win_gotoid(l:wid)
  call setpos(".", l:qpos)
endfunction

autocmd FileType qf
      \ nmap <buffer> Z :<C-u>q<CR>
      \ | nnoremap <buffer> <silent> <CR> <CR>zv
      \ | nnoremap <buffer> <silent> <expr> <BS> 
      \ "<CR>zv".(g:qfloc ? ":lclose<CR>" : ":cclose<CR>")
      \ | nnoremap <buffer> <C-h> :<C-u>call QF_C_H()<CR>

function s:prepare_qf_elements(cmd) abort
  return map(
    \ split(system(a:cmd), "\n"),
    \ "{'filename': v:val, 'text': v:val}"
  \ )
endfunction

" little helper to fill quickfix/loclist from shell command
if v:version >= 900 || has("nvim-0.11")
  command! -nargs=1 -complete=shellcmdline CSysExpr
        \ call setqflist(s:prepare_qf_elements(<f-args>), "r")
  command! -nargs=1 -complete=shellcmdline LSysExpr
        \ call setloclist(0, s:prepare_qf_elements(<f-args>), "r")
else
  command! -nargs=1 -complete=shellcmd CSysExpr
        \ call setqflist(s:prepare_qf_elements(<f-args>), "r")
  command! -nargs=1 -complete=shellcmd LSysExpr
        \ call setloclist(0, s:prepare_qf_elements(<f-args>), "r")
endif

" }}}

" pre-load plugin configuration {{{

let g:sneak#prompt = " <sneak> "
let g:sneak#use_ic_scs = 1
let g:sneak#label = 1
let g:sneak#s_next = 0

" }}}

function s:ConfigPlugins() abort " {{{
  " this slightly overcomplicated logic makes configuring plugins work 
  " with on demand loading using special command

  if get(g:, "loaded_aplus", 0) && !get(g:, "configured_aplus", 0)
    let g:configured_aplus = 1
    " TODO
  endif

  if get(g:, "loaded_fugitive", 0) && !get(g:, "configured_fugitive", 0)
    let g:configured_fugitive = 1
    " empty block for completness
  endif

  if get(g:, "loaded_commentary", 0) && !get(g:, "configured_commentary", 0)
    let g:configured_commentary = 1
    " empty block for completness
  endif

  if get(g:, "loaded_sneak_plugin", 0) && !get(g:, "configured_sneak_plugin", 0)
    let g:configured_sneak_plugin = 1
    map <C-n> <Plug>Sneak_;
    map <C-p> <Plug>Sneak_,
    map s <Plug>Sneak_s
    map S <Plug>Sneak_S
    map f <Plug>Sneak_f
    map F <Plug>Sneak_F
    map t <Plug>Sneak_t
    map T <Plug>Sneak_T
  endif

  if get(g:, "loaded_sandwich", 0) && !get(g:, "configured_sandwich", 0)
    let g:configured_sandwich = 1
    runtime! macros/sandwich/keymap/surround.vim

    xmap zs <Plug>(sandwich-add)
    xmap is <Plug>(textobj-sandwich-query-i)
    xmap as <Plug>(textobj-sandwich-query-a)
    xmap iS <Plug>(textobj-sandwich-auto-i)
    xmap aS <Plug>(textobj-sandwich-auto-a)
    omap is <Plug>(textobj-sandwich-query-i)
    omap as <Plug>(textobj-sandwich-query-a)
    omap iS <Plug>(textobj-sandwich-auto-i)
    omap aS <Plug>(textobj-sandwich-auto-a)
  endif

  if get(g:, "loaded_vim_extras", 0) && !get(g:, "configured_vim_extras", 0)
    let g:configured_vim_extras = 1
    nmap <Tab>o :+0TabOpen<Space>
  endif

  if get(g:, "loaded_repeat", 0) && !get(g:, "configured_repeat", 0)
    let g:configured_repeat = 1
    " TODO ?
  endif

  if get(g:, "loaded_ale", 0) && !get(g:, "configured_ale", 0)
    let g:configured_ale = 1
    " there exist machines where it is installed so it would be nice to 
    " configure it even if it isn't as minimal as I want
    " TODO
  endif

  " others {{{

  let g:undotree_SplitWidth = 40
  " fallback for repeat (and sandwich?) not working
  nnoremap <Space>. .

  " }}}

endfunction " }}}

function s:FullConfigCommit() abort

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

  " plugin list {{{

  let l:plugins = [
        \ ['Rellikeht', 'arglist-plus'],
        \ ['Rellikeht', 'vim-extras'],
        \ ['mbbill', 'undotree'],
        \ ['justinmk', 'vim-sneak'],
        \ ['tpope', 'vim-fugitive'],
        \ ['tpope', 'vim-abolish'],
        \ ['tpope', 'vim-eunuch'],
        \ ['tpope', 'vim-tbone'],
        \ ['tpope', 'vim-commentary'],
        \ ['tpope', 'vim-repeat'],
        \ ['wellle', 'targets.vim'],
        \ ['machakann', 'vim-sandwich'],
        \ ['ryvnf', 'readline.vim'],
        \ ]

  " ??
  "mhinz/vim-signify"
  "Rellikeht/lazy-utils"
  "junegunn/fzf"
  "junegunn/fzf.vim"
  "Rellikeht/fzf-vim-extras"

  " ???
  " https://github.com/whiteinge/diffconflicts

  " }}}

  call plug#begin(g:vim_plug_dir) " TODO {{{

  " inform plug about plugins to load
  for [author, plugin] in l:plugins
    " this call is slightly faster than :execute
    call plug#(author."/".plugin, { 'on': [] })
  endfor

  call plug#end()

  " force loading plugins
  for [_, plugin] in l:plugins
    call plug#load(plugin)
  endfor

  " }}}

  call s:ConfigPlugins()
endfunction

" plugins ondemand machinery {{{

function s:FullConfig() abort
  if get(g:, "full_config_applied", 0)
    return
  endif
  let g:full_config_applied = 1
  if get(g:, "vim_started", 0)
    call s:FullConfigCommit()
  else
    " little hack to make this visually faster during vim startup
    autocmd VimEnter * call s:FullConfigCommit()
  endif
endfunction

command! Full call s:FullConfig()
autocmd VimEnter * let g:vim_started = 1
call s:ConfigPlugins()

" }}}

if filereadable(expand('~/.local.vimrc'))
  source ~/.local.vimrc
endif
