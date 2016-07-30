" Plugins {{{1

" Disable compability with old fashioned Vi
set nocompatible

" Setup directory paths
if has('nvim')
  let s:config_dir = expand(has('win32') ? '$LOCALAPPDATA/nvim' : '~/.config/nvim')
else
  let s:config_dir = expand(has('win32') ? '$USERPROFILE/vimfiles' : '~/.vim')
endif
let s:autoload_dir = s:config_dir . '/autoload'
let s:plugins_dir = s:config_dir . '/plugged'
let s:cache_dir = s:config_dir . '/.cache'

" Setup global variables
let s:first_run = empty(glob(s:autoload_dir . '/plug.vim'))

" Automatically install vim-plug upon first run
if s:first_run
  execute 'silent !curl --create-dirs -fLo ' . shellescape(s:autoload_dir . '/plug.vim') .
    \' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall | windo source $MYVIMRC
endif

" Begin the plugin section
call plug#begin(s:plugins_dir)

" List the required plugins
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'tomtom/tcomment_vim'
Plug 'vim-airline/vim-airline'
Plug 'toiffel/vim-airline-themes'
Plug 'toiffel/vim-hybrid'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'FelikZ/ctrlp-py-matcher'
Plug 'embear/vim-localvimrc'
Plug 'kana/vim-altr'
Plug 'mileszs/ack.vim'
Plug 'qpkorr/vim-bufkill'
Plug 'Raimondi/delimitMate'
Plug 'scrooloose/nerdtree'

" Finish the plugin section, update runtimepath and initialize plugin system
call plug#end()

" Skip the rest of initialization before installing plugins upon first run
if s:first_run
  finish
endif

" Functions {{{1

function! s:GetVisualSelection() " {{{2
  let old_reg = getreg('"')
  let old_reg_type = getregtype('"')
  normal! gv""y
  let selection = getreg('"')
  call setreg('"', old_reg, old_reg_type)
  return selection
endfunction

function! s:SearchVisualSelection(command) " {{{2
  let selection = s:GetVisualSelection()
  let @/ = '\V' . substitute(escape(selection, a:command . '\'), '\n', '\\n', 'g')
  call feedkeys(a:command . @/ . "\<CR>", 'n')
endfunction

function! s:SearchVisualSelectionInFiles() " {{{2
  let selection = s:GetVisualSelection()

  if selection =~ '\n'
    echohl ErrorMsg | echomsg 'Multiline search is not supported' | echohl None
    return
  endif

  let pattern = shellescape(selection)
  call ack#Ack('grep!', '-Q ' . pattern)

  let @/ = '\V' . escape(selection, '\')
  call histadd('/', @/)
  call feedkeys(":let &hlsearch=1 \| echo\<CR>", 'n')
endfunction

" }}}2

" General settings {{{1

" Set the default character encoding
if !has('nvim')
  set encoding=utf-8
endif

" Don't clutter the filesystem with garbage files
set nobackup
set nowritebackup
set noswapfile
set noundofile

" Put unsaved buffers to background when loading new buffers
" without asking to save the current changes first
set hidden

" UI settings {{{1

" Use dark variation of color scheme
set background=dark

" Use colors from custom terminal theme
if !has('gui_running')
  let g:hybrid_custom_term_colors = 1
endif

" Set some eye candy color scheme
colorscheme hybrid

" Set font when running in GUI mode
if has('gui_running')
  if has('gui_gtk2')
    set guifont=Droid\ Sans\ Mono\ Slashed\ 14
  elseif has('gui_macvim')
    set guifont=Menlo\ Regular:h18
  elseif has('gui_win32')
    set guifont=Consolas:h14:cANSI
  endif
endif

" Remove menu bar, toolbar and scrollbars
if has('gui_running')
  set guioptions-=m
  set guioptions-=T
  set guioptions-=l
  set guioptions-=L
  set guioptions-=r
  set guioptions-=R
  set guioptions-=b
endif

" Configure the cursor shape
if has('gui_running')
  set guicursor+=o:block-Cursor,a:blinkon0
elseif has('nvim')
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
elseif &term =~ 'xterm\|rxvt'
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[2 q"
endif

" Turn off annoying beeps/flashes on errors
set noerrorbells
set novisualbell
set t_vb=

" Don't redraw the display while executing macros
set lazyredraw

" Disable soft wrapping of long lines
set nowrap

" Disable hard wrapping of long lines
set textwidth=0

" Show absolute number for the current line and relative numbers for other lines
set number
set relativenumber

" Highlight the line containing the cursor
set cursorline

" Keep the given number of lines above and below the cursor while scrolling
set scrolloff=5

" Enable list mode, show whitespace characters
set listchars=tab:»\ ,space:·,trail:·,extends:>,precedes:<
set list

" Show the current mode on the last line
set showmode

" Show the current command in the bottom right corner
set showcmd

" Edit settings {{{1

" Set width of tabs and indents to 4 spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Always use tabs instead of spaces
set noexpandtab

" Keep the cursor column while jumping or switching between buffers
set nostartofline

" Search settings {{{1

" Highlight all matches of the search pattern
set hlsearch

" Ignore case in search patterns
set ignorecase

" When searching, wrap around the beginning or the end of the file
set wrapscan

" Don't jump to matching brackets while typing
set noshowmatch

" Key mappings {{{1

" Configure the <Leader> key
let mapleader = ','

" Press <Leader> twice for backward searches
nnoremap <Leader><Leader> ,

" Edit/reload Vim configuration file
nmap <silent> <Leader>ve :edit $MYVIMRC<CR>
nmap <silent> <Leader>vr :source $MYVIMRC<CR>

" Fast saving
nmap <silent> <Leader>w :write<CR>

" Save all modified files and build the project
nmap <silent> <Leader>m :wall <Bar> make!<CR>

" Clear the last search highlighting
nmap <silent> <Leader><Space> :nohlsearch<CR>

" Easy navigation between windows
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Make Y yank from the current cursor position to the end of line,
" to be consistent with C and D
nnoremap Y y$

" Replace built-in * and # behavior in Visual mode
xnoremap <silent> * :<C-u>call <SID>SearchVisualSelection('/')<CR>
xnoremap <silent> # :<C-u>call <SID>SearchVisualSelection('?')<CR>

" Plugin settings {{{1

" vim-airline {{{2

" Enable enhanced tabline
let g:airline#extensions#tabline#enabled = 1

" Show only filenames (without full path) in the tabline
let g:airline#extensions#tabline#fnamemod = ':t'

" Define 'straight' tabs in the statusline and tabline
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" ctrlp.vim {{{2

" Set the directory to store cache files
let g:ctrlp_cache_dir = s:cache_dir . '/ctrlp'

" Don't jump to buffer if it's already opened in a window somewhere
" This is useful when opening the same buffer in different windows
let g:ctrlp_switch_buffer = 0

" Do not limit the maximum number of files to scan
let g:ctrlp_max_files = 0

" Use ag to speed up file indexing
if executable('ag')
  let g:ctrlp_user_command = 'ag -l -g "" --nocolor %s'
endif

" Use Python-based matcher to speed up matching
if has('python') || has('python3')
  let g:ctrlp_match_func = {'match' : 'pymatcher#PyMatch'}
endif

" Search in the currently opened buffers
nmap <silent> <Leader>b :CtrlPBuffer<CR>

" localvimrc {{{2

" Don't load local vimrc files in a sandbox
let g:localvimrc_sandbox = 0

" Don't ask before sourcing local vimrc files
let g:localvimrc_ask = 0

" altr {{{2

" Define additional vim-altr rules
call altr#define('%/src/%.c', '%/src/%.cpp', '%/src/%.cc', '%/src/%.m',
  \'%/src/%.mm', '%/include/%.h', '%/include/%.hpp')

" Switch between associated files, e.g. C++ header and implementation
nmap <Leader>a <Plug>(altr-forward)

" ack.vim {{{2

" Specify the default arguments given to ack
let g:ack_default_options = ' -i -s -H --nocolor --nogroup --column'

" Highlight all matches of the search pattern
let g:ackhighlight = 1

" Use ag to speed up file searching
if executable('ag')
  let g:ackprg = 'ag -i --vimgrep'
endif

" Display ack prompt and place the cursor into the quotes
nmap <Leader>/ :Ack!<Space>""<Left>

" Search for currently selected text
xnoremap <silent> <Leader>* :<C-u>call <SID>SearchVisualSelectionInFiles()<CR>
xnoremap <silent> <Leader># :<C-u>call <SID>SearchVisualSelectionInFiles()<CR>

" Search for word under the cursor
nmap <Leader>* :Ack!<CR>

" vim-bufkill {{{2

" Disable predefined bufkill mappings
let g:BufKillCreateMappings = 0

" Delete a buffer without closing the window it was displayed in
nmap <silent> <Leader>x :BW<CR>
nmap <silent> <Leader>X :BW!<CR>

" delimitMate {{{2

" Insert an indent when pressing <CR> inside empty pair of matching characters
let delimitMate_expand_cr = 1

" NERD tree {{{2

" Don't show unneeded 'Press ? for help' label
let NERDTreeMinimalUI = 1

" Sort directories first, then files
let NERDTreeSortOrder = ['\/$', '*']

" Enable case-sensitive sorting
let NERDTreeCaseSensitiveSort = 1

" Display hidden files by default
let NERDTreeShowHidden = 1

" Always show all files, don't ignore anything
let NERDTreeIgnore = []

" Disable cascade opening of directories having only one child subdirectory
let NERDTreeCascadeOpenSingleChildDir = 0

" Quickly toggle NERD tree window
nmap <silent> <Leader>nn :NERDTreeToggle <Bar> setlocal nolist<CR>

" Reveal the current file in NERD tree window
nmap <silent> <Leader>nf :NERDTreeFind <Bar> setlocal nolist<CR>

" }}}2

" vim: fen fdm=marker fmr={{{,}}} fdc=3 et ts=2 sts=2 sw=2