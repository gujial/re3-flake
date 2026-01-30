# re3-flake

本仓库提供一个 Nix flake，用于构建多个 re3 分支的可执行文件（GTA III / Vice City / Liberty City Stories）。

## 前置条件

- 已安装并启用 Nix（推荐启用 flake）：
  - 在 `~/.config/nix/nix.conf` 中包含 `experimental-features = nix-command flakes`

## 构建

在仓库根目录执行以下命令（任选其一）：

- 构建 GTA III（master 分支）：
  - `nix build .#re3`
- 构建 Vice City（miami 分支）：
  - `nix build .#re3-vc`
- 构建 Liberty City Stories（lcs 分支）：
  - `nix build .#re3-lcs`

构建产物位于 `./result`。

## 运行

构建完成后，可直接运行 `result/bin` 下的可执行文件：

- GTA III：`./result/bin/re3`
- Vice City：`./result/bin/reVC`
- LCS：`./result/bin/reLCS`

## 说明

- 构建过程使用 `premake5` 生成 `gmake2` 工程并以 OpenAL + GLFW + OpenGL3 的配置编译。
- 构建会创建 Desktop 文件与图标，安装到 `$out/share` 目录。
- 运行时默认工作目录为：
  - `~/.re3`、`~/.reVC`、`~/.reLCS`
