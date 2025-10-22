{
  description = "Flake for building multiple re3 branches with branch-specific metadata";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      # 构建单个分支的函数：直接返回 derivation，接受描述字符串
      buildRe3 =
        branch: desc:
        pkgs.stdenv.mkDerivation rec {
          pname = "re3-${branch}";
          version = "1.0.0";

          src = pkgs.fetchFromGitHub {
            owner = "gujial";
            repo = "re3-flake";
            rev = "refs/heads/${branch}";
            sha256 = "WCvs5QGkfnj33yu26LdSVTtwhuLyB3NhkT1i1nirvCk=";
            fetchSubmodules = true;
          };

          nativeBuildInputs = [
            pkgs.premake5
            pkgs.gcc
            pkgs.gnumake
            pkgs.libx11
            pkgs.libGL
            pkgs.openal
            pkgs.glew
            pkgs.glfw
            pkgs.libsndfile
            pkgs.libmpg123
          ];

          buildPhase = ''
            cp -r $src/* $PWD/
            cd $PWD
            substituteInPlace printHash.sh --replace-warn '#!/usr/bin/env sh' '#!${pkgs.bash}/bin/bash'

            echo "Running premake5 gmake2..."
            premake5 gmake2 --with-librw

            cd build
            config="release_linux-amd64-librw_gl3_glfw-oal"
            echo "Building $config..."
            make config=$config
          '';

          installPhase = ''
                      mkdir -p $out/bin
                      cp ../bin/linux-amd64-librw_gl3_glfw-oal/Release/re3 $out/bin/re3-${branch}
                      cp ../res/images/logo.svg $out/bin/re3-${branch}-icon.svg

                      cat > $out/bin/re3-${branch}.desktop <<EOF
            [Desktop Entry]
            Name=Re3 (${branch})
            Exec=$out/bin/re3-${branch}
            Icon=re3-${branch}-icon
            Type=Application
            Categories=Game;Emulator;
            Terminal=false
            EOF
          '';

          meta = with pkgs.lib; {
            description =
              if desc == null then
                "Re3 branch ${branch} built with Premake, OpenAL, and auto-arch detection."
              else
                desc;
            license = licenses.mit;
            maintainers = with maintainers; [ gujial ];
            platforms = platforms.linux;
          };
        };

    in
    {
      packages.x86_64-linux = {
        re3-master = buildRe3 "master" "Re3 master branch: the mainline GTA III engine port.";
        re3-vc = buildRe3 "miami" "Re3 Miami (VC) branch: GTA Vice City engine port.";
        re3-lcs = buildRe3 "lcs" "Re3 LCS branch: GTA Liberty City Stories engine port.";
      };
    };
}
