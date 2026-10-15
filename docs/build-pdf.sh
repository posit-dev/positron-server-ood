#!/usr/bin/env bash
# Builds one branded PDF from the site pages. The pages are concatenated
# into pdf.qmd because Quarto's include shortcode does not expand the
# {{< var >}} shortcodes inside included files.
set -euo pipefail
cd "$(dirname "$0")"

pages=(index.qmd get_started.qmd configuration.qmd troubleshooting.qmd test_checklist.qmd)

# Quarto does not expand {{< var >}} in a file that the project excludes
# from the site, so substitute the three variables here.
var() { sed -n "s/^  $1: \"\(.*\)\"$/\1/p" _variables.yml; }
version=$(var version); url_x64=$(var url-x64); url_arm64=$(var url-arm64)

{
  cat <<'HEADER'
---
title: "Positron Server on Open OnDemand"
subtitle: "Install, configure, and test the positron-server-ood app"
author: "Posit, PBC"
date: today
format:
  typst:
    # Static faces. Typst picks one instance of the variable fonts the brand
    # ships, so bold text and regular-weight code need these.
    font-paths: [fonts]
    toc: true
    toc-depth: 2
    number-sections: true
    output-file: "Positron-Server-on-Open-OnDemand.pdf"
---
HEADER
  for page in "${pages[@]}"; do
    title=$(sed -n 's/^title: "\(.*\)"$/\1/p' "$page" | head -1)
    printf '\n# %s\n\n' "$title"
    # Drop the front matter, then turn links to other pages into links
    # within this document.
    awk 'NR == 1 && /^---$/ { fm = 1; next } fm == 1 { if (/^---$/) fm = 2; next } { print }' "$page" \
      | sed -E 's/\(([a-z_]+)\.qmd#/(#/g' \
      | sed -E 's/\(index\.qmd\)/(#positron-server-ood)/g; s/\(get_started\.qmd\)/(#get-started)/g; s/\(configuration\.qmd\)/(#configuration)/g; s/\(troubleshooting\.qmd\)/(#troubleshooting)/g; s/\(test_checklist\.qmd\)/(#test-checklist)/g' \
      | sed -e "s|{{< var positron.version >}}|$version|g" -e "s|{{< var positron.url-x64 >}}|$url_x64|g" -e "s|{{< var positron.url-arm64 >}}|$url_arm64|g"
  done
} > pdf.qmd

quarto render pdf.qmd --to typst
echo "Wrote $(pwd)/Positron-Server-on-Open-OnDemand.pdf"
