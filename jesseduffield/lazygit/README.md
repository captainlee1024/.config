## 如何使用

这个目录是 lazygit 的配置目录，用于通过仓库管理 `~/.config/jesseduffield/lazygit`。

当前配置使用 `delta` 作为 lazygit 的 diff pager，并开启左右对照显示：

```yaml
git:
  pagers:
    - colorArg: always
      pager: delta --dark --side-by-side --paging=never --24-bit-color=never --syntax-theme="OneHalfDark"
```

使用前确认已经安装 delta：

```bash
delta --version
```

备份并移除电脑现有的 lazygit 配置目录：

```bash
mv ~/.config/jesseduffield/lazygit ~/.config/jesseduffield/lazygit_bak
```

在仓库 `.config` 目录下建立软链接：

```bash
ln -s "$(pwd)/jesseduffield/lazygit" ~/.config/jesseduffield/lazygit
```

完成后打开 lazygit：

```bash
lazygit
```
