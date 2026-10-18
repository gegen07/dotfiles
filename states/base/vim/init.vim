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
  call dein#add('Shougo/deoplete.nvim', {'rev': '6.1'})
  call dein#add('preservim/nerdtree', {'rev': '7.1.3'})
  call dein#add('dense-analysis/ale', {'rev': 'v4.0.0'})
  call dein#add('junegunn/fzf', {'rev': 'v0.74.5'})
  call dein#add('fatih/vim-go', {'rev': 'v1.29'})

  " UI
  call dein#add('mhinz/vim-startify', {'rev': 'v1.1'})
  call dein#add('vim-airline/vim-airline', {'rev': 'v0.12'})
  call dein#add('vim-airline/vim-airline-themes', {'rev': '77aab8c6cf7179ddb8a05741da7e358a86b2c3ab'})
  call dein#add('junegunn/goyo.vim', {'rev': '1.6.0'})
  call dein#add('junegunn/limelight.vim', {'rev': '617064e84e896f6f36b5e559f8e6486d632f68ed'})

  " Git
  call dein#add('airblade/vim-gitgutter', {'rev': '90b75207bd9b55d8ac4af15f72b4e935462014d0'})
  call dein#add('tpope/vim-fugitive', {'rev': 'v3.7'})

  "Dracula Theme
  call dein#add('dracula/vim', {'rev': 'v2.0.0'})

  " Language syntax
  call dein#add('sheerun/vim-polyglot', {'rev': 'v4.17.1'})

  " needs to be loaded after most plugins
  call dein#add('ryanoasis/vim-devicons', {'rev': 'v0.11.0'})

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

" NERDTree
map <F2> :NERDTreeToggle<CR> "opens NertTree with Ctrl-n
