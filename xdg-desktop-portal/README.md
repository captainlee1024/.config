# xdg-desktop-portal 用户配置

本目录保存由本仓库维护的用户级 `xdg-desktop-portal` 后端选择配置。目前只针对 Niri 会话覆盖截图和屏幕共享后端，不修改 GNOME 的默认行为。

## 目录部署方式

仓库目录：

```text
/home/terry/project/manjaro-workspace/.config/xdg-desktop-portal
```

实际配置位置：

```text
~/.config/xdg-desktop-portal
```

部署时使用整个目录的符号链接：

```text
~/.config/xdg-desktop-portal
  -> /home/terry/project/manjaro-workspace/.config/xdg-desktop-portal
```

这个目录只包含少量、静态、人工维护的 Portal 选择配置。Portal 服务正常运行时只读取这些文件，不会自动改写它们，因此适合进行目录级管理。

## 当前文件

```text
niri-portals.conf
```

当前内容：

```ini
[preferred]
default=gnome;gtk;
org.freedesktop.impl.portal.Access=gtk;
org.freedesktop.impl.portal.Notification=gtk;
org.freedesktop.impl.portal.Secret=gnome-keyring;
org.freedesktop.impl.portal.ScreenCast=wlr;
org.freedesktop.impl.portal.Screenshot=wlr;
```

## 为什么需要该配置

Flameshot 14 在 Linux Wayland 下优先通过 `org.freedesktop.portal.Screenshot` 获取屏幕图像。

在 GNOME Wayland 三显示器环境中，`xdg-desktop-portal-gnome` 可以完成该请求，Flameshot 会显示三个屏幕供选择。

在 Niri 26.04 三显示器环境中，通过 GNOME Screenshot Portal 请求整张桌面时曾出现：

```text
niri: error taking a screenshot:
Condition failed: outputs.len() == 1 (3 vs 1)

xdg-desktop-portal-gnome:
Failed to get screenshot:
GDBus.Error:org.freedesktop.DBus.Error.Failed: internal error
```

因此仅在 Niri 会话中把 Screenshot 接口切换到 `xdg-desktop-portal-wlr`：

```ini
org.freedesktop.impl.portal.Screenshot=wlr;
```

Niri 支持 `wlr-screencopy`，所以 wlr Portal 可以获取三显示器画面。

Zoom 7.1.5 在 Niri 26.04 下通过 GNOME ScreenCast Portal 发起共享时，本地可以选择显示器并显示正在共享，但远端参会者收不到画面。日志显示 Niri 已创建 PipeWire 流，随后格式协商失败：

```text
Paused -> Error("no more input formats")
pw.link ... negotiating -> error no more input formats
```

测试 `force-pipewire-invalid-modifier` 后错误仍然存在，因此没有保留该 Niri debug 选项。

最终把 Niri 的 ScreenCast 接口也切换到 wlr Portal：

```ini
org.freedesktop.impl.portal.ScreenCast=wlr;
```

修改后，`zoom-host` 在 Niri 原生 Wayland 模式下发起共享，远端参会者可以正常看到画面。因此 Niri 当前的两个屏幕相关接口都走 wlr：

```text
Screenshot -> xdg-desktop-portal-wlr -> Flameshot
ScreenCast -> xdg-desktop-portal-wlr -> Zoom
```

该覆盖会影响 Niri 会话中所有使用标准 ScreenCast Portal 的应用，而不只影响 Zoom。wlr Portal 更偏向输出/显示器捕获；Niri 的 GNOME Portal 所提供的窗口选择、动态 Cast Target 等高级能力可能不可用。如果以后其他录屏或会议软件需要这些功能，应重新测试后端取舍。

## 为什么不会影响 GNOME

桌面会话会设置 `XDG_CURRENT_DESKTOP`：

```text
GNOME 会话：XDG_CURRENT_DESKTOP=GNOME
Niri 会话： XDG_CURRENT_DESKTOP=niri
```

`xdg-desktop-portal` 根据该变量选择 `<desktop>-portals.conf`。因此：

```text
XDG_CURRENT_DESKTOP=niri
  -> 读取 niri-portals.conf

XDG_CURRENT_DESKTOP=GNOME
  -> 不读取 niri-portals.conf
```

从 GNOME 和 Niri 之间切换时，应正常注销当前会话并重新登录，使 Portal 服务继承新桌面的环境。不要在一个桌面会话里嵌套启动另一个桌面来验证 Portal 选择。

## 配置优先级

Niri 软件包提供系统默认文件：

```text
/usr/share/xdg-desktop-portal/niri-portals.conf
```

本仓库部署的是同名用户文件：

```text
~/.config/xdg-desktop-portal/niri-portals.conf
```

用户配置优先于系统配置。Pacman 升级 Niri 时只更新 `/usr/share` 中的系统文件，不会覆盖用户配置或仓库文件。

代价是：上游以后修改系统默认 Portal 配置时，本仓库的用户覆盖不会自动合并这些变化，因此升级后需要主动比较。

## 软件依赖

Arch/Manjaro 环境需要安装：

```bash
sudo pacman -S \
  xdg-desktop-portal \
  xdg-desktop-portal-gnome \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-wlr
```

Flameshot 还需要：

```bash
sudo pacman -S flameshot qt6-wayland
```

Niri 和 Flameshot 的具体版本应以系统仓库当前版本为准。配置文件存在不代表后端软件已经安装。

## 新系统部署

先安装所需软件包并克隆本仓库，然后确认实际路径不存在或已经备份，再创建链接：

```bash
ln -s \
  /home/terry/project/manjaro-workspace/.config/xdg-desktop-portal \
  ~/.config/xdg-desktop-portal
```

完成后注销并重新登录 Niri。也可以在确定当前没有重要屏幕共享任务时重启 Portal：

```bash
systemctl --user restart xdg-desktop-portal.service
```

重启 Portal 会短暂中断正在使用 Portal 的文件选择、屏幕共享等操作。

## 验证

查看当前桌面：

```bash
printf '%s\n' "$XDG_CURRENT_DESKTOP"
```

检查链接：

```bash
readlink -f ~/.config/xdg-desktop-portal
```

在 Niri 下测试 Flameshot：

```bash
QT_QPA_PLATFORM=wayland flameshot gui
```

在 Niri 下测试 Zoom 发起共享：

```bash
zoom-host
```

进入会议、选择显示器并开始共享后，需要由另一位参会者确认远端画面确实可见。只看到本地“正在共享”状态不足以证明视频帧已经成功发送。

检查 Portal 和 Flameshot 日志：

```bash
journalctl --user -b --no-pager |
  grep -Ei 'flameshot|xdg-desktop-portal|screenshot|wlr'
```

## 升级后的检查

升级 Niri 或 Portal 后比较系统默认和用户覆盖：

```bash
diff -u \
  /usr/share/xdg-desktop-portal/niri-portals.conf \
  ~/.config/xdg-desktop-portal/niri-portals.conf
```

已知的预期差异包括显式指定：

```ini
org.freedesktop.impl.portal.ScreenCast=wlr;
org.freedesktop.impl.portal.Screenshot=wlr;
```

如果出现其他差异，应先阅读新版系统文件，再决定是否同步到仓库，不要直接用系统文件覆盖用户版本。

## 回退

若怀疑本配置导致问题，可以暂时把链接改名：

```bash
mv \
  ~/.config/xdg-desktop-portal \
  ~/.config/xdg-desktop-portal.disabled
```

然后注销并重新登录。没有用户覆盖后，Portal 将重新使用 `/usr/share/xdg-desktop-portal/niri-portals.conf`。

验证完成后，可把链接名称恢复。仓库中的配置文件不会因此丢失。
