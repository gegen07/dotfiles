if &compatible
  set nocompatible
endif

set shiftround
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set autoindent
set copyindent

set splitbelow
set splitright

set encoding=utf-8

" Stop creating backup and swap files
set noswapfile
set nobackup
set nowb
set number

" Shortcuts

" Required:
set runtimepath+={{ grains.homedir }}/.dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('{{ grains.homedir }}/.dein')
  call dein#begin('{{ grains.homedir }}/.dein')

  " Let dein manage dein
  " Required:
  call dein#add('{{ grains.homedir }}/.dein/repos/github.com/Shougo/dein.vim')

  " Tools
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('scrooloose/nerdtree')
  call dein#add('w0rp/ale')
  call dein#add('valloric/youcompleteme')
  call dein#add('junegunn/fzf')
  call dein#add('terryma/vim-multiple-cursors')
  call dein#add('fatih/vim-go')

  " UI
  call dein#add('mhinz/vim-startify')
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('junegunn/goyo.vim')
  call dein#add('junegunn/limelight.vim')

  " Git
  call dein#add('airblade/vim-gitgutter')
  call dein#add('tpope/vim-fugitive')

  "Dracula Theme
  call dein#add('dracula/vim')

  " Language syntax
  call dein#add('sheerun/vim-polyglot')

  " needs to be loaded after most plugins
  call dein#add('ryanoasis/vim-devicons')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

" Goyo
let g:goyo_width = 150
let g:goyo_height = 90
let g:goyo_linenr = 0


let base16colorspace=256
set background=dark
syntax enable
color dracula

let g:airline_powerline_fonts = 1
let g:deoplete#enable_at_startup = 1

let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1

let g:go_bin_path = $GOPATH."/bin"


call deoplete#custom#option('omni_patterns', {
\ 'go': '[^. *\t]\.\w*',
\})

" NERDTree
map <F2> :NERDTreeToggle<CR> "opens NertTree with Ctrl-n
