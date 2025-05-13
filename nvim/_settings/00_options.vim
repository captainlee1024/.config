" ====================
" === Editor Setup ===
" ====================
" ===
" === System
" ===
" === 使用系统粘贴板，允许neovim 与系统粘贴板交互
set clipboard+=unnamedplus
let &t_ut=''
" === 自动将neovim 当前工作目录切换到当前打开文件的目录
set autochdir


" ===
" === Editor behavior
" === 编辑器行为
" ===
set number
set relativenumber
set cursorline
set hidden
set noexpandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set list
set listchars=tab:\|\ ,trail:▫
set scrolloff=4
set ttimeoutlen=0
set notimeout
set viewoptions=cursor,folds,slash,unix
set wrap
set tw=0
set indentexpr=
set foldmethod=indent
set foldlevel=99
set foldenable
set formatoptions-=tc
set splitright
set splitbelow
set noshowmode
set showcmd
set wildmenu
set ignorecase
set smartcase
set shortmess+=c
set inccommand=split
set completeopt=longest,noinsert,menuone,noselect,preview
set ttyfast "should make scrolling faster
set lazyredraw "same as above
set visualbell
silent !mkdir -p ~/.config/nvim/tmp/backup
silent !mkdir -p ~/.config/nvim/tmp/undo
"silent !mkdir -p ~/.config/nvim/tmp/sessions
set backupdir=~/.config/nvim/tmp/backup,.
set directory=~/.config/nvim/tmp/backup,.
if has('persistent_undo')
	set undofile
	set undodir=~/.config/nvim/tmp/undo,.
endif
set colorcolumn=100
set updatetime=100
set virtualedit=block

" ===
" === Terminal Behaviors
" === 终端行为
" ===
" === 如果使用了neoterm 插件，自动滚动到底部
let g:neoterm_autoscroll = 1 
" === 打开终端自动进入插入模式
autocmd TermOpen term://* startinsert
" === Ctrl + n 从插入模式切换到normal模式，这个时候就可以使用 leader + q 来退出终端了
tnoremap <C-N> <C-\><C-N>
tnoremap <C-O> <C-\><C-N><C-O>
" === 设置终端的16个基本颜色 (Dracula/Monokai风格的颜色)
let g:terminal_color_0  = '#000000'
let g:terminal_color_1  = '#FF5555'
let g:terminal_color_2  = '#50FA7B'
let g:terminal_color_3  = '#F1FA8C'
let g:terminal_color_4  = '#BD93F9'
let g:terminal_color_5  = '#FF79C6'
let g:terminal_color_6  = '#8BE9FD'
let g:terminal_color_7  = '#BFBFBF'
let g:terminal_color_8  = '#4D4D4D'
let g:terminal_color_9  = '#FF6E67'
let g:terminal_color_10 = '#5AF78E'
let g:terminal_color_11 = '#F4F99D'
let g:terminal_color_12 = '#CAA9FA'
let g:terminal_color_13 = '#FF92D0'
let g:terminal_color_14 = '#9AEDFE'


" experimental
set lazyredraw
"set regexpengine=1
" Explicitly set to auto/new, unless a specific regex needs the old engine
set re=0 
