# 用户级命令

本目录保存经过排查、希望在重装后恢复，并准备逐个链接到 `~/.local/bin` 的用户命令。

当前管理：

```text
desktop-profile
zoom-host
zoom-watch
```

## 管理原则

仓库目录：

```text
/home/terry/project/manjaro-workspace/.config/bin
```

用户命令目录：

```text
~/.local/bin
```

不要把整个 `~/.local/bin` 链接到本目录。该目录还可能包含 `uv`、`pipx` 或其他工具安装的命令。目前本机已有：

```text
~/.local/bin/specify
```

因此只链接由本仓库明确管理的文件：

```text
~/.local/bin/zoom-host
  -> /home/terry/project/manjaro-workspace/.config/bin/zoom-host

~/.local/bin/zoom-watch
  -> /home/terry/project/manjaro-workspace/.config/bin/zoom-watch

~/.local/bin/desktop-profile
  -> /home/terry/project/manjaro-workspace/.config/bin/desktop-profile
```

`~/.local/bin` 已经位于本机 `PATH`，无需添加 alias 或修改 `.zshrc`。

## `desktop-profile`

用于在 Niri 会话中管理两套 Desktop Shell：

```text
DMS     -> DMS 状态栏、启动器和通知
Classic -> Waybar gruvbox_2、Fuzzel 和 Mako
```

常用命令：

```bash
desktop-profile dms
desktop-profile classic
desktop-profile toggle
desktop-profile status
```

脚本使用软件包自带的 `dms.service` 管理 DMS，并通过 Niri 启动 Classic 组件；不会修改字体、字号或显示器配置。完整架构、安装方式和恢复流程见 `../niri/README.md`。

## 背景

Zoom 7.1.5 在当前 Wayland/NVIDIA 环境中没有一个同时满足所有场景的稳定后端：

| 模式 | 主界面操作 | 自己共享 | 观看别人共享 |
| --- | --- | --- | --- |
| 原生 Wayland | 正常 | 正常 | 黑屏 |
| XWayland | 可能无法点击 | 非主要用途 | 可以观看 |

当前实测范围：

- `zoom-host`：在 GNOME 和 Niri 中共用；Niri 下必须配合 `org.freedesktop.impl.portal.ScreenCast=wlr`，远端参会者已确认能看到共享画面；
- `zoom-watch`：在 Niri 下已确认可以观看其他参会者共享；GNOME 沿用此前的 XWayland 观看方案；
- 两个脚本自动同步 `xwayland=` 和 `QT_QPA_PLATFORM`，日常不需要手工编辑 `zoomus.conf`。

Niri 的 ScreenCast Portal 配置和 PipeWire 格式协商故障记录见 `../xdg-desktop-portal/README.md`。

Zoom 的最终 Qt 后端同时受两层设置控制：

1. 进程环境变量 `QT_QPA_PLATFORM`；
2. `~/.config/zoomus.conf` 中的 `xwayland=`。

只设置其中一项不可靠。ZoomLauncher 会读取 `xwayland=`，并可能覆盖启动进程继承的 Qt 平台设置。

完整调查记录见 `zoom-wayland-click-fix.md`。

## `zoom-host`

用于：

- 发起或主持会议；
- 正常操作 Zoom 主界面；
- 自己共享整个桌面。

执行：

```bash
zoom-host
```

它会：

1. 检查 `~/.config/zoomus.conf`；
2. 要求文件中恰好存在一条 `xwayland=`；
3. 如果 Zoom 正在运行，发送 `SIGTERM` 正常结束相关进程；
4. 最多等待约 5 秒；
5. 若进程没有退出，则停止操作且不修改配置；
6. 设置 `xwayland=false`；
7. 使用 `QT_QPA_PLATFORM=wayland` 启动 `/usr/bin/zoom`。

脚本不负责选择 Portal。桌面会话会自动完成：

```text
GNOME -> GNOME ScreenCast Portal
Niri  -> wlr ScreenCast Portal
```

Niri 下曾使用 GNOME ScreenCast Portal 时发生 `no more input formats`，表现为本地显示正在共享、远端却看不到画面。切换为 wlr ScreenCast Portal 后已实测恢复。

等价的核心设置是：

```ini
xwayland=false
```

```text
QT_QPA_PLATFORM=wayland
```

## `zoom-watch`

用于：

- 加入其他人主持的会议；
- 主要观看其他参会者共享的画面。

执行：

```bash
zoom-watch
```

它会执行相同的检查和正常退出流程，然后设置：

```ini
xwayland=true
```

并使用：

```text
QT_QPA_PLATFORM=xcb
```

启动 Zoom。

该模式的已知代价是 Zoom 主界面可能无法点击。

`zoom-watch` 用于接收和观看共享，不承诺能够从 XWayland 模式发起屏幕共享。需要自己共享时应先退出会议，再使用 `zoom-host` 重新启动。

## 重要警告

两个命令都会结束当前正在运行的 Zoom。

不要在尚未正常离开会议、录制或共享时切换模式。脚本只发送 `SIGTERM`，不会使用 `SIGKILL`；如果 Zoom 在约 5 秒内没有退出，脚本会报错并保持 `zoomus.conf` 不变。

## 会议链接参数

两个脚本会把所有参数原样传给 `/usr/bin/zoom`，因此支持：

```bash
zoom-watch 'zoommtg://...'
```

但是浏览器直接点击 `zoommtg://` 链接时，仍然由 `~/.local/share/applications/Zoom.desktop` 处理，不会自动调用这两个脚本。当前推荐先运行合适的脚本，再在 Zoom 中加入会议。

## `Zoom.desktop` 的关系

两个脚本直接执行 `/usr/bin/zoom`，不经过 Desktop 文件。

当前用户级 Desktop 仍位于：

```text
~/.local/share/applications/Zoom.desktop
```

它不是本目录方案的核心，也暂未纳入仓库。以后可以单独决定是否删除用户覆盖、恢复系统 Desktop，或创建两个分别调用脚本的图形入口。

## 为什么不跟踪 `zoomus.conf`

`~/.config/zoomus.conf` 是 Zoom 会主动修改的运行时配置，可能包含音视频设备、窗口状态和其他机器相关设置；而且 `xwayland=true/false` 都有各自用途，不存在唯一永久值。

因此：

- 不把整个文件复制进仓库；
- 不把它链接到仓库；
- 只由两个脚本修改现有的 `xwayland=`；
- 如果配置项缺失或重复，脚本拒绝继续，避免猜测文件结构。

## 软件依赖

需要安装 Zoom：

```bash
yay -S zoom
```

还依赖系统常见的 POSIX 工具：

```text
sh
grep
sed
pgrep
pkill
sleep
env
```

Arch/Manjaro 基础系统通常已经提供这些工具。

## 新系统部署

安装所需软件、克隆仓库并确认目标名称没有冲突后：

```bash
mkdir -p ~/.local/bin

ln -s \
  /home/terry/project/manjaro-workspace/.config/bin/zoom-host \
  ~/.local/bin/zoom-host

ln -s \
  /home/terry/project/manjaro-workspace/.config/bin/zoom-watch \
  ~/.local/bin/zoom-watch

ln -s \
  /home/terry/project/manjaro-workspace/.config/bin/desktop-profile \
  ~/.local/bin/desktop-profile
```

脚本目标必须具有可执行权限：

```bash
chmod +x \
  /home/terry/project/manjaro-workspace/.config/bin/desktop-profile \
  /home/terry/project/manjaro-workspace/.config/bin/zoom-host \
  /home/terry/project/manjaro-workspace/.config/bin/zoom-watch
```

## 验证

检查命令解析：

```bash
command -v zoom-host
command -v zoom-watch
command -v desktop-profile
```

预期：

```text
/home/terry/.local/bin/zoom-host
/home/terry/.local/bin/zoom-watch
/home/terry/.local/bin/desktop-profile
```

检查链接：

```bash
readlink -f ~/.local/bin/zoom-host
readlink -f ~/.local/bin/zoom-watch
readlink -f ~/.local/bin/desktop-profile
```

Shell 语法检查：

```bash
sh -n ~/.local/bin/zoom-host
sh -n ~/.local/bin/zoom-watch
sh -n ~/.local/bin/desktop-profile
```

运行某个模式后检查配置：

```bash
grep '^xwayland=' ~/.config/zoomus.conf
```

检查 Zoom 主进程实际 Qt 后端：

```bash
for pid in $(pgrep -x zoom); do
  printf 'PID=%s\n' "$pid"
  tr '\0' '\n' < "/proc/$pid/environ" |
    grep '^QT_QPA_PLATFORM='
done
```

## 回退

删除两个符号链接即可停用命令，不会删除仓库脚本或 `zoomus.conf`：

```bash
rm ~/.local/bin/zoom-host
rm ~/.local/bin/zoom-watch
```

然后按需要手工设置 `xwayland=` 并直接运行 `/usr/bin/zoom`。

## 后续维护

Zoom 升级后，应重新测试：

1. 原生 Wayland 下主界面；
2. 原生 Wayland 下发起共享；
3. 原生 Wayland 下观看共享；
4. XWayland 下以上三项。

如果新版 Zoom 在原生 Wayland 下全部恢复正常，应停止使用 `zoom-watch`，将 `xwayland=false` 作为默认值，并考虑删除这套临时双模式脚本。
