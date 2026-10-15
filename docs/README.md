# Documentation

The site is a [Quarto](https://quarto.org/) website. GitHub Actions renders it
on every push to `main` and publishes it to GitHub Pages.

## Build the site

```bash
cd docs
quarto render
```

The site is written to `docs/_site/`.

## Build a single PDF

The `pdf` profile renders the same pages as one book:

```bash
cd docs
quarto render --profile pdf --to pdf
```

The PDF is written to `docs/_book/Positron-Server-on-Open-OnDemand.pdf`.
The PDF build needs a LaTeX install. If you do not have one, run
`quarto install tinytex` once.

## Update the Positron Server version

Edit `_variables.yml`. The version and the two download URLs are used on
every page that mentions them.
