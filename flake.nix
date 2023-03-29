{
  description = "Typst playground";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    typst.url = "github:typst/typst";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # External documents
    typst-templates = {
      url = "github:typst/templates";
      flake = false;
    };

    sahasatvik-typst-theorems = {
      url = "github:sahasatvik/typst-theorems";
      flake = false;
    };

    GeorgeHoneywood-alta-typst = {
      url = "github:GeorgeHoneywood/alta-typst";
      flake = false;
    };

    andreasKroepelin-typst-slides = {
      url = "github:andreasKroepelin/typst-slides";
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

        typst-external-sources = [
          {
            name = "typst-templates";
            filename = "ams/main";
          }
          {
            name = "typst-templates";
            filename = "dept-news/main";
          }
          {
            name = "typst-templates";
            filename = "fiction/main";
          }
          {
            name = "typst-templates";
            filename = "ieee/main";
          }
          {
            name = "typst-templates";
            filename = "letter/main";
          }
          {
            name = "sahasatvik-typst-theorems";
            filename = "example";
          }
          {
            name = "sahasatvik-typst-theorems";
            filename = "differential_calculus";
          }
          {
            name = "GeorgeHoneywood-alta-typst";
            filename = "example";
          }
          {
            name = "andreasKroepelin-typst-slides";
            filename = "examples/simple";
          }
          {
            name = "andreasKroepelin-typst-slides";
            filename = "examples/doc";
          }
          {
            name = "andreasKroepelin-typst-slides";
            filename = "examples/gauss";
          }
        ];

        typst = let
          fontsConf = pkgs.symlinkJoin {
            name = "typst-fonts";
            paths = [
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

        typst-documents = builtins.listToAttrs (map (source: let
            outputFilename = builtins.replaceStrings ["/"] ["-"] source.filename;
          in {
            name = "${source.name}-${outputFilename}";
            value = pkgs.stdenvNoCC.mkDerivation {
              name = "typst-${source.name}";

              src = inputs."${source.name}";

              buildPhase = ''
                runHook preBuild

                ${typst}/bin/typst \
                  --root $src/ \
                  $src/${source.filename}.typ \
                  ${source.name}-${outputFilename}.pdf

                runHook postBuild
              '';

              installPhase = ''
                runHook preInstall
                install -m644 -D ${source.name}-${outputFilename}.pdf --target $out/
                runHook postInstall
              '';
            };
          })
          typst-external-sources);
      in {
        formatter = pkgs.alejandra;

        packages = typst-documents;

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "typst-devshell";

          buildInputs = [
            typst
          ];
        };
      };
    };
}
