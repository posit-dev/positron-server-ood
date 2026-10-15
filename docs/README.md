# Documentation

The site is a [Quarto](https://quarto.org/) website. GitHub Actions renders it
on every push to `main` and publishes it to GitHub Pages.

The Posit brand in `_brand/` comes from
[posit-dev/posit-brand](https://github.com/posit-dev/posit-brand). Quarto
applies it to the site and the PDF. To update it, run
`quarto use brand posit-dev/posit-brand` in this directory.

## Build the site

```bash
cd docs
quarto render
```

The site is written to `docs/_site/`.

## Build a single PDF

```bash
cd docs
./build-pdf.sh
```

The script joins the pages into one document and renders it with Typst,
which Quarto bundles, so no LaTeX install is needed. The PDF is written to
`docs/Positron-Server-on-Open-OnDemand.pdf`.

`fonts/` holds static Open Sans and Source Code Pro faces for the PDF. Typst
uses one weight of the variable font files that the brand ships, which loses
bold text and makes code extra light.

## Update the Positron Server version

Edit `_variables.yml`. The version and the two download URLs are used on
every page that mentions them.
