# re3-flake

English | [简体中文](README.zh_CN.md)

A Nix Flake-based wrapper to simplify running **re3** (GTA III), **reVC** (GTA Vice City), and **reLCS** (Liberty City Stories) on Linux (NixOS).

## 🌟 Features

- **Automated Initialization**: Automatically copies original game assets from Steam directory on first run.
- **Seamless Updates**: Automatically syncs the latest Nix-compiled engine (including shaders and resource files) to the game directory on each launch.
- **Desktop Integration**: Automatically generates `.desktop` menu entries with icons.
- **Multi-Version Support**: Provides separate configurations for master (III), miami (VC), and lcs branches.

## 🛠️ Installation

Add this wrapper to your system `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Add this wrapper
    re3-flake.url = "github:gujial/re3-flake";
  };

  outputs = { self, nixpkgs, re3-wrapper, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            # Choose the games you want to install
            re3-flake.packages.${pkgs.system}.re3
            re3-flake.packages.${pkgs.system}.reVC
            re3-flake.packages.${pkgs.system}.reLCS
          ];
        })
      ];
    };
  };
}
```

## 🚀 First-Time Usage

### 1. Default Steam Path
If you have the Steam version installed in the default location, the wrapper will automatically detect:
- **re3**: `$HOME/.steam/steam/steamapps/common/Grand Theft Auto 3`
- **reVC**: `$HOME/.steam/steam/steamapps/common/Grand Theft Auto Vice City`

### 2. Non-Standard Path (or Non-Steam Version)
If your original game files are in a different location, or you're trying to run **reLCS** which doesn't have a Steam version, use environment variables:

```bash
# Example: Specify the resource path when running reVC for the first time
export STEAM_GAME_DIR="/path/to/your/GTA_VC_Files"
reVC
```
After the initial copy is complete, you can launch directly afterwards.

## 📁 Working Directory
To maintain the purity of the Nix Store while allowing game saves, the games run in your home directory:
- **GTA III**: `~/.re3/`
- **Vice City**: `~/.reVC/`
- **LCS**: `~/.reLCS/`

**Note**: If you want to modify settings or install mods, go to the directories above. The wrapper will overwrite the engine binary and system resources on each launch, but won't delete your saves or custom files.

## 🔧 Development & Build Logic

The wrapper follows this execution logic:
1. **Check**: Whether the target directory (e.g., `~/.reVC`) exists.
2. **Initialize** (first time only): Copy large assets (`.img`, `.dir`, `.mp3`) from the source path.
3. **Sync**: Force overwrite the latest `re3/reVC` binaries and shader/template files from the `share` directory in the Nix Store.
4. **Launch**: Enter the target directory and execute.

## 📄 Command-Line Arguments
This wrapper script supports all original `re3` program command-line arguments. For example:
```bash
reVC -windowed
```

--- 

### Contributing & Support
If you encounter missing icons or path matching errors, please submit an Issue.