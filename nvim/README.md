## 如何使用

1. 备份并移除电脑现有的~/.config/nvim目录
2. 将仓库下的该目录连接建立软链接到~/.config/nvim

```bash
ln -s "$(pwd)/nvim" ~/.config/nvim
```
