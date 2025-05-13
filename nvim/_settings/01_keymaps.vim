" ===
" === Basic Mappings
" === 基本快捷键映射
" ===
" Set <LEADER> as <SPACE>, ; as :
let mapleader=" "
noremap ; :

" Save & quit
" === 保存与退出
noremap Q :q<CR>
noremap <C-q> :qa<CR>
noremap S :w<CR>
noremap <c-b> :source $MYVIMRC<CR>


" Open the vimrc file anytime
noremap <LEADER>rc :e ~/.config/nvim/init.vim<CR>

" make Y to copy till the end of the line
" === 使用Y复制到行尾
nnoremap Y y$

" Copy to system clipboard
vnoremap Y "+y

" Indentation
" === 缩进快捷键(normal模式下)
nnoremap < <<
nnoremap > >>

" Search
" === 搜索， Leader+回车清除搜索高量
noremap <LEADER><CR> :nohlsearch<CR>

" Adjacent duplicate words
noremap <LEADER>dw /\(\<\w\+\>\)\_s*\1

" Space to Tab
nnoremap <LEADER>tt :%s/    /\t/g
vnoremap <LEADER>tt :s/    /\t/g

" Folding
" === 代码折叠 使用 Leader+o 快速进行代码折叠和打开
noremap <silent> <LEADER>o za

" Open up lazygit
" === 打开 lazygit
noremap \g :Git
" === Ctrl+g 在一个新的标签页打开lazygit
noremap <c-g> :tabe<CR>:-tabmove<CR>:term lazygit<CR>
" nnoremap <c-n> :tabe<CR>:-tabmove<CR>:term lazynpm<CR>


" ===
" === Cursor Movement
" ===

" K/J keys for 5 times u/e (faster navigation)
" === 快速移动
noremap <silent> K 5k
noremap <silent> J 5j

" N key: go to the start of the line
"noremap <silent> N 0
" I key: go to the end of the line
"noremap <silent> I $

" Faster in-line navigation
"noremap W 5w
"noremap B 5b

" Ctrl + U or E will move up/down the view port without moving the cursor
" === Ctrl + K/J 上下滚动视图但不移动光标
noremap <C-K> 5<C-y>
noremap <C-J> 5<C-e>


" source $XDG_CONFIG_HOME/nvim/cursor.vim
"source ~/.config/nvim/cursor.vim
" ===
" === 加载光标配置
" ===
"source ~/.config/nvim/_settings/cursor_settings.vim



" ===
" === Insert Mode Cursor Movement
" === 插入模式的光标移动
" ===
inoremap <C-a> <ESC>A


" ===
" === Command Mode Cursor Movement
" === 命令模式的光标移动，模仿命令行中的光标移动
" ===
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-w> <S-Right>


" ===
" === Window management
" === 窗口管理
" ===
" Use <space> + new arrow keys for moving the cursor around windows
noremap <LEADER>w <C-w>w
noremap <LEADER>k <C-w>k
noremap <LEADER>j <C-w>j
noremap <LEADER>h <C-w>h
noremap <LEADER>l <C-w>l

" Disable the default s key
" === 禁用s键的默认行为
noremap s <nop>

" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
" === 分割窗口的快捷键
noremap sk :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
noremap sj :set splitbelow<CR>:split<CR>
noremap sh :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
noremap sl :set splitright<CR>:vsplit<CR>

" Resize splits with arrow keys
" === 使用方向键条这个窗口大小
noremap <up> :res +5<CR>
noremap <down> :res -5<CR>
noremap <left> :vertical resize-5<CR>
noremap <right> :vertical resize+5<CR>

" === " 将两个窗口上下排列 / 左右排列
" Place the two screens up and down
noremap su <C-w>t<C-w>K
" Place the two screens side by side
noremap sv <C-w>t<C-w>H

" Rotate screens
" === 旋转屏幕 (实际是移动窗口到另一个根分割区)
noremap sru <C-w>b<C-w>K
noremap srv <C-w>b<C-w>H

" === Leader+q 关闭当前活动窗口下方的窗口 (有点特殊)
" === 在终端里使用Ctrl+N 进入normal之后使用该快捷键可以关闭终端
" === 终端下方没有其他窗口时，它会关闭当前(窗口)终端
" Press <SPACE> + q to close the window below the current window
noremap <LEADER>q <C-w>j:q<CR>


" ===
" === Tab management
" === 标签页管理
" ===
" Create a new tab with tu
noremap tu :tabe<CR>
" Move around tabs with tn and ti
noremap tj :-tabnext<CR>
noremap tk :+tabnext<CR>
" Move the tabs with tmn and tmi
noremap tmj :-tabmove<CR>
noremap tmk :+tabmove<CR>
" 保存buffer
" === 在新标签页中打开当前文件 (复制当前缓冲区到新标签页)
noremap tn :tab split<CR>

" ===
" === 其他有用的未分类配置
" ===
" Open a new instance of st with the cwd, 暂时使用alacritty终端，先注释掉
" nnoremap \t :tabe<CR>:-tabmove<CR>:term sh -c 'st'<CR><C-\><C-N>:q<CR>

" Move the next character to the end of the line with ctrl+9
inoremap <C-u> <ESC>lx$p

" Opening a terminal window
noremap <LEADER>/ :set splitbelow<CR>:split<CR>:res +10<CR>:term<CR>

" Press space twice to jump to the next '' and edit it
noremap <LEADER><LEADER> <Esc>/<++><CR>:nohlsearch<CR>c4l

" Spelling Check with <space>sc
noremap <LEADER>sc :set spell!<CR>

" Press ` to change case (instead of ~)
noremap ` ~

noremap <C-c> zz

" Auto change directory to current dir 在autocmds里配置
" autocmd BufEnter * silent! lcd %:p:h

" Call figlet
" === 调用 figlet 生成艺术字，执行快捷键之后输入想要生成的字符
"                                 _      
"   _____  ____ _ _ __ ___  _ __ | | ___ 
"  / _ \ \/ / _` | '_ ` _ \| '_ \| |/ _ \
" |  __/>  < (_| | | | | | | |_) | |  __/
"  \___/_/\_\__,_|_| |_| |_| .__/|_|\___|
"                          |_|           
noremap tx :r !figlet

" find and replace
noremap \s :%s//g<left><left>

" set wrap
" === 用来切换自动换行
noremap <LEADER>sw :set wrap<CR>

" press f10 to show hlgroup
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . sy
