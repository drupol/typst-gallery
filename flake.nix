{
  description = "Typst playground";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    typst.url = "github:typst/typst";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        lib,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          overlays = [inputs.typst.overlays.default];
          inherit system;
        };

        typst = let
          fontsConf = pkgs.symlinkJoin {
            name = "typst-fonts";
            paths = [
              pkgs.eb-garamond
              pkgs.dejavu_fonts
              pkgs.lmodern
              pkgs.garamond-libre
              pkgs.fira
              pkgs.liberation_ttf
              pkgs.texlive.newcomputermodern.pkgs
              ./fonts
            ];
          };
        in
          pkgs.writeShellApplication {
            name = "typst";
            text = ''
              ${pkgs.typst-dev}/bin/typst \
              --font-path ${fontsConf} \
              "$@"
            '';
            runtimeInputs = [];
          };

        documents = lib.attrNames (lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./src));

        typst-documents =
          lib.genAttrs
          documents
          (
            document:
              pkgs.stdenvNoCC.mkDerivation {
                name = "typst-${document}";

                src = pkgs.lib.cleanSource ./.;

                buildPhase = ''
                  runHook preBuild

                  ${typst}/bin/typst \
                    --root $src/src/${document}/ \
                    $src/src/${document}/main.typ \
                    ${document}.pdf

                  runHook postBuild
                '';

                installPhase = ''
                  runHook preInstall
                  install -m644 -D *.pdf --target $out/
                  runHook postInstall
                '';
              }
          );

        watch-typst-documents-list =
          map
          (
            document:
              pkgs.writeShellApplication {
                name = "watch-typst-${document}";
                text = ''
                  ${typst}/bin/typst \
                    --root src/ \
                    -w \
                    src/${document}/main.typ \
                    build/${document}.pdf
                '';
              }
          )
          documents;
      in {
        formatter = pkgs.alejandra;

        apps = builtins.listToAttrs (map (document: {
            name = document.name;
            value = {
              type = "app";
              program = document;
            };
          })
          watch-typst-documents-list);

        packages = typst-documents;

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "typst-devshell";

          buildInputs =
            [
              typst
            ]
            ++ watch-typst-documents-list;
        };
      };
    };
}
