" _____ _____ ____  ______   __  _   ___     _____ __  __
"|_   _| ____|  _ \|  _ \ \ / / | \ | \ \   / /_ _|  \/  |
"  | | |  _| | |_) | |_) \ V /  |  \| |\ \ / / | || |\/| |
"  | | | |___|  _ <|  _ < | |   | |\  | \ V /  | || |  | |
"  |_| |_____|_| \_\_| \_\|_|   |_| \_|  \_/  |___|_|  |_|
"
"  Author: @Terry

" === 第一次使用时自动加载
" === 1. 检测vim-plug 插件管理器有没有被下载，如果没有自动从github 下载
" === 2. nvim启动后自动安装所有插件
" ===
"if empty(glob('~/.config/nvim/autoload/plug.vim'))
"	silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
"				\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
"endif

" ===
" === Create a _machine_specific.vim file to adjust machine specific stuff, like python interpreter location
" === 加载每台机器的特殊配置，比如python的安装位置，预览的默认浏览器等
" === 1. 检查 ~/.config/nvim/ 目录下是否存在一个名为 _machine_specific.vim的文件
" === 2. 如果不存在会从 ~/.config/nvim/default_configs/_machine_specific_default.vim 复制一份
" === 3. source 加载这个文件
" ===
let has_machine_specific_file = 1
if empty(glob('~/.config/nvim/_machine_specific.vim'))
	let has_machine_specific_file = 0
	silent! exec "!cp ~/.config/nvim/default_configs/_machine_specific_default.vim ~/.config/nvim/_machine_specific.vim"
endif
source ~/.config/nvim/_machine_specific.vim

" ===
" === 原生NVIM 核心配置(不包含插件)
" === 这些都是在加载插件之前加载，不依赖插件
" ===
source ~/.config/nvim/_settings/00_options.vim
source ~/.config/nvim/_settings/01_keymaps.vim
source ~/.config/nvim/_settings/02_autocmds.vim
source ~/.config/nvim/_settings/04_functions.vim " Load functions before plugins that might use them

" ===
" === 加载光标配置
" ===
source ~/.config/nvim/_settings/cursor_settings.vim

" ===
" === 插件管理(使用vim-plug) 需要先安装vim-plug
" ===
call plug#begin('~/.config/nvim/plugged')


" Pretty Dress
Plug 'bling/vim-bufferline'
Plug 'bpietravalle/vim-bolt'
Plug 'theniceboy/vim-deus'

" trouble

" onedark 主题
Plug 'joshdick/onedark.vim'
Plug 'sainnhe/sonokai'
Plug 'morhetz/gruvbox'

" Status line
Plug 'theniceboy/eleline.vim'
Plug 'ojroques/vim-scrollstatus'

" General Highlighter
Plug 'RRethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'RRethy/vim-illuminate'

" File navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
Plug 'kevinhwang91/rnvimr'
Plug 'airblade/vim-rooter'
"Plug 'pechorin/any-jump.vim'

" Taglist
Plug 'liuchengxu/vista.vim'

" Debugger
"Plug 'puremourning/vimspector', {'do': './install_gadget.py --enable-python --enable-go --force-enable-rust --enable-bash'}

" Auto Complete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'wellle/tmux-complete.vim'

" Snippets
Plug 'theniceboy/vim-snippets'

" Undo Tree
Plug 'mbbill/undotree'

" Git
Plug 'theniceboy/vim-gitignore', { 'for': ['gitignore', 'vim-plug'] }
Plug 'fszymanski/fzf-gitignore', { 'do': ':UpdateRemotePlugins' }
Plug 'airblade/vim-gitgutter'
Plug 'cohama/agit.vim'

" Autoformat
Plug 'Chiel92/vim-autoformat'


" CSharp
Plug 'OmniSharp/omnisharp-vim'
Plug 'ctrlpvim/ctrlp.vim' , { 'for': ['cs', 'vim-plug'] } " omnisharp-vim dependency

" HTML, CSS, JavaScript, Typescript, PHP, JSON, etc.
Plug 'elzr/vim-json'
Plug 'neoclide/jsonc.vim'
Plug 'othree/html5.vim'
Plug 'alvan/vim-closetag'
" Plug 'hail2u/vim-css3-syntax' " , { 'for': ['vim-plug', 'php', 'html', 'javascript', 'css', 'less'] }
" Plug 'spf13/PIV', { 'for' :['php', 'vim-plug'] }
" Plug 'pangloss/vim-javascript', { 'for': ['vim-plug', 'php', 'html', 'javascript', 'css', 'less'] }
Plug 'yuezk/vim-js', { 'for': ['vim-plug', 'php', 'html', 'javascript', 'css', 'less'] }
" Plug 'MaxMEllon/vim-jsx-pretty', { 'for': ['vim-plug', 'php', 'html', 'javascript', 'css', 'less'] }
" Plug 'jelera/vim-javascript-syntax', { 'for': ['vim-plug', 'php', 'html', 'javascript', 'css', 'less'] }
"Plug 'jaxbot/browserlink.vim'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'posva/vim-vue'

" Go
Plug 'fatih/vim-go' , { 'for': ['go', 'vim-plug'], 'tag': '*' }

" Rust
" Plug 'rust-lang/rust.vim'

" Python
" Plug 'tmhedberg/SimpylFold', { 'for' :['python', 'vim-plug'] }
Plug 'Vimjas/vim-python-pep8-indent', { 'for' :['python', 'vim-plug'] }
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for' :['python', 'vim-plug'] }
"Plug 'vim-scripts/indentpython.vim', { 'for' :['python', 'vim-plug'] }
"Plug 'plytophogy/vim-virtualenv', { 'for' :['python', 'vim-plug'] }
Plug 'tweekmonster/braceless.vim', { 'for' :['python', 'vim-plug'] }

" Flutter
Plug 'dart-lang/dart-vim-plugin'
Plug 'f-person/pubspec-assist-nvim', { 'for' : ['pubspec.yaml'] }

" Swift
" Plug 'keith/swift.vim'
" Plug 'arzg/vim-swift'

" Markdown
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'dhruvasagar/vim-table-mode', { 'on': 'TableModeToggle', 'for': ['text', 'markdown', 'vim-plug'] }
Plug 'mzlogin/vim-markdown-toc', { 'for': ['gitignore', 'markdown', 'vim-plug'] }
Plug 'dkarter/bullets.vim'
Plug 'vimwiki/vimwiki'

" Other filetypes
" Plug 'jceb/vim-orgmode', {'for': ['vim-plug', 'org']}

" Editor Enhancement
Plug 'jiangmiao/auto-pairs'
Plug 'mg979/vim-visual-multi'
Plug 'tomtom/tcomment_vim' " in <space>cn to comment a line
Plug 'theniceboy/antovim' " gs to switch
Plug 'tpope/vim-surround' " type yskw' to wrap the word with '' or type cs'` to change 'word' to `word`
Plug 'gcmt/wildfire.vim' " in Visual mode, type k' to select all text in '', or type k) k] k} kp
Plug 'junegunn/vim-after-object' " da= to delete what's after =
Plug 'godlygeek/tabular' " ga, or :Tabularize <regex> to align
Plug 'tpope/vim-capslock'	" Ctrl+L (insert) to toggle capslock
Plug 'easymotion/vim-easymotion'
Plug 'svermeulen/vim-subversive'
Plug 'theniceboy/argtextobj.vim'
Plug 'rhysd/clever-f.vim'
Plug 'chrisbra/NrrwRgn'
Plug 'AndrewRadev/splitjoin.vim'

" Bookmarks
" Plug 'MattesGroeger/vim-bookmarks'

" Find & Replace
Plug 'brooth/far.vim', { 'on': ['F', 'Far', 'Fardo'] }

" Documentation
"Plug 'KabbAmine/zeavim.vim' " <LEADER>z to find doc

" Mini Vim-APP
Plug 'skywind3000/asynctasks.vim'
Plug 'skywind3000/asyncrun.vim'

" Vim Applications
Plug 'itchyny/calendar.vim'

" Other visual enhancement
Plug 'ryanoasis/vim-devicons'
Plug 'luochen1990/rainbow'
Plug 'mg979/vim-xtabline'
Plug 'wincent/terminus'

" Other useful utilities
Plug 'lambdalisue/suda.vim' " do stuff like :sudowrite
" Plug 'makerj/vim-pdf'
"Plug 'xolox/vim-session'
"Plug 'xolox/vim-misc' " vim-session dep

" Dependencies
" Plug 'MarcWeber/vim-addon-mw-utils'
" Plug 'kana/vim-textobj-user'
" Plug 'roxma/nvim-yarp'


call plug#end()


" === 后面都是插件加载之后才能做的事情

" ===
" === 加载主题配置
" ===
source ~/.config/nvim/_settings/03_colorscheme.vim

" ===
" === 加载plug 配置
" ===
source ~/.config/nvim/_after/plugin/colorscheme.vim
source ~/.config/nvim/_after/plugin/fzf_leaderf_vista.vim
source ~/.config/nvim/_after/plugin/coc.vim
source ~/.config/nvim/_after/plugin/gitgutter.vim
source ~/.config/nvim/_after/plugin/language.vim
source ~/.config/nvim/_after/plugin/other.vim

" Open the _machine_specific.vim file if it has just been created
if has_machine_specific_file == 0
	exec "e ~/.config/nvim/_machine_specific.vim"
endif


