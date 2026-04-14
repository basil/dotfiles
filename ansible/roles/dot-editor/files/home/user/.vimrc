"
" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
"
set nocompatible
execute pathogen#infect()

if (has("termguicolors"))
  set termguicolors
endif

syntax enable
colorscheme nord

set clipboard^=unnamed,unnamedplus
set hidden		" Hide buffers when they are abandoned.
set nobackup		" Do not keep a backup file.
set nojoinspaces	" Use one space after a period.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set tabpagemax=200      " Increase maximum number of tab pages (default is 50)
set titleold=		" Restore old title after leaving Vim.
set title		" Set xterm title.
set visualbell		" Stop vim from beeping on error.

"
" Enables a menu at the bottom of the vim window.
"
set wildmode=list:longest,full

"
" Smart searching options
"
set ignorecase		" Do case insensitive matching.
set infercase		" Infer case for ignorecase keyword completion.
set smartcase		" Ignore ignorecase for uppercase letters in patterns.

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#show_tabs = 1
let g:airline_powerline_fonts = 1
let g:airline_theme="nord"
let vim_markdown_preview_github=1

"
" Don't use Ex mode; use Q for formatting.
"
map Q gq

"
" Switch syntax highlighting on, when the terminal has colors.
" Also switch on highlighting the last used search pattern.
"
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

"
" Only do this part when compiled with support for autocommands.
"
if has("autocmd")
    "
    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    "
    filetype plugin indent on

    "
    " For all text files set 'textwidth' to 80 characters.
    "
    autocmd FileType text setlocal textwidth=80

    "
    " Indentation options
    "
    autocmd FileType ant set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=120
    autocmd FileType bash,sh,c,cpp set tabstop=8|set softtabstop=8|set shiftwidth=8|set noexpandtab|set textwidth=80
    autocmd FileType conf set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=80
    autocmd FileType groovy set tabstop=2|set softtabstop=2|set shiftwidth=2|set expandtab|set textwidth=100
    autocmd FileType java set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=120
    autocmd FileType javascript set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=120
    autocmd FileType json set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=120
    autocmd FileType python set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=80
    autocmd FileType ruby set tabstop=2|set softtabstop=2|set shiftwidth=2|set expandtab|set textwidth=80
    autocmd FileType xml set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=120
    autocmd FileType xsd set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=120
    autocmd Filetype css set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=120
    autocmd Filetype html set tabstop=4|set softtabstop=4|set shiftwidth=4|set expandtab|set textwidth=120
    autocmd Filetype yaml set tabstop=2|set softtabstop=2|set shiftwidth=2|set expandtab|set textwidth=80

    "
    " Set the file type of Gradle files to Groovy.
    "
    autocmd BufNewFile,BufRead *.gradle setf groovy

    "
    " Highlight trailing whitespace.
    "
    highlight ExtraWhitespace ctermbg=red guibg=red
    match ExtraWhitespace /\s\+$/
    autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
    autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
    autocmd InsertLeave * match ExtraWhitespace /\s\+$/
    autocmd BufWinLeave * call clearmatches()
else
    set autoindent smartindent	" Turn on auto/smart indenting.
    set textwidth=80
endif

"
" C-mode formatting options
"   t auto-wrap comment
"   c allows textwidth to work on comments
"   q allows use of gq* for auto formatting
"   l don't break long lines in insert mode
"   r insert '*' on <cr>
"   o insert '*' on newline with 'o'
"   n recognize numbered bullets in comments
"
set formatoptions=tcqlron

"
" C-mode options (cinoptions==cino)
" N	number of spaces
" Ns	number of spaces * shiftwidth
" >N	default indent
" eN	extra indent if the { is at the end of a line
" nN	extra indent if there is no {} block
" fN	indent of the { of a function block
" gN	indent of the C++ class scope declarations (public, private, protected)
" {N	indent of a { on a new line after an if,while,for...
" }N	indent of a } in reference to a {
" ^N	extra indent inside a function {}
" :N	indent of case labels
" =N	indent of case body
" lN	align case {} on the case line
" tN	indent of function return type
" +N	indent continued algibreic expressions
" cN	indent of comment line after /*
" )N	vim searches for closing )'s at most N lines away
" *N	vim searches for closing */ at most N lines away
"
set cinoptions=+0.5s,(0.5s,u0,:0

"
" jj = <Esc>
"
inoremap jj <Esc>
