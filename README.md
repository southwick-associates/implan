
# implan

A Southwick-only R package to streamline Implan work, also providing functions for writing results to Excel worksheets.

## Installation

From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/implan")
```

## Usage

See the vignettes:

- [Implan preparation, import, and export](github-vignettes/implan-transfer.md)
- [Writing multiple results to one Excel workbook](github-vignettes/write-excel.md)
- [Updating to a new Implan sectoring scheme](github-vignettes/sector-update.md)

## Development

See the [R packages book](http://r-pkgs.had.co.nz/) for a guide to package development. The software environment was specified using [package renv](https://rstudio.github.io/renv/index.html). Use `renv::restore()` to build the project library.
