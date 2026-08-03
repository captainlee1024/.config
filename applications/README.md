# 用户级 Desktop 启动项

本目录只保存经过排查、确实需要覆盖系统默认行为、并希望在重装后恢复的用户级 `.desktop` 文件。

它不是 `~/.local/share/applications` 的完整备份，也不会把该目录整体链接到仓库。

## 为什么只管理单个文件

实际目录：

```text
~/.local/share/applications
```

可能包含 Zoom、JetBrains、Clash、浏览器 PWA 等大量应用自动生成的启动项。这些文件可能带机器路径、随机 ID，或者随应用安装和卸载变化。

因此采用单文件管理：

```text
需要维护的文件
  -> 单独链接到本仓库

其他应用自动生成的文件
  -> 继续留在 ~/.local/share/applications
```

当前只管理 Flameshot。Zoom 将在后续独立处理，避免把两个尚未一起审查的方案混入同一次提交。

## Flameshot 文件与部署关系

系统软件包文件：

```text
/usr/share/applications/org.flameshot.Flameshot.desktop
```

仓库文件：

```text
/home/terry/project/manjaro-workspace/.config/applications/org.flameshot.Flameshot.desktop
```

实际用户入口：

```text
~/.local/share/applications/org.flameshot.Flameshot.desktop
```

最终只为该文件建立链接：

```text
~/.local/share/applications/org.flameshot.Flameshot.desktop
  -> /home/terry/project/manjaro-workspace/.config/applications/org.flameshot.Flameshot.desktop
```

不要把整个 `~/.local/share/applications` 链接到本目录。

## 当前修改

系统主入口原来只启动 Flameshot 后台程序：

```ini
Exec=/usr/bin/flameshot
```

GNOME 默认没有提供 Flameshot 所需的传统托盘服务，直接启动后台程序时曾出现：

```text
QDBusTrayIcon encountered a D-Bus error:
org.freedesktop.DBus.Error.ServiceUnknown
The name is not activatable
```

当前主入口改为使用原生 Wayland 并直接进入截图：

```ini
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot gui
```

三个 Desktop Action 也全部显式使用 Wayland：

```ini
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot config
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot gui
Exec=env QT_QPA_PLATFORM=wayland /usr/bin/flameshot launcher
```

其中：

- `gui`：直接获取截图并进入框选、标注界面；
- `launcher`：先打开 Flameshot 功能选择器；
- `config`：打开 Flameshot 设置。

`QT_QPA_PLATFORM=wayland` 只负责让 Flameshot 界面使用原生 Wayland。屏幕图像由 `xdg-desktop-portal` 获取，GNOME/Niri 的后端选择见 `../xdg-desktop-portal/README.md`。

完整问题背景和排障过程见 `flameshot-wayland.md`。

## 日常使用

从 GNOME 或 Niri 的应用列表点击 Flameshot，会执行：

```bash
env QT_QPA_PLATFORM=wayland /usr/bin/flameshot gui
```

终端直接截图：

```bash
QT_QPA_PLATFORM=wayland flameshot gui
```

终端打开功能选择器：

```bash
QT_QPA_PLATFORM=wayland flameshot launcher
```

不需要先启动后台进程。

## 新系统部署

安装 Flameshot 和 Qt Wayland 支持：

```bash
sudo pacman -S flameshot qt6-wayland
```

克隆仓库后，确保目标文件不存在或已经备份，然后创建单文件链接：

```bash
mkdir -p ~/.local/share/applications

ln -s \
  /home/terry/project/manjaro-workspace/.config/applications/org.flameshot.Flameshot.desktop \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop
```

如果桌面应用列表没有立即刷新，可以注销并重新登录。

## 验证

确认链接目标：

```bash
readlink -f \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop
```

校验 Desktop 文件格式：

```bash
desktop-file-validate \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop
```

没有输出通常表示校验通过。

查看所有启动命令：

```bash
grep '^Exec=' \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop
```

每一条都应该包含：

```text
QT_QPA_PLATFORM=wayland
```

## 软件升级后的检查

Pacman 升级 Flameshot 时只更新：

```text
/usr/share/applications/org.flameshot.Flameshot.desktop
```

不会覆盖用户文件或仓库文件。用户文件继续优先，但不会自动获得上游新增的启动参数、翻译或 Desktop Action。

升级后比较：

```bash
diff -u \
  /usr/share/applications/org.flameshot.Flameshot.desktop \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop
```

当前已知的预期差异是四条 `Exec=`。如果出现其他差异，应先审查新版系统文件，再把有意义的上游变化合并进仓库，并重新运行 `desktop-file-validate`。

## 回退到系统默认入口

暂时停用用户覆盖：

```bash
mv \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop \
  ~/.local/share/applications/org.flameshot.Flameshot.desktop.disabled
```

桌面环境随后会重新使用 `/usr/share/applications/org.flameshot.Flameshot.desktop`。如未立即刷新，可以注销并重新登录。

恢复时把链接名称改回即可，仓库文件不会丢失。

## 纳入新应用的标准

只有同时满足以下条件，才把新的 `.desktop` 文件加入本目录：

1. 系统默认启动方式存在明确问题；
2. 已经完成排查并验证修改有效；
3. 修改在重装后仍有复用价值；
4. 文件不依赖随机 ID 或不可移植的机器路径；
5. 已记录系统原文件、具体差异、验证和回退方法；
6. 只链接目标文件，不接管整个用户 applications 目录。
