主题1和3相同，3是1的备份，1有部分修改
当前niri使用的是主题2

FIXME: 主题2中的天气和cava有问题，需要修复

## 如何使用

首先将~/.config/waybar备份

```bash
mv ./waybar ./_waybar_bac
```

然后将仓库的waybar软链接建立到~/.config下

```bash
ln -s "$(pwd)/waybar" ~/.config/waybar
```
