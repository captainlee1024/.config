## 如何使用

当前系统已经安装 tmux：

```bash
tmux -V
```

tmux 没有配置文件时也可以直接使用默认配置。

启动一个 tmux 会话：

```bash
tmux
```

启动并命名会话：

```bash
tmux new -s dev
```

退出当前 tmux 会话，但保留后台运行：

```text
Ctrl-b d
```

查看所有会话：

```bash
tmux ls
```

重新进入默认会话：

```bash
tmux attach
```

重新进入指定会话：

```bash
tmux attach -t dev
```

关闭当前 shell 后，如果该会话里没有其他 pane 或窗口，tmux 会话也会结束：

```bash
exit
```

## 常用快捷键

tmux 默认前缀键是 `Ctrl-b`。先按 `Ctrl-b`，松开后再按后面的键。

```text
Ctrl-b c       新建窗口
Ctrl-b n       下一个窗口
Ctrl-b p       上一个窗口
Ctrl-b ,       重命名当前窗口
Ctrl-b %       左右分屏
Ctrl-b "       上下分屏
Ctrl-b 方向键  切换 pane
Ctrl-b {       当前 pane 和上一个 pane 互换位置
Ctrl-b }       当前 pane 和下一个 pane 互换位置
Ctrl-b x       关闭当前 pane
Ctrl-b d       detach，退出但保留会话
Ctrl-b [       进入复制/滚动模式
q              退出复制/滚动模式
```

## 后续配置

如果以后需要把 tmux 配置纳入这个仓库管理，可以在本目录创建：

```text
tmux.conf
```

然后备份并移除电脑现有的 tmux 配置目录：

```bash
mv ~/.config/tmux ~/.config/tmux_bak
```

在仓库 `.config` 目录下建立软链接：

```bash
ln -s "$(pwd)/tmux" ~/.config/tmux
```
