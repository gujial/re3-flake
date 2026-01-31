# re3-flake

这是一个基于 Nix Flake 的包装器，旨在简化在 Linux (NixOS) 上运行 **re3** (GTA III), **reVC** (GTA Vice City) 和 **reLCS** (Liberty City Stories) 的过程。

## 🌟 功能特性

- **自动化初始化**：首次运行自动从 Steam 目录复制原始游戏资源。
- **无缝更新**：每次启动都会自动将 Nix 编译的最新引擎（及 Shader、资源文件）同步到游戏目录。
- **桌面集成**：自动生成带图标的 `.desktop` 菜单入口。
- **多版本支持**：针对 master (III)、miami (VC) 和 lcs 分支分别提供了独立的配置。

## 🛠️ 安装

在你的系统 `flake.nix` 中引入此包装器：

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # 引入本包装器
    re3-wrapper.url = "github:你的用户名/你的包装器仓库名";
  };

  outputs = { self, nixpkgs, re3-wrapper, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            # 选择你想要安装的游戏
            re3-wrapper.packages.${pkgs.system}.re3
            re3-wrapper.packages.${pkgs.system}.reVC
            re3-wrapper.packages.${pkgs.system}.reLCS
          ];
        })
      ];
    };
  };
}
```

## 🚀 首次使用说明

### 1. 默认 Steam 路径
如果你在默认位置安装了 Steam 版游戏，包装器会自动检测：
- **re3**: `$HOME/.steam/steam/steamapps/common/Grand Theft Auto 3`
- **reVC**: `$HOME/.steam/steam/steamapps/common/Grand Theft Auto Vice City`

### 2. 非标准路径 (或非 Steam 版)
如果你的原始游戏文件位于其他位置，或正在尝试运行没有 Steam 版的 **reLCS**，请通过环境变量运行：

```bash
# 示例：首次运行 reVC 时指定资源路径
export STEAM_GAME_DIR="/path/to/your/GTA_VC_Files"
reVC
```
一旦完成首次复制，以后直接启动即可。

## 📁 工作目录
为了保证 Nix Store 的纯净性并允许游戏保存进度，游戏会在你的家目录下运行：
- **GTA III**: `~/.re3/`
- **Vice City**: `~/.reVC/`
- **LCS**: `~/.reLCS/`

**注意**：如果你想修改设置或安装模组，请前往上述目录进行操作。包装器每次启动会覆盖引擎二进制和系统资源，但不会删除你的存档或自定义文件。

## 🔧 开发与构建逻辑

包装器遵循以下执行逻辑：
1. **检查**：目标目录（如 `~/.reVC`）是否存在。
2. **初始化**（仅限首次）：从源路径复制大型资源（`.img`, `.dir`, `.mp3`）。
3. **同步**：从 Nix Store 强制覆盖最新的 `re3/reVC` 二进制文件及 `share` 目录下的 Shader/模版。
4. **启动**：进入目标目录并执行。

## 📄 开关参数
本包装器脚本支持所有 `re3` 原始程序的命令行参数。例如：
```bash
reVC -windowed
```

--- 

### 贡献与支持
如果你在使用过程中发现图标未显示或路径匹配错误，请提交 Issue。