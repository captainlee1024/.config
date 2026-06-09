## 如何使用

leaf 是一个终端 Markdown 预览工具，不是 Nvim 插件。它可以在终端里渲染 Markdown、LaTeX，并把 Mermaid 渲染成 ASCII 图。

安装：

```bash
yay -S leaf-markdown-viewer
```

检查版本：

```bash
leaf --version
```

预览文件：

```bash
leaf README.md
```

监听文件变化并自动刷新：

```bash
leaf -w README.md
```

## 链接配置

当前仓库里的配置目录是：

```text
leaf/
```

leaf 默认读取：

```text
~/.config/leaf/config.toml
```

如果系统里已经有 leaf 配置，先备份：

```bash
mv ~/.config/leaf ~/.config/leaf_bak
```

在本仓库 `.config` 目录下执行软链接：

```bash
ln -s "$(pwd)/leaf" ~/.config/leaf
```

检查链接：

```bash
ls -l ~/.config/leaf
```

## Nvim 中使用

leaf 更适合在全宽终端里看 Mermaid。不要优先用竖向 split，因为 Mermaid ASCII 图宽度不够时容易换行错乱。

临时在 Nvim 中打开当前 Markdown 文件：

```vim
:execute 'tab terminal leaf -w ' . shellescape(expand('%:p'))
```

如果以后要加快捷键，可以放到 Nvim 配置里：

```vim
nnoremap <Leader>ml :execute 'tab terminal leaf -w ' . shellescape(expand('%:p'))<CR>
```

使用时：

```text
<Leader>ml
```

会新开一个 Nvim tab，在里面运行 `leaf -w 当前文件`。

## 注意

`width` 配置只是限制正文最大宽度，不能把 Mermaid ASCII 图自动缩放到终端宽度内。复杂 Mermaid 图仍然建议使用 `markdown-preview.nvim` 的浏览器预览。
