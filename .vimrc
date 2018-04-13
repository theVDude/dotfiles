execute pathogen#infect()
syntax on
colors Monokai-rob
set autoread

if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
  set t_Co=256
endif

let mapleader = ","
let g:mapleader = ","
let g:airline_powerline_fonts = 1
let g:ctrlp_map = '<Leader>t'
let g:ctrlp_match_window_bottom = 0
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_dotfiles = 0
let g:ctrlp_switch_buffer = 0
let g:indent_guides_auto_colors = 0

" Fast Saving
nmap <leader>w :w!<cr>

" Fast edit .vimrc
map <leader>e :e! ~/.vimrc<cr>

set foldmethod=indent
set ignorecase
set smartcase
set hlsearch
set incsearch
set hidden
set laststatus=2
set statusline=%n\ %t%y%=%c,%l/%L\ %P
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2

nmap \q :noh<CR>
nmap \e :NERDTreeToggle<CR>
nmap j gj
nmap k gk
nmap <C-e> :b#<CR>
nmap <C-n> :bnext<CR>
nmap <C-p> :bprev<CR>
nmap ; :CtrlPBuffer<CR>

autocmd VimEnter * IndentGuidesEnable
