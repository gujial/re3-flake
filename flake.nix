{
  description = "Flake for building re3 from different branches using local repo with official Linux instructions and auto-arch detection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      buildRe3FromBranch =
        branch:
        pkgs.stdenv.mkDerivation rec {
          pname = "re3-${branch}";
          version = "1.0.0";

          # 直接使用仓库根目录为源码
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
            # 复制整个仓库到可写目录
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
            cp ../bin/linux-amd64-librw_gl3_glfw-oal/Release/re3 $out/bin/
          '';

          meta = with pkgs.lib; {
            description = "Re3 branch ${branch} built using local repo with Premake and auto-arch detection";
            license = licenses.mit;
          };
        };
    in
    {
      packages.x86_64-linux = {
        re3-3 = buildRe3FromBranch "master";
        re3-vc = buildRe3FromBranch "miami";
        re3-lcs = buildRe3FromBranch "lcs";
      };
    };
}
