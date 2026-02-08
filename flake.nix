{
  description = "Launcher wrapper for re3 (GTA III, VC, LCS) with Desktop entries";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    re3-master-repo.url = "github:gujial/re3/master"; 
    re3-miami-repo.url  = "github:gujial/re3/miami";
    re3-lcs-repo.url    = "github:gujial/re3/lcs";
    re3-miami-improved-repo.url = "github:gujial/re3/miami-improve";
  };

  outputs = { self, nixpkgs, re3-master-repo, re3-miami-repo, re3-lcs-repo, re3-miami-improved-repo, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system (import nixpkgs { inherit system; }));

      mkLauncher = pkgs: { gamePkg, program, steamDirName, dataDir, displayName }: 
        let
          # 1. 先创建包装脚本
          wrapperScript = pkgs.writeShellScript "${program}-wrapper" ''
            set -e
            TARGET_DIR="$HOME/${dataDir}"
            
            if [ ! -d "$TARGET_DIR" ]; then
              echo "--- 正在初始化 ${displayName} 原始文件 ---"
              DEFAULT_STEAM_PATH="$HOME/.steam/steam/steamapps/common/${steamDirName}"
              SOURCE_PATH="''${STEAM_GAME_DIR:-$DEFAULT_STEAM_PATH}"

              if [ -d "$SOURCE_PATH" ]; then
                mkdir -p "$TARGET_DIR"
                cp -rn "$SOURCE_PATH"/* "$TARGET_DIR/"
                chmod -R u+w "$TARGET_DIR"
              else
                echo "错误: 找不到原始游戏目录！"
                exit 1
              fi
            fi

            echo "--- 同步引擎与资源 ---"
            cp -f "${gamePkg}/bin/${program}" "$TARGET_DIR/"
            if [ -d "${gamePkg}/share/${program}" ]; then
              cp -rf "${gamePkg}/share/${program}"/* "$TARGET_DIR/"
            fi

            chmod -R u+w "$TARGET_DIR"
            cd "$TARGET_DIR"
            exec "./${program}" "$@"
          '';
        in
        # 2. 封装成一个完整的 Derivation
        pkgs.stdenv.mkDerivation {
          pname = "${program}-wrapped";
          version = gamePkg.version or "1.0.0";

          # 无需源码，直接在 installPhase 处理
          phases = [ "installPhase" ];

          installPhase = ''
            mkdir -p $out/bin $out/share/applications $out/share/icons

            # 复制包装脚本
            cp ${wrapperScript} $out/bin/${program}
            chmod +x $out/bin/${program}

            # 从原始包中复制图标 (源 Flake 已将图标放在 share/icons)
            if [ -d "${gamePkg}/share/icons" ]; then
              cp -r ${gamePkg}/share/icons $out/share/
            fi

            # 创建桌面文件
            # 注意：Exec 指向我们这个包里的包装脚本
            # Icon 名字对应源 Flake 里定义的图标名 (通常是 re3, reVC 等)
            cat > $out/share/applications/${program}.desktop <<EOF
            [Desktop Entry]
            Name=${displayName}
            Exec=$out/bin/${program}
            Icon=${program}
            Type=Application
            Categories=Game;
            Terminal=false
            EOF
          '';
        };

    in
    {
      packages = forAllSystems (system: pkgs: {
        # GTA III
        re3 = mkLauncher pkgs {
          gamePkg = re3-master-repo.packages.${system}.default;
          program = "re3";
          displayName = "Grand Theft Auto III (re3)";
          steamDirName = "Grand Theft Auto 3";
          dataDir = ".re3";
        };

        # GTA Vice City
        reVC = mkLauncher pkgs {
          gamePkg = re3-miami-repo.packages.${system}.default; 
          program = "reVC";
          displayName = "Grand Theft Auto: Vice City (reVC)";
          steamDirName = "Grand Theft Auto Vice City"; 
          dataDir = ".reVC";
        };

        # GTA Liberty City Stories
        reLCS = mkLauncher pkgs {
          gamePkg = re3-lcs-repo.packages.${system}.default;
          program = "reLCS";
          displayName = "GTA: Liberty City Stories (reLCS)";
          steamDirName = "GTALCS_FIXME"; 
          dataDir = ".reLCS";
        };

        reVC-Improved = mkLauncher pkgs {
          gamePkg = re3-miami-improved-repo.packages.${system}.default;
          program = "reVC-Improved";
          displayName = "GTA: Vice City (reVC Improved)";
          steamDirName = "Grand Theft Auto Vice City"; 
          dataDir = ".reVC-Improved";
        };
      });
    };
}