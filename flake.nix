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

    johanvx-typst-undergradmath = {
      url = "github:johanvx/typst-undergradmath";
      flake = false;
    };

    Leedehai-typst-physics = {
      url = "github:Leedehai/typst-physics";
      flake = false;
    };

    johannes-wolf-typst-plot = {
      url = "github:johannes-wolf/typst-plot";
      flake = false;
    };

    pncnmnp-typst-poster = {
      url = "github:pncnmnp/typst-poster";
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

        sources = builtins.fromJSON (builtins.readFile ./sources.json);

        typst-external-sources =
          builtins.foldl'
          (carry: current:
            carry
            ++
            (map
              (document: {
                name = current.name;
                filename = document;
              })
            current.documents
            )
          )
          []
          sources.sources;

        typst-documents = builtins.listToAttrs (map (source: let
            outputFilename = builtins.replaceStrings ["/"] ["-"] source.filename;
          in {
            name = "${source.name}-${outputFilename}";
            value = pkgs.stdenvNoCC.mkDerivation {
              name = "package-${source.name}";

              src = inputs."${source.name}";

              buildPhase = ''
                runHook preBuild

                ${typst}/bin/typst \
                  --root $src/ \
                  compile
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
