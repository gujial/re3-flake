# reLCS

> 暂无 logo 图片（游戏图标同理）

## Flake 使用说明

1. Flake.nix 配置

```nix
{
  inputs = {
    re3-flake = {
      url = "github:gujial/re3-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
  };
  outputs = inputs@{ nixpkgs, re3flake, ... }: {
    host = nixpkgs.lib.nixosSystem {
      modules = [
        (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [
                  nur.overlays.default
                ];

                environment.systemPackages = [
                  re3-flake.packages.${pkgs.system}.re3-lcs
                  # ...
                ];
              }
            )
        # ...
      ];
    };
  };
}
```

2. 复制游戏文件到 ~/.reLCS
3. 复制 gamefiles 到 ~/.reLCS 并覆盖原版游戏文件

> 仅供学习交流使用，安装后请于 24 小时内删除，禁止用于商业用途，禁止传播盗版游戏。

## Intro

The aim of this project is to reverse GTA Liberty City Stories.

## How can I try it?

- reLCS requires game assets to work.
- Build reLCS or download it from one of the above links (Debug or Release).
- (Optional) If you want to use optional features, copy the files in /gamefiles folder to your game root folder.
- Move reLCS.exe to GTA LCS directory and run it.

## Preparing the environment for building

You may want to point GTA_LCS_RE_DIR environment variable to GTA LCS root folder if you want executable to be moved there via post-build script.

- For Linux, proceed: [Building on Linux](https://github.com/GTAmodding/re3/wiki/Building-on-Linux)
- For FreeBSD, proceed: [Building on FreeBSD](https://github.com/GTAmodding/re3/wiki/Building-on-FreeBSD) 
- For Windows, assuming you have Visual Studio:
    - Clone the repo using the argument `--recursive`.
    - Run one of the `premake-vsXXXX.cmd` variants on root folder.
    - Open the project via Visual Studio  
    
**If you use 64-bit D3D9**: We don't ship 64-bit Dx9 SDK. You need to download it from Microsoft if you don't have it(although it should come pre-installed after some Windows version)  

There are various settings at the very bottom of [config.h](https://github.com/GTAmodding/re3/tree/lcs/src/core/config.h), you may want to take a look there. i.e. FIX_BUGS define fixes the bugs we've come across.

> :information_source: **If you choose OpenAL on Windows** You must read [Running OpenAL build on Windows](https://github.com/GTAmodding/re3/wiki/Running-OpenAL-build-on-Windows).

> :information_source: **Did you notice librw?** reLCS uses completely homebrew RenderWare-replacement rendering engine; [librw](https://github.com/aap/librw/). librw comes as submodule of reLCS, but you also can use LIBRW enviorenment variable to specify path to your own librw.

## Contributing
Please read the [Coding Style](https://github.com/GTAmodding/re3/blob/master/CODING_STYLE.md) Document

