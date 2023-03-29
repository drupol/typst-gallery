# Typst document

This project will build the default [Typst][typst] templates from https://github.com/typst/templates using [Nix][nix].

## Usage

### To list all the available documents

```
nix flake show
```

### To build a document

```shell
nix build .#<name>
```

Where you replace the placeholder `<name>` with the name of the package from `nix flake show`.

[typst]: https://typst.app/
[nix]: https://nixos.org/
