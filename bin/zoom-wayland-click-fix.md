# Zoom 在 GNOME Wayland 下窗口无法点击：排查与修复

## 问题现象

- 桌面环境：GNOME Wayland。
- Zoom 窗口能够正常显示，但鼠标点击没有反应。
- 问题曾跨多个 Zoom 版本出现，因此不能简单归因于某一个版本。

## 现场环境

- Zoom 安装来源：AUR `zoom` 包，由 `yay` 构建并通过 `pacman -U` 安装。
- 排查时版本：Zoom Workplace 7.1.0 (3715)。
- 显卡：NVIDIA GeForce RTX 4070 SUPER。
- Zoom 默认启动日志：

  ```text
  XDG_SESSION_TYPE = wayland
  platformName: xcb
  isNativeWayland: 0
  ```

这表示桌面会话是 Wayland，但 Zoom 默认使用 Qt XCB 后端，通过 XWayland 显示窗口。

## 排查过程

### 1. 检查官方 Wayland 支持

Zoom 官方支持在 Linux Wayland 会话中运行及共享整个桌面，但部分功能有限制，例如仅共享单个应用窗口和部分批注场景。整桌共享符合本机需求。

### 2. 检查崩溃记录

曾观察到 `ZoomWebviewHost` 因栈保护触发而退出：

```text
*** stack smashing detected ***: terminated
__stack_chk_fail
SIGABRT
```

该崩溃是一个真实但独立的 Zoom CEF/WebView 问题，不能解释每一次“窗口显示但不能点击”。

### 3. 排除旧配置和缓存

停止 Zoom 后，临时隔离以下路径，并用全新配置启动同一个 7.1.0：

```text
~/.zoom
~/.config/zoom
~/.config/zoomus.conf
~/.cache/zoom
```

干净配置下窗口仍然无法点击，因此旧配置、账户状态和缓存不是本次点击故障的主要原因。

### 4. 检查 XWayland 窗口

默认模式下，Zoom 主窗口具有以下特征：

```text
WM_CLASS = "zoom", "zoom"
_NET_WM_WINDOW_TYPE = _KDE_NET_WM_WINDOW_TYPE_OVERRIDE, _NET_WM_WINDOW_TYPE_NORMAL
Client accepts input or input focus: True
```

窗口声明接受输入，但 GNOME/Mutter 没有把它识别为活动 XWayland 窗口。结合干净配置仍复现，问题范围缩小到 Zoom Qt 窗口与 GNOME/Mutter 的 XWayland 输入/焦点交互。

### 5. 原生 Wayland 对照测试

使用以下环境变量启动相同版本：

```sh
QT_QPA_PLATFORM=wayland /usr/bin/zoom
```

结果：窗口恢复正常点击。

### 6. 恢复旧配置后的二次验证

恢复原来的 `~/.config/zoomus.conf` 后，从 GNOME Dock 启动 Zoom，窗口再次无法点击。进程环境证明 Dock 和用户级 desktop 文件并没有失效：

```text
/usr/bin/zoom（ZoomLauncher）：
QT_QPA_PLATFORM=wayland

/opt/zoom/zoom（实际主程序）：
QT_QPA_PLATFORM=xcb
```

原因是恢复后的 Zoom 配置包含：

```ini
xwayland=true
```

ZoomLauncher 读取该项后，将用户级 desktop 文件传入的 `QT_QPA_PLATFORM=wayland` 覆盖为 `QT_QPA_PLATFORM=xcb`。因此，仅修改 desktop 文件不足以保证原生 Wayland；还必须将该配置改为 `false`。

## 结论

本次问题不是“Zoom 完全不支持 Wayland”，也不是旧配置或缓存导致。有效的规避方式是让 Zoom 的 Qt 主界面使用原生 Wayland，绕过出现问题的 XWayland 窗口输入路径。

Zoom 内嵌的 CEF/WebView 子进程可能仍显示 X11/Ozone X11 参数，这是 Zoom 自身的混合架构，不影响本次主窗口修复结论。

## 永久修复

系统启动项位于：

```text
/usr/share/applications/Zoom.desktop
```

不要直接修改该文件，因为 Zoom 包升级可能覆盖它。将其复制为同名用户级启动项：

```text
~/.local/share/applications/Zoom.desktop
```

仅将：

```ini
Exec=/usr/bin/zoom %U
```

修改为：

```ini
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/zoom %U
```

同名 desktop 文件存在时，GNOME 优先采用用户级文件。该设置只影响 Zoom，不应写入 `.zshrc`，以免影响其他 Qt 程序。

然后编辑：

```text
~/.config/zoomus.conf
```

将：

```ini
xwayland=true
```

修改为：

```ini
xwayland=false
```

这一步不可省略。`xwayland=true` 会让 ZoomLauncher 把 desktop 文件设置的 `QT_QPA_PLATFORM=wayland` 覆盖成 `QT_QPA_PLATFORM=xcb`。

## 验证方法

1. 确认所有 Zoom 进程已经退出。
2. 从 GNOME 应用菜单点击 Zoom Workplace。
3. 确认窗口可以点击、登录和进入会议。
4. 检查两个 Zoom 进程的环境：

   ```sh
   launcher_pid=$(pgrep -o -x zoom)
   main_pid=$(pgrep -n -x zoom)
   tr '\0' '\n' < "/proc/$launcher_pid/environ" | grep '^QT_QPA_PLATFORM='
   tr '\0' '\n' < "/proc/$main_pid/environ" | grep '^QT_QPA_PLATFORM='
   ```

5. 正确结果应当是 ZoomLauncher 和实际主程序均为：

   ```text
   QT_QPA_PLATFORM=wayland
   ```

6. 也可检查 Zoom 日志中的 `platformName` 与 `isNativeWayland`。不能只检查 desktop 文件，因为 ZoomLauncher 可能根据 `zoomus.conf` 再次覆盖后端。

## 回退方法

如果原生 Wayland 启动产生新问题，需要同时把 `~/.config/zoomus.conf` 恢复为：

```ini
xwayland=true
```

并删除用户级覆盖文件：

```sh
rm ~/.local/share/applications/Zoom.desktop
```

随后重新从应用菜单启动 Zoom。

## 升级后的注意事项

- `yay`/`pacman` 升级 Zoom 不会覆盖用户级 `Zoom.desktop`。
- 如果未来 Zoom 默认原生支持 Wayland且不再复现，可以删除用户级覆盖文件。
- 如果升级后图标、会议链接或启动行为异常，应比较用户级文件和新版 `/usr/share/applications/Zoom.desktop`，同步官方新增字段，同时保留修改后的 `Exec=`。

## 后续排查：接收共享黑屏

升级到 Zoom `7.1.5-1`（客户端内部版本 `7.1.5 (4332)`）后，原生
Wayland 下主界面可以正常点击，自己共享整个桌面时其他参会者也能看到，
但观看其他参会者的共享时画面仍然为黑色。

已经完成以下排除测试：

- 隔离 `~/.cache/zoom` 和 `~/.zoom/data/cefcache`，让 Zoom 重新生成缓存；
- 单独隔离 Qt `qtpipelinecache`，排除旧版本图形管线缓存；
- 从 Zoom `7.1.0-1` 升级到 `7.1.5-1`；
- 在 Zoom 的“共享屏幕 → 高级”中启用“使用 TCP 连接进行屏幕共享”；
- 临时测试 `LIBGL_ALWAYS_SOFTWARE=1`，但 Zoom 仍实际使用 NVIDIA；
- 临时测试 `QT_QUICK_BACKEND=software`，该模式下 Zoom 主界面无法正常显示，
  因此不是可用方案。

原生 Wayland 现场日志显示：

```text
platformName: wayland isNativeWayland: 1
OpenGL VENDOR: NVIDIA Corporation
RENDERER: NVIDIA GeForce RTX 4070 SUPER
VERSION: OpenGL ES 3.2 NVIDIA 610.43.03
```

日志能够证明 Zoom 创建了 Qt/QRhi 图形上下文和 `ShareItem`，但 Zoom 的普通
日志不记录接收共享帧的数量、解码结果或最终像素内容。因此，“日志没有报错”
不能证明共享画面已经正常渲染。

当前可稳定复现的行为是：

| Zoom 后端 | 主界面点击 | 自己发起共享 | 观看别人共享 |
| --- | --- | --- | --- |
| 原生 Wayland | 正常 | 正常（整个桌面） | 黑屏 |
| XWayland（GNOME 会话仍为 Wayland） | 可能无法点击 | 不作为主要用途 | 此前测试可以显示 |

这里的 XWayland 模式只影响 Zoom 进程，不代表把 GNOME 会话切换为 Xorg。
不采用完整 Xorg 会话作为解决方案。

## 当前实用方案：按会议用途切换 Zoom 后端

该方案现已封装为两个仓库管理的用户命令：

```sh
zoom-host
zoom-watch
```

它们逐个链接到 `~/.local/bin`，会检查配置、正常结束已有 Zoom、等待进程退出、同步修改 `xwayland=` 和 `QT_QPA_PLATFORM`，然后启动 Zoom。日常应优先使用这两个命令；下面保留原始命令用于解释实现和应急排查。

详细部署、验证和回退说明见同目录的 `README.md`。

以下命令会先结束现有 Zoom 进程。切换前应当先正常离开正在进行的会议。

### 发起会议并共享：原生 Wayland

推荐命令：

```sh
zoom-host
```

等价的原始操作：

```sh
pkill -TERM -x zoom; pkill -TERM -x ZoomWebviewHost
```

```sh
sed -i 's/^xwayland=.*/xwayland=false/' ~/.config/zoomus.conf; QT_QPA_PLATFORM=wayland /usr/bin/zoom
```

该模式用于需要正常操作 Zoom 主界面或共享整个桌面的场景。

### 加入会议并观看别人共享：XWayland

推荐命令：

```sh
zoom-watch
```

等价的原始操作：

```sh
pkill -TERM -x zoom; pkill -TERM -x ZoomWebviewHost
```

```sh
sed -i 's/^xwayland=.*/xwayland=true/' ~/.config/zoomus.conf; QT_QPA_PLATFORM=xcb /usr/bin/zoom
```

该模式用于主要观看其他参会者共享的场景。GNOME 本身仍运行在 Wayland
会话中；只有 Zoom 使用 XWayland。已知代价是 Zoom 主界面可能出现无法点击，
但此前测试中会议窗口和接收共享可以正常显示。

不能只设置 `QT_QPA_PLATFORM` 而忽略 `xwayland=`：ZoomLauncher 会读取
`zoomus.conf`，并可能覆盖命令行继承的 Qt 平台选择。

## Niri 下发起共享：ScreenCast Portal 修复

上述原生 Wayland 共享最初在 GNOME 下验证成功。切换到 Niri 26.04 后，执行 `zoom-host` 可以正常选择显示器并进入“正在共享”状态，但远端参会者看不到画面。

日志证明问题不在脚本的后端切换：Zoom 实际为：

```text
platformName: wayland
isNativeWayland: 1
```

失败发生在 Niri 的 GNOME/Mutter ScreenCast 兼容接口与 Zoom 之间的 PipeWire 格式协商：

```text
record_monitor connector="DP-2"
Unconnected -> Connecting -> Paused
Paused -> Error("no more input formats")
pw.link ... negotiating -> error no more input formats
```

曾临时测试 Niri 官方调试选项：

```kdl
debug {
    force-pipewire-invalid-modifier
}
```

它改变了 PipeWire modifier 提议，但仍然出现 `no more input formats`，因此已经撤销，没有保留在 Niri 配置中。

最终在 Niri 专用 Portal 配置中将：

```ini
org.freedesktop.impl.portal.ScreenCast=gnome;
```

修改为：

```ini
org.freedesktop.impl.portal.ScreenCast=wlr;
```

当前文件：

```text
~/.config/xdg-desktop-portal/niri-portals.conf
```

最终屏幕相关配置：

```ini
org.freedesktop.impl.portal.ScreenCast=wlr;
org.freedesktop.impl.portal.Screenshot=wlr;
```

重启 `xdg-desktop-portal` 后重新执行 `zoom-host`，远端参会者已确认可以看到共享画面。调用链变为：

```text
Zoom
-> xdg-desktop-portal
-> xdg-desktop-portal-wlr
-> Niri wlr-screencopy
-> PipeWire
-> Zoom 发送共享画面
```

`niri-portals.conf` 只在 `XDG_CURRENT_DESKTOP=niri` 时读取，所以 GNOME 仍使用 GNOME Portal。两个脚本本身不需要按桌面分叉，可以在 GNOME 和 Niri 下共用。

该配置会让 Niri 下其他 ScreenCast Portal 客户端也使用 wlr 后端，可能失去 GNOME Portal 提供的窗口选择或 Niri 动态 Cast Target 等高级能力。当前优先保证 Zoom 共享可用；升级 Niri、Zoom 或 Portal 后应重新测试。

## 临时缓存处理结论

排查期间隔离的 `~/.cache/zoom`、CEF 缓存和 Qt pipeline 缓存均已由 Zoom
重新生成。使用新缓存后问题仍然复现，因此旧缓存不应恢复，可以在确认上述
双模式方案满足使用需求后直接删除。`zoomus.conf` 的旧快照也不应覆盖当前
文件；后端切换应使用上一节的 `xwayland=true/false`。
