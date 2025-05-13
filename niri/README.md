Niri配置暂时先不使用同软链接的方式
配置有变更是，删除仓库中的配置，cp最新的niri配置到仓库里，以进行配置的更新维护

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
