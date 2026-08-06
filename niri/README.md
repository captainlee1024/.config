# Niri 配置

当前 `~/.config/niri` 使用软链接指向本仓库中的 `niri/`，因此修改仓库中的配置就是修改实际生效的配置。

## 如何使用

现在我们使用软链接的方式，启动niri时使用我们仓库里的niri配置

首先备份并删除~/.config/niri

```bash
mv ./niri ./_niri_bac
```

建立软链接

```bash
ln -s "$(pwd)/niri" ~/.config/niri
```

## Desktop Shell 架构

Niri 只负责窗口管理；状态栏、启动器和通知由独立的 Desktop Shell 组件负责。目前保留两套模式：

| 模式 | 状态栏 | 启动器 | 通知 |
| --- | --- | --- | --- |
| DMS（当前模式） | DMS | DMS | DMS |
| Classic（保留备用） | Waybar `gruvbox_2` | Fuzzel | Mako |

暂不引入 iNiR，也不拆分 `niri/config.kdl`。DMS 的状态栏、启动器、通知、音量、网络和托盘均已验证可用；当前主题是 `Gruvbox Multi / Mat. H / Green`，GTK/Qt 系统主题同步保持关闭。

`desktop-profile` 负责切换并记住当前模式。Niri 登录时只调用一次 `desktop-profile start`，不再直接启动 Waybar 或 Mako。状态文件不存在时默认使用 DMS。

### DMS 的安装与配置归属

DMS 使用 Arch/Manjaro 官方软件包安装：

```bash
sudo pacman -S dms-shell-niri
```

新版软件包分为两层：

- `dms-shell` 是共用的 DMS 主程序。
- `dms-shell-niri` 是 Niri 对应的适配/依赖包，并提供虚拟依赖 `dms-shell-compositor`。

程序文件由 Pacman 管理：

- 命令：`/usr/bin/dms`
- DMS/Quickshell 程序文件：`/usr/share/quickshell/dms/`
- systemd 用户服务：`/usr/lib/systemd/user/dms.service`

这些程序文件不复制进 dotfiles，也不创建 `~/.config/quickshell/dms/`。升级统一使用 `sudo pacman -Syu`。

DMS 的个人设置目录已经软链接到本仓库：

```text
~/.config/DankMaterialShell
  -> /home/terry/project/manjaro-workspace/.config/DankMaterialShell
```

仓库跟踪：

```text
DankMaterialShell/
├── settings.json
└── themes/
    ├── gruvboxMaterial/
    └── gruvboxMulti/
```

以后通过 DMS 设置界面修改选项时，会直接更新仓库中的 `settings.json`，Git 只记录变化，不会自动提交。`.firstlaunch`、`.changelog-*`、缓存和运行状态不纳入仓库，它们会由 DMS 自动重建。

DMS 还会自动生成 `~/.config/niri/dms/`。当前 `niri/config.kdl` 没有 include 这些文件，所以它们不会改变现有布局、字体、字号、分辨率或缩放；这些自动生成文件已被 Git 忽略。

最终职责边界：

```text
~/.config/niri/                 -> 本仓库 niri/，管理 Niri
~/.config/waybar/               -> 本仓库 waybar/，管理 Classic 状态栏主题
~/.config/DankMaterialShell/    -> 本仓库 DankMaterialShell/，管理 DMS 个人设置和主题
~/.local/bin/desktop-profile    -> 本仓库 bin/desktop-profile
```

运行时，Waybar 与 DMS 状态栏二选一，Mako 与 DMS 通知服务二选一。切换只控制进程，不搬动或覆盖配置文件。DMS 使用软件包自带的 `dms.service`，但该服务保持 `disabled`，只由 `desktop-profile` 按需启动和停止。

### 模式切换命令

```bash
desktop-profile dms      # 切换到 DMS
desktop-profile classic  # 切换到 Waybar + Fuzzel + Mako
desktop-profile toggle   # 在两种模式间切换
desktop-profile status   # 显示保存状态与实际进程状态
desktop-profile start    # 登录时恢复上次模式，主要供 Niri 调用
```

当前模式保存在：

```text
~/.local/state/desktop-profile/current
```

该文件只包含 `dms` 或 `classic`，属于运行状态，不提交到仓库。切换脚本经过 `DMS -> Classic -> DMS` 往返验证，并避免重复启动状态栏或通知服务。

Niri 的固定自启动入口是：

```kdl
spawn-at-startup "/home/terry/.local/bin/desktop-profile" "start"
```

也可以按 `Mod+Shift+B` 快速切换两种模式。

### DMS 常用命令

检查安装和依赖：

```bash
dms doctor
```

```bash
dms ipc call spotlight toggle       # 打开启动器
dms ipc call settings focusOrToggle # 打开设置
dms restart                         # 重启 DMS
```

正常切换不要直接执行 `dms kill` 或 `pkill`，统一使用 `desktop-profile`，否则保存的模式可能与实际进程不一致。

### 新系统恢复

安装 DMS、克隆本仓库并确认目标不存在后，建立两个链接：

```bash
ln -s /home/terry/project/manjaro-workspace/.config/DankMaterialShell ~/.config/DankMaterialShell
ln -s /home/terry/project/manjaro-workspace/.config/bin/desktop-profile ~/.local/bin/desktop-profile
```

然后执行：

```bash
desktop-profile dms
```

缓存、运行状态和 `niri/dms/` 会自动重新生成。当前不执行 `dms setup`，不全局启用 `dms.service`，也不让 DMS 管理显示器输出。

## 快捷键

本节记录 `config.kdl` 中当前实际启用的快捷键。正常启动 niri 时，下面的 `Mod` 指键盘上的 `Super`（Windows 徽标键）；如果把 niri 嵌套运行在窗口中，`Mod` 则是 `Alt`。

### niri 的窗口组织方式

niri 横向排列“列”，同一列中可以纵向放置多个窗口。理解这一点后，大部分组合键会比较直观：

- 左右操作通常针对整列。
- 上下操作通常针对同一列里的单个窗口。
- 只按 `Mod` 的方向键通常是切换焦点；再加 `Ctrl` 通常是移动窗口或整列。
- 再加 `Shift` 的方向键通常用于显示器或工作区操作。

以下表格中的具体行为优先于上述记忆规律。

### 帮助、程序与会话

| 快捷键 | 作用 | 使用说明 |
| --- | --- | --- |
| `Mod+Shift+/`（通常显示为 `Mod+?`） | 打开快捷键帮助 | 显示 niri 内置的快捷键浮层。 |
| `Mod+T` | 打开终端 | 启动 Alacritty。 |
| `Mod+D` | 打开程序启动器 | 启动 Fuzzel，用于搜索并运行应用。 |
| `Super+Alt+L` | 锁定屏幕 | 启动 Swaylock；这里写死的是 `Super`，不是 `Mod`。 |
| `Mod+Q` | 关闭窗口 | 关闭当前聚焦窗口。 |
| `Mod+Escape` | 切换快捷键抑制 | 远程桌面或软件 KVM 接管快捷键时，用它恢复或重新允许接管。这个组合始终由 niri 处理。 |
| `Mod+Shift+E` | 退出 niri | 会先显示确认对话框。 |
| `Ctrl+Alt+Delete` | 退出 niri | 与 `Mod+Shift+E` 相同，会先确认。 |
| `Mod+Shift+P` | 关闭显示器 | 让所有显示器进入关闭状态；移动鼠标或按键即可唤醒。 |

### 聚焦与移动窗口

方向键和 `H/J/K/L` 是两套等价操作，可以按使用习惯选择。

| 快捷键 | 作用 | 使用说明 |
| --- | --- | --- |
| `Mod+Left` / `Mod+H` | 聚焦左侧列 | 将焦点切换到左边的列。 |
| `Mod+Right` / `Mod+L` | 聚焦右侧列 | 将焦点切换到右边的列。 |
| `Mod+Up` / `Mod+K` | 聚焦上方窗口 | 在当前列内向上切换窗口。 |
| `Mod+Down` / `Mod+J` | 聚焦下方窗口 | 在当前列内向下切换窗口。 |
| `Mod+Ctrl+Left` / `Mod+Ctrl+H` | 向左移动列 | 将当前窗口所在的整列向左移动。 |
| `Mod+Ctrl+Right` / `Mod+Ctrl+L` | 向右移动列 | 将当前窗口所在的整列向右移动。 |
| `Mod+Ctrl+Up` / `Mod+Ctrl+K` | 向上移动窗口 | 调整当前窗口在列内的上下顺序。 |
| `Mod+Ctrl+Down` / `Mod+Ctrl+J` | 向下移动窗口 | 调整当前窗口在列内的上下顺序。 |
| `Mod+Home` | 聚焦第一列 | 跳到当前工作区最左侧的列。 |
| `Mod+End` | 聚焦最后一列 | 跳到当前工作区最右侧的列。 |
| `Mod+Ctrl+Home` | 将列移到最前 | 把当前列移动到工作区最左侧。 |
| `Mod+Ctrl+End` | 将列移到最后 | 把当前列移动到工作区最右侧。 |

### 显示器

| 快捷键 | 作用 | 使用说明 |
| --- | --- | --- |
| `Mod+Shift+方向键` | 聚焦相邻显示器 | 按物理方向切换显示器；也可以用 `Mod+Shift+H/J/K/L`。 |
| `Mod+Ctrl+Shift+方向键` | 将列移到相邻显示器 | 把当前整列移动到对应方向的显示器；也可以使用 `H/J/K/L`。 |

这里移动的是整列。如果一列中纵向堆叠了多个窗口，它们会一起移动到目标显示器。

### 工作区

niri 的工作区按上下方向动态排列，并始终在底部保留一个空工作区。

| 快捷键 | 作用 | 使用说明 |
| --- | --- | --- |
| `Mod+Page_Down` / `Mod+U` | 聚焦下一个工作区 | 向下切换工作区。 |
| `Mod+Page_Up` / `Mod+I` | 聚焦上一个工作区 | 向上切换工作区。 |
| `Mod+Ctrl+Page_Down` / `Mod+Ctrl+U` | 将列移到下方工作区 | 把当前整列移动到下方工作区。 |
| `Mod+Ctrl+Page_Up` / `Mod+Ctrl+I` | 将列移到上方工作区 | 把当前整列移动到上方工作区。 |
| `Mod+Shift+Page_Down` / `Mod+Shift+U` | 工作区向下重排 | 改变当前工作区在动态列表中的顺序。 |
| `Mod+Shift+Page_Up` / `Mod+Shift+I` | 工作区向上重排 | 改变当前工作区在动态列表中的顺序。 |
| `Mod+1` 到 `Mod+9` | 聚焦指定工作区 | 按动态索引切换；目标编号超过现有数量时，会落到最底部的空工作区。 |
| `Mod+Ctrl+1` 到 `Mod+Ctrl+9` | 将列移到指定工作区 | 把当前整列移动到对应索引的工作区。 |

### 列组合与拆分

| 快捷键 | 作用 | 使用说明 |
| --- | --- | --- |
| `Mod+[` | 向左组合或拆出窗口 | 窗口独占一列时，将它并入左侧列；窗口已在多窗口列中时，将它向左拆成新列。 |
| `Mod+]` | 向右组合或拆出窗口 | 窗口独占一列时，将它并入右侧列；窗口已在多窗口列中时，将它向右拆成新列。 |
| `Mod+,` | 从右侧吸收窗口 | 从右侧列取一个窗口，放到当前列底部。 |
| `Mod+.` | 向右拆出窗口 | 将当前列最底部的窗口拆到右侧新列。 |

### 尺寸与布局

当前列宽和窗口高度的预设比例均为 `1/3`、`1/2`、`2/3` 和全屏尺寸。

| 快捷键 | 作用 | 使用说明 |
| --- | --- | --- |
| `Mod+R` | 循环切换列宽 | 在列宽预设比例之间切换。 |
| `Mod+Shift+R` | 循环切换窗口高度 | 当一列中有多个窗口时，在高度预设比例之间切换。 |
| `Mod+Ctrl+R` | 重置窗口高度 | 清除当前窗口的手动高度设置。 |
| `Mod+F` | 最大化列 | 让当前列占据显示器宽度，但仍属于平铺布局。 |
| `Mod+Shift+F` | 窗口全屏 | 让当前窗口进入或退出真正的全屏状态。 |
| `Mod+Ctrl+F` | 扩展到可用宽度 | 让当前列填满其他完整可见列未占用的水平空间。 |
| `Mod+C` | 居中当前列 | 将聚焦列移动到显示器中央。 |
| `Mod+-` / `Mod+=` | 调整列宽 | 每次将当前列宽减少或增加 `10%`。 |
| `Mod+Shift+-` / `Mod+Shift+=` | 调整窗口高度 | 每次将当前窗口高度减少或增加 `10%`。 |
| `Mod+V` | 切换浮动状态 | 在浮动窗口和平铺窗口之间移动当前窗口。 |
| `Mod+Shift+V` | 切换浮动/平铺焦点 | 在浮动层和平铺层之间切换焦点。 |
| `Mod+W` | 切换列标签模式 | 将当前列的窗口在纵向堆叠和标签页显示之间切换。 |

### 鼠标滚轮操作

| 快捷键 | 作用 | 使用说明 |
| --- | --- | --- |
| `Mod+滚轮上/下` | 切换工作区 | 向上或向下切换工作区，带有 `150 ms` 防误触间隔。 |
| `Mod+Ctrl+滚轮上/下` | 移动列到工作区 | 将当前整列移到上方或下方工作区。 |
| `Mod+横向滚轮左/右` | 切换列 | 聚焦左侧或右侧列。 |
| `Mod+Ctrl+横向滚轮左/右` | 移动列 | 将当前列向左或向右移动。 |
| `Mod+Shift+滚轮上/下` | 横向切换列 | 普通鼠标没有横向滚轮时，用纵向滚轮切换左右列。 |
| `Mod+Ctrl+Shift+滚轮上/下` | 横向移动列 | 普通鼠标没有横向滚轮时，用纵向滚轮移动当前列。 |

滚轮方向会受到设备 `natural-scroll` 设置影响。

### 截图与音频

| 快捷键 | 作用 | 使用说明 |
| --- | --- | --- |
| `Print` | 交互式截图 | 打开 niri 截图界面。图片保存到 `~/Pictures/Screenshots/`。 |
| `Ctrl+Print` | 截取显示器 | 截取当前显示器。 |
| `Alt+Print` | 截取窗口 | 截取当前聚焦窗口。 |
| 音量增加键 | 增大音量 | 通过 WirePlumber 将默认输出设备音量增加 `0.1`。锁屏时仍可使用。 |
| 音量降低键 | 减小音量 | 通过 WirePlumber 将默认输出设备音量降低 `0.1`。锁屏时仍可使用。 |
| 静音键 | 切换输出静音 | 切换默认音频输出设备的静音状态。锁屏时仍可使用。 |
| 麦克风静音键 | 切换麦克风静音 | 切换默认音频输入设备的静音状态。锁屏时仍可使用。 |
