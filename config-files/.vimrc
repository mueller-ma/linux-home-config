" Just to be sure
set nocompatible

execute pathogen#infect()
filetype plugin indent on
"Helptags

" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
"let &runtimepath.=','.vimDir "default, set it only when really needed

" Switch syntax highlighting on
syntax on
" Change colorscheme to desert for better readable comments
colorscheme desert
" Dark background
set background=dark

" Execute astyle (formating text)
map <silent> <F2> gggqG<CR>

" Comment with F3 and uncomment with F4
" Default
map <silent> <F3> :norm I#<CR>
map <silent> <F4> :norm ^x<CR>

" 1 Sign
autocmd BufNewFile,BufRead *vimrc*         map <silent> <F3> :norm I"<CR>
autocmd BufNewFile,BufRead *.php           map <silent> <F3> :norm I;<CR>
" 2 Signs
autocmd BufNewFile,BufRead *.cpp           map <silent> <F3> :norm I//<CR>
autocmd BufNewFile,BufRead *.c             map <silent> <F3> :norm I//<CR>
autocmd BufNewFile,BufRead *.items         map <silent> <F3> :norm I//<CR>
autocmd BufNewFile,BufRead *.rules         map <silent> <F3> :norm I//<CR>
autocmd BufNewFile,BufRead *.sitemap       map <silent> <F3> :norm I//<CR>
autocmd BufNewFile,BufRead *.js            map <silent> <F3> :norm I//<CR>
" Remove 2
autocmd BufNewFile,BufRead *.cpp           map <silent> <F4> :norm ^2x<CR>
autocmd BufNewFile,BufRead *.c             map <silent> <F4> :norm ^2x<CR>
autocmd BufNewFile,BufRead *.items         map <silent> <F4> :norm ^2x<CR>
autocmd BufNewFile,BufRead *.rules         map <silent> <F4> :norm ^2x<CR>
autocmd BufNewFile,BufRead *.sitemap       map <silent> <F4> :norm ^2x<CR>
autocmd BufNewFile,BufRead *.js            map <silent> <F4> :norm ^2x<CR>
" Special
autocmd BufNewFile,BufRead *.xml           map <silent> <F3> vat<esc>a--><esc>'<i<!--<esc>'>$
autocmd BufNewFile,BufRead *.xml           map <silent> <F4> 0vat<esc>C><esc>'<4x<esc>

" Set line numbers
map <silent><F5> :set invnumber<CR>

" Change between tabs with F7 and F8
map <silent><F7> :tabp<CR>
map <silent><F8> :tabn<CR>

" Better pasting
"noremap P ]P
"noremap p ]p

" Switch v and V
noremap v V
noremap V v

" Asytle settings
" for all files
autocmd BufNewFile,BufRead * set formatprg=astyle\ -T4
" for *.cpp
autocmd BufNewFile,BufRead *.cpp set formatprg=astyle\ -T4p

" Ingore case of Q and W in command mode
:command Q q
:command W w
:command WQ wq
:command Wq wq

" Disable Ex Mode
nnoremap Q <Nop>

" Save file as root
cmap w!! w !sudo tee > /dev/null %

" Add new lines without entering insert mode
nnoremap <silent> ö o<ESC>
nnoremap <silent> Ö O<ESC>

" use wildmenu
set wildmenu

" Backup
set backup
"set backupdir=~/.vim/backup
let myBackupDir = expand(vimDir . '/backup')
call system('mkdir ' . myBackupDir)
let &backupdir = myBackupDir

" Show matching brackets
set showmatch

" Show command
set showcmd

" Disable mouse support
set mouse=

" Set Backspace
set backspace=2

" Search options
set hlsearch
set ignorecase
set smartcase
set incsearch
map N Nzz
map n nzz

" Clear highlight from search; commented ones are not working
"noremap <ESC> :noh<CR>
"map <ESC> :let @/ = ""<CR>
"nnoremap <ESC> :noh<CR><CR>
"nnoremap <silent> <esc> :noh<return><esc>
"nnoremap <silent> <esc>^[ <esc>^[

" Smart indent
set smartindent

" Restore cursor
augroup JumpCursorOnEdit
au!
autocmd BufReadPost *
\ if expand("<afile>:p:h") !=? $TEMP |
\   if line("'\"") > 1 && line("'\"") <= line("$") |
\     let JumpCursorOnEdit_foo = line("'\"") |
\     let b:doopenfold = 1 |
\     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
\        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
\        let b:doopenfold = 2 |
\     endif |
\     exe JumpCursorOnEdit_foo |
\   endif |
\ endif
" Need to postpone using "zv" until after reading the modelines.
autocmd BufWinEnter *
\ if exists("b:doopenfold") |
\   exe "normal zv" |
\   if(b:doopenfold > 1) |
\       exe  "+".1 |
\   endif |
\   unlet b:doopenfold |
\ endif
augroup END

" Persistent undo
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undo')
    " Create dirs
    call system('mkdir ' . vimDir)
    call system('mkdir ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
    set undolevels=1000
    set undoreload=10000
endif

function! FixArrowkeys()
    imap <ESC>oA <ESC>ki
    imap <ESC>oB <ESC>ji
    imap <ESC>oC <ESC>li
    imap <ESC>oD <ESC>hi
endfunction

" Switch tabs more easy
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" New and untested stuff

"let g:clipbrdDefaultReg = '+'

"Status line
set laststatus=2
"set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

" Todo List
"function! TodoListMode()
   "e ~/.todo.otl
   ""Calendar
   "wincmd l
   "set foldlevel=1
   "tabnew ~/.notes.txt
   "tabfirst
   "" or 'norm! zMzr'
"endfunction"
"
"nnoremap <silent> <Leader>todo :execute TodoListMode()<CR>

" Spell checking
"if version >= 700
   "set spl=en spell
   ""set nospell
"endif
