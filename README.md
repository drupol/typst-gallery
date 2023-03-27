# Typst document

## Usage

1. Clone the repository

```shell
git clone https://github.com/drupol/typst-document
cd typst-document
```

2. Modify the `src/main.typ` file

3. Build the document

```shell
nix build
open result/document.pdf
```

4. Watch the document and build incrementaly

```shell
nix run .#watch
```

Then open the resulting document with your favorite viewer: `open build/document.pdf`

## Font management

Add your custom font in the `fonts/` directory.

To check what are the available fonts, run `nix develop` then run `typst --fonts`