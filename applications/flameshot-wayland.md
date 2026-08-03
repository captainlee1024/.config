# Flameshot 在 GNOME Wayland 三显示器环境下的配置与排障记录

## 1. 背景与问题现象

当前环境：

- 桌面环境：GNOME
- 显示协议：Wayland
- 显示器数量：3 台
- Flameshot：14.0.0
- Qt：6.11.1
- 系统已安装 `xdg-desktop-portal` 和 `xdg-desktop-portal-gnome`

最初直接启动 Flameshot 后进行截图，出现多显示器画面或截图区域错位。

执行下面的测试后，截图恢复正常：

```bash
pkill flameshot
QT_QPA_PLATFORM=wayland flameshot
```

然后在另一个终端执行：

```bash
QT_QPA_PLATFORM=wayland flameshot gui
```

Flameshot 正常显示 3 个显示器供选择。选择其中一个显示器后，可以框选、编辑、复制，并成功粘贴发送。

终端出现以下日志属于正常现象：

```text
qt.qpa.wayland.textinput: ... Got leave event ...
flameshot: info: GNOME Wayland detected; keeping capture window alive until clipboard data is fetched.
flameshot: info: 捕获已保存至剪贴板。
```

其中 `keeping capture window alive until clipboard data is fetched` 是 Flameshot 为适配 GNOME Wayland 剪贴板而采取的正常行为。

## 2. 原因判断

问题不是 Flameshot 完全不支持 Wayland，也不是缺少 GNOME Portal。

Flameshot 14 已支持通过 Wayland 和 `xdg-desktop-portal` 截图，并针对多显示器和混合缩放重新设计了截图流程：先选择一台显示器，再在该显示器中截图。

本机原来的启动方式没有明确指定 Qt 使用 Wayland。Flameshot 可能通过 XWayland 启动，而实际画面由 Wayland Portal 提供。在三显示器、不同分辨率、不同缩放率或存在特殊显示器坐标时，XWayland 与 Wayland 的坐标换算可能导致错位。

强制指定：

```bash
QT_QPA_PLATFORM=wayland
```

之后问题消失，因此当前解决方向是：仅让 Flameshot 使用原生 Wayland，不给所有 Qt 软件设置全局环境变量。

## 3. 可选使用方式

### 3.1 终端直接进入截图界面

不需要预先启动 Flameshot 后台进程，直接执行：

```bash
QT_QPA_PLATFORM=wayland flameshot gui
```

流程：

```text
执行命令
→ 选择 3 台显示器中的一台
→ 框选截图区域
→ 标注、保存或复制
```

这是命令行截图最直接的方式。

### 3.2 终端打开 Flameshot Launcher

执行：

```bash
QT_QPA_PLATFORM=wayland flameshot launcher
```

流程：

```text
执行命令
→ 打开 Flameshot 功能选择器
→ 选择截图模式或相关选项
→ 进入显示器选择和截图流程
```

`launcher` 比 `gui` 多一层功能选择界面，适合需要选择不同截图模式、延迟时间或保存选项时使用。

### 3.3 终端启动后台进程

执行：

```bash
QT_QPA_PLATFORM=wayland flameshot
```

该命令主要用于启动 Flameshot 后台进程和托盘图标，并不会直接进入截图。

当前 GNOME 没有启用 AppIndicator/KStatusNotifierItem 托盘扩展。直接启动后台模式时，日志出现：

```text
QDBusTrayIcon encountered a D-Bus error:
org.freedesktop.DBus.Error.ServiceUnknown
The name is not activatable
```

由于 GNOME 默认不提供 Flameshot 使用的传统托盘服务，托盘图标无法显示，进程也没有正常留在后台。因此当前不采用后台常驻方式，也不为此额外安装 GNOME 托盘扩展。

## 4. 当前采用的方案：用户级 `.desktop` 覆盖

目标是满足以下条件：

- 直接从 GNOME 应用列表点击 Flameshot；
- 点击后直接开始截图；
- 强制 Flameshot 使用原生 Wayland；
- 不设置 GNOME 自定义快捷键；
- 不配置 shell alias；
- 不开机自动启动；
- 不安装额外的 GNOME 托盘扩展；
- 不给所有 Qt 程序设置全局 `QT_QPA_PLATFORM`；
- 不修改由系统软件包管理的原始文件。

### 4.1 系统原始启动文件

Flameshot 软件包安装的启动文件位于：

```text
/usr/share/applications/org.flameshot.Flameshot.desktop
```

该文件由系统软件包管理。升级或重新安装 Flameshot 时，它可能被更新，因此不直接修改它。

### 4.2 用户级启动文件

把系统启动文件完整复制到：

```text
~/.local/share/applications/org.flameshot.Flameshot.desktop
```

完整路径为：

```text
/home/terry/.local/share/applications/org.flameshot.Flameshot.desktop
```

系统文件与用户文件使用相同文件名。桌面环境会优先使用用户目录中的版本，因此可以安全覆盖启动行为，而系统原文件仍由软件包正常升级。

这个做法与本机 Zoom 的用户级 Wayland 启动项思路相同。

### 4.3 当前具体修改

系统文件中的主入口原来是：

```ini
Exec=/usr/bin/flameshot
```

用户文件中修改为：

```ini
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot gui
```

因此从 GNOME 应用列表点击 Flameshot 后，不启动托盘后台，而是直接进入原生 Wayland 截图流程。

桌面文件中的三个右键动作也全部明确指定 Wayland。

“配置”原来是：

```ini
Exec=flameshot config
```

修改为：

```ini
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot config
```

“进行截图”原来是：

```ini
Exec=flameshot gui
```

修改为：

```ini
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot gui
```

“打开启动器”原来是：

```ini
Exec=flameshot launcher
```

修改为：

```ini
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot launcher
```

当前用户级文件中所有相关启动命令为：

```ini
# GNOME 应用列表主入口：点击后直接截图
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot gui

# Desktop Action: Configure
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot config

# Desktop Action: Capture
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot gui

# Desktop Action: Launcher
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot launcher
```

## 5. 当前日常使用方法

### 从 GNOME 应用列表使用

点击“Flameshot/火焰截图”：

```text
点击应用图标
→ 选择 3 台显示器中的一台
→ 框选截图区域
→ 编辑、复制或保存
```

### 从终端直接截图

```bash
QT_QPA_PLATFORM=wayland flameshot gui
```

### 从终端打开功能选择器

```bash
QT_QPA_PLATFORM=wayland flameshot launcher
```

不要求先运行 `flameshot` 后台进程。

## 6. Flameshot 升级后的检查方法

用户级 `.desktop` 文件不会被 Flameshot 软件包升级覆盖。这保证了当前修复能够保留，但也意味着上游以后新增的桌面动作或参数不会自动同步到用户副本。

升级 Flameshot 后，可以比较系统新版与用户副本：

```bash
diff -u \
  /usr/share/applications/org.flameshot.Flameshot.desktop \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop
```

正常情况下，至少会看到本文记录的 4 条 `Exec=` 差异。

如果除了 `Exec=` 之外还有上游新增或修改的内容，可以：

1. 备份当前用户文件；
2. 重新从 `/usr/share/applications/` 复制最新版；
3. 再重新应用本文记录的 4 条 `Exec=` 修改；
4. 使用 `desktop-file-validate` 校验。

校验命令：

```bash
desktop-file-validate \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop
```

命令没有输出通常表示校验通过。

## 7. 恢复系统默认启动方式

如果以后 Flameshot 已能在当前环境中自动选择正确的 Wayland 后端，或者用户级覆盖出现问题，可以先把用户文件改名备份：

```bash
mv \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop.backup
```

之后 GNOME 会重新使用：

```text
/usr/share/applications/org.flameshot.Flameshot.desktop
```

如应用列表没有立即刷新，可以注销并重新登录 GNOME。

恢复当前覆盖时，把备份文件改回原文件名即可。

## 8. 再次出现错位时的排查顺序

### 8.1 结束可能残留的旧进程

```bash
pkill flameshot
```

然后直接测试原生 Wayland：

```bash
QT_QPA_PLATFORM=wayland flameshot gui
```

如果终端方式正常而应用图标异常，优先检查用户级 `.desktop` 是否仍然存在、内容是否正确。

### 8.2 确认版本和桌面会话

```bash
flameshot --version
```

```bash
env | grep -E \
  '^(XDG_SESSION_TYPE|XDG_CURRENT_DESKTOP|WAYLAND_DISPLAY|DISPLAY)='
```

预期应包含：

```text
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=GNOME
WAYLAND_DISPLAY=wayland-0
```

### 8.3 检查用户级启动项

```bash
grep '^Exec=' \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop
```

每条相关命令都应该包含：

```text
env QT_QPA_PLATFORM=wayland /usr/bin/flameshot
```

### 8.4 检查进程实际环境

如果 Flameshot 正在运行：

```bash
for pid in $(pgrep -x flameshot); do
  echo "PID=$pid"
  tr '\0' '\n' < "/proc/$pid/environ" |
    grep -E '^(QT_QPA_PLATFORM|XDG_SESSION_TYPE|WAYLAND_DISPLAY|DISPLAY)='
done
```

预期应包含：

```text
QT_QPA_PLATFORM=wayland
```

### 8.5 检查 Portal 软件包

```bash
pacman -Q \
  flameshot \
  qt6-wayland \
  xdg-desktop-portal \
  xdg-desktop-portal-gnome
```

GNOME Wayland 截图依赖 `xdg-desktop-portal` 和 GNOME Portal 后端。

### 8.6 查看日志

```bash
journalctl --user -b \
  -u xdg-desktop-portal \
  -u xdg-desktop-portal-gnome \
  --no-pager
```

运行 Flameshot 并保留 Qt 日志：

```bash
QT_QPA_PLATFORM=wayland \
QT_LOGGING_RULES="qt.qpa.*=true" \
flameshot gui 2>&1 | tee /tmp/flameshot-wayland.log
```

### 8.7 对照显示器布局和缩放

如果原生 Wayland 下再次出现错位，应记录：

- 每台显示器的物理分辨率；
- 每台显示器的缩放比例；
- 哪台是主显示器；
- 三台显示器的相对排列；
- 是否存在负 X/Y 坐标；
- 三台显示器顶部是否对齐；
- 错位的是截图内容、暗色遮罩还是鼠标选区坐标。

可以暂时把三台显示器调整为相同缩放比例并让顶部对齐，作为对照实验。如果问题消失，通常说明仍然存在混合 DPI 或虚拟桌面坐标转换问题。

## 9. 当前明确没有采用的配置

为了减少隐含配置和后续排障成本，当前没有采用：

- zsh alias；
- GNOME 自定义截图快捷键；
- Flameshot 开机自动启动；
- 全局 `QT_QPA_PLATFORM=wayland`；
- `QT_SCREEN_SCALE_FACTORS` 旧版缩放 workaround；
- GNOME AppIndicator 托盘扩展；
- 直接修改 `/usr/share/applications/` 中的软件包文件。

当前只保留一项针对 Flameshot 的显式配置：

```text
~/.local/share/applications/org.flameshot.Flameshot.desktop
```

这样影响范围最小，出现问题时也容易定位和恢复。

## 10. Niri Wayland 三显示器补充

### 10.1 现象

同一套 Flameshot 14.0.0 和 `QT_QPA_PLATFORM=wayland` 在 GNOME Wayland 下正常，但切换到 Niri Wayland 后无法截图。

这不表示 `QT_QPA_PLATFORM=wayland` 失效。该变量只决定 Flameshot 的 Qt 界面使用原生 Wayland；实际读取屏幕仍要通过 Wayland 截图协议或 Portal。

### 10.2 精确错误

Niri 和 GNOME Portal 日志显示：

```text
niri: error taking a screenshot:
Condition failed: outputs.len() == 1 (3 vs 1)

xdg-desktop-portal-gnome:
Failed to get screenshot:
GDBus.Error:org.freedesktop.DBus.Error.Failed: internal error
```

Flameshot v14 先通过 Screenshot Portal 获取画面，再进入显示器选择。Niri 当时的 GNOME Screenshot Portal 路径只接受一个输出，而本机连接了三个输出，所以请求在 Flameshot 编辑界面出现前失败。

### 10.3 最终方案

没有修改共享的 `flameshot.ini`，也没有启用旧版 `useGrimAdapter`。本机 Flameshot 14.0.0 已不识别以下旧配置：

```ini
useGrimAdapter=true
disabledGrimWarning=true
```

最终创建 Niri 专用 Portal 配置：

```text
~/.config/xdg-desktop-portal/niri-portals.conf
```

其中指定：

```ini
[preferred]
default=gnome;gtk;
org.freedesktop.impl.portal.Access=gtk;
org.freedesktop.impl.portal.Notification=gtk;
org.freedesktop.impl.portal.Secret=gnome-keyring;
org.freedesktop.impl.portal.ScreenCast=gnome;
org.freedesktop.impl.portal.Screenshot=wlr;
```

结果：

```text
GNOME 会话
→ Screenshot 使用 GNOME Portal
→ Flameshot 显示三块屏幕供选择

Niri 会话
→ Screenshot 使用 wlr Portal
→ wlr-screencopy 从 Niri 获取图像
→ 进入 Flameshot 编辑界面
```

两个桌面都继续使用同一条命令：

```bash
QT_QPA_PLATFORM=wayland flameshot gui
```

Portal 根据桌面会话设置的 `XDG_CURRENT_DESKTOP` 自动选择配置，无需手工切换。切换桌面时应注销后重新登录。

更完整的 Portal 配置说明、依赖、升级比较和回退方法见：

```text
../xdg-desktop-portal/README.md
```

## 11. 仓库管理位置

Flameshot 用户启动项保存在仓库：

```text
/home/terry/project/manjaro-workspace/.config/applications/
  org.flameshot.Flameshot.desktop
```

实际使用位置是单文件符号链接：

```text
~/.local/share/applications/org.flameshot.Flameshot.desktop
  -> /home/terry/project/manjaro-workspace/.config/applications/org.flameshot.Flameshot.desktop
```

Niri Portal 配置保存在仓库：

```text
/home/terry/project/manjaro-workspace/.config/xdg-desktop-portal/
  niri-portals.conf
```

实际使用位置是目录符号链接：

```text
~/.config/xdg-desktop-portal
  -> /home/terry/project/manjaro-workspace/.config/xdg-desktop-portal
```

部署、校验、升级比较和回退方式分别见两个目录中的 README。
