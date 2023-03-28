# Typst document

This project will build the default [Typst][typst] templates from https://github.com/typst/templates using [Nix][nix].

## Usage

1. Clone the repository

```shell
git clone https://github.com/drupol/typst-document
cd typst-document
```

2. Build example templates

```shell
nix build .#ams
nix build .#dept-news
nix build .#fiction
nix build .#ieee
nix build .#letter

open result/ams.pdf
open result/dept-news.pdf
open result/fiction.pdf
open result/ieee.pdf
open result/letter.pdf
```

3. Watch the document and recompile on changes

```shell
nix run .#watch-typst-ams
nix run .#watch-typst-dept-news
nix run .#watch-typst-fiction
nix run .#watch-typst-ieee
nix run .#watch-typst-letter
```

Then open the resulting PDF file in the `build` directory with your favorite viewer.

## Font management

Add custom fonts in the `fonts/` directory.

To check what are the available fonts, execute `nix develop` then run `typst --fonts`

[typst]: https://typst.app/
[nix]: https://nixos.org/
