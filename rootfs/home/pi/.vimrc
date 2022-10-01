" no compatible; use Vim, not vi (same as set nocompatible)
set nocp

" don't wrap lines
"set nowrap

" keep 3 lines when scrolling
set scrolloff=3

" show vertical and horizontal position
set ruler

" Y = y$ not yy.  More intuative
noremap Y y$

" tilde (~) acts like an operator (à la 'd' or 'c')
"set top

" incremental search (set incsearch)
set is

" ignore case when searching
set ic

" hlsearch: highlight search - show the current search pattern this is a nice
" feature sometimes - but it sure can get in the way sometimes when you edit.
set hlsearch

" show matching ()'s []'s {}'s
set sm

" tabs are 4 spaces long
set tabstop=4

" when autoindent does a tab, it's 4 spaces long
set shiftwidth=4

" always set autoindenting on
"set autoindent
set noautoindent

" smart indent
"set smartindent
set nosmartindent

" cindent
"set cindent
set nocindent

" no need to save to make a :next :previous, etc.
set aw

" TODO comment    
set backspace=2

" turn off error beep/flash
set visualbell t_vb=
set novisualbell
" ...or, no bell sound at all
"set errorbells

" put title in title bar
set title

" smoother changes
set ttyfast

" turn off scrolling, when having issues in putty
set ttyscroll=0

" tabs are converted to space characters
"set et

" remove autocommands just in case
"autocmd!

" don't out in insert mode, TODO comment   
set noinsertmode

" display incomplete commands
set showcmd

" always show status line
set ls=2

" you need digraphs for uumlauts
"set digraph

" TODO comment    
set joinspaces

" show line number, turn off with set nonumber
set number

" allow magic patterns in searches
set magic

" we use bash
set shell=bash

" auto saves changes when quitting and swiching buffer
"set autowrite

" tabs are converted to spaces, use only when required
"set expandtab

" do not keep a backup file
set nobackup

" dictionary: english words first
"set   dictionary=/usr/dict/words

" esckeys: allow usage of cursor keys within insert mode you will find this
" useful when working, eg, on SunOS.
set esckeys

" hidden: allow "hidden" buffers
set hidden

" modeline:
" allow the last line to be a modeline - useful when the last line in sig gives
" the preferred textwidth for replies.
set modeline
set modelines=3

" report: show a report when N lines were changed; report=0 thus means "show all
" changes"!
set report=0

" runtimepath: list of dirs to search for runtime files runtimepath is for Vim-6
" only!
"if version>=600
"  set runtimepath+=~/.vim,~/.vim/after,/usr/share/vim/vim60
"endif

" shiftwidth: number of spaces to use for each insertion of (auto)indent
"set shiftwidth=8
"set shiftwidth=2

" shortmess: kind of messages to show; abbreviate them all!
" new since vim-5.0v: flag 'I' to suppress "intro message".
"set shortmess=at
set shortmess=atI

" showcmd: show current uncompleted command
set showcmd

" showmatch: show the matching bracket for the last ')'
set showmatch

" showmode: show the current mode
set showmode

" don't jump to first character when paging
set nostartofline

" splitbelow: Create new window below current one
set splitbelow

" ttyscroll: turn off scrolling -> faster!
"set ttyscroll=0

" move freely between files
set whichwrap=<,>,h,l,[,]

" wildchar the char used for "expansion" on the command line default value is
" "<C-E>" but I prefer the tab key:
set   wildchar=<TAB>

" wrapmargin
set wrapmargin=1

" writebackup
set nowritebackup

" syntax highlighting
syntax on
if has("gui_running")
    " See ~/.gvimrc
    set guifont=Monospace\ 10  " use this font
    set lines=50           " height = 50 lines
    set columns=100        " width = 100 columns
    set background=light   " adapt colors for background
    set selectmode=mouse,key,cmd
    set keymodel=
else
    colorscheme elflord    " use this color scheme
    set background=dark    " adapt colors for background
endif

" formatoptions: typing "ESC gq" formats the text to 80 chars per line
" IMPORTANT: this turns off a single textwidth setting (tw), see below
"set formatoptions=cqr
" ...alternatively, break the line automatically after 80 chars
"set tw=80

" print a red bar after 80 characters to mark the limit
if exists('+colorcolumn')
"	set tw=80            " sets text width at 80 chars, apply by typing 'gq'
	set colorcolumn=80   " mark 80 character line limit
else
	" not tested
	au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

if has("autocmd")
    " restore cursor position
    au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

    " filetypes (au = autocmd)
    au FileType helpfile set nonumber      " no line numbers when viewing help
    au FileType helpfile nnoremap <buffer><cr> <c-]>   " Enter selects subject
    au FileType helpfile nnoremap <buffer><bs> <c-T>   " Backspace to go back

    " when using mutt, text width=80
    "au FileType mail,tex set textwidth=80
    au FileType cpp,c,java,sh,pl,php,asp  set autoindent
    au FileType cpp,c,java,sh,pl,php,asp  set smartindent
    au FileType cpp,c,java,sh,pl,php,asp  set cindent
    "au BufRead mutt*[0-9] set tw=80

    " automatically chmod +x Shell and Perl scripts
    "au BufWritePost   *.sh             !chmod +x %
    "au BufWritePost   *.pl             !chmod +x %

    " file formats
    au BufNewFile,BufRead  *.pls    set syntax=dosini
    au BufNewFile,BufRead  modprobe.conf    set syntax=modconf
endif

" keyboard mappings
"map <F1> :previous<CR>  " map F1 to open previous buffer
"map <F2> :next<CR>      " map F2 to open next buffer
"map <silent> <C-N> :silent noh<CR> " turn off highlighted search
"map ,v :sp ~/.vimrc<cr> " edit my .vimrc file in a split
"map ,e :e ~/.vimrc<cr>      " edit my .vimrc file
"map ,u :source ~/.vimrc<cr> " update the system settings from my vimrc file

" write out html file
"map ,h :source $VIM/vim71/syntax/2html.vim<cr>:w<cr>:clo<cr>

" common command line typos
"cmap W w
"cmap Q q

" keyboard mapping for numeric keypad
"imap <Esc>OM <c-m>
" map <Esc>OM <c-m>
"imap <Esc>OP <nop>
" map <Esc>OP <nop>
"imap <Esc>OQ /
" map <Esc>OQ /
"imap <Esc>OR *
" map <Esc>OR *
"imap <Esc>OS -
" map <Esc>OS -

"imap <Esc>Ol +
"imap <Esc>Om -
"imap <Esc>On ,
"imap <Esc>Op 0
"imap <Esc>Oq 1
"imap <Esc>Or 2
"imap <Esc>Os 3
"imap <Esc>Ot 4
"imap <Esc>Ou 5
"imap <Esc>Ov 6
"imap <Esc>Ow 7
"imap <Esc>Ox 8
"imap <Esc>Oy 9
"imap <Esc>Oz 0

" are you used to the Unix commands "alias" and "which"?
"map :alias map
"map :which map

" the command {number}CTRL-G show the current nuffer number, too.
" this is yet another feature that vi does not have.
" as I always want to see the buffer number I map it to CTRL-G.
" pleae note that here we need to prevent a loop in the mapping by
" using the comamnd "noremap"!
"noremap <C-G> 2<C-G>

" define "del" char to be the same backspace (saves a LOT of trouble!)
" as the angle notation cannot be use with the LeftHandSide
" with mappings you must type this in *literally*!
"map <C-V>127 <C-H>
"cmap <C-V>127 <C-H>
" the same for Linux Debian which uses
"imap <Esc>[3~ <C-H>

" go in help
"map   \\   <C-]>

" setup for color highlighing in an xterm
"if &term =~ "xterm"
" if has("terminfo")
"  set t_Co=16
"  set t_Sf=[3%p1%dm
"  set t_Sb=[4%p1%dm
"  set t_vb=
" else
"  set t_Co=16
"  set t_Sf=[3%dm
"  set t_Sb=[4%dm
"  set t_vb=
" endif
"endif


