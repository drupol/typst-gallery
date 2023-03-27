{
  description = "Typst playground";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    typst.url = "github:typst/typst";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        typst = let
          fontsConf = pkgs.symlinkJoin {
            name = "typst-fonts";
            paths = [
              pkgs.eb-garamond
              pkgs.dejavu_fonts
              pkgs.lmodern
              pkgs.garamond-libre
              pkgs.fira
              ./fonts
            ];
          };
        in
          pkgs.writeShellApplication {
            name = "typst";
            text = ''
              ${inputs.typst.packages.${system}.default}/bin/typst \
              --font-path ${fontsConf} \
              "$@"
            '';
            runtimeInputs = [];
          };

        typst-document = pkgs.stdenvNoCC.mkDerivation {
          name = "typst-document";

          src = pkgs.lib.cleanSource ./.;

          buildPhase = ''
            runHook preBuild

            ${typst}/bin/typst \
              --root $src/src/ \
              $src/src/main.typ \
              document.pdf

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -m644 -D *.pdf --target $out/
            runHook postInstall
          '';
        };

        watch-typst-document = pkgs.writeShellApplication {
          name = "watch-typst-document";
          text = ''
            ${typst}/bin/typst \
              --root src/ \
              -w \
              src/main.typ \
              build/document.pdf
          '';
        };
      in {
        formatter = pkgs.alejandra;

        apps.watch = {
          type = "app";
          program = watch-typst-document;
        };

        packages.default = typst-document;

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "typst-devshell";

          buildInputs = [
            typst
            watch-typst-document
          ];
        };
      };
    };
}
