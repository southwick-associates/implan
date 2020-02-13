
# implan

A Southwick-only R package that streamlines the process of working with Implan. It also provides some convenience functions for writing results to Excel worksheets.

## Installation

```r
install.packages("remotes")
remotes::install_github("southwick-associates/implan")
```

## Usage

See the vignettes:

- [Preparing for Implan import & export](github-vignettes/implan-transfer.md)
- [Updating to a new Implan sectoring scheme](github-vignettes/sector-update.md)
- [Writing multiple results to one Excel workbook](github-vignettes/write-excel.md)

## Package Development

See the [R packages](http://r-pkgs.had.co.nz/) book for instructions on package development. The software environment was specified using package [renv](https://rstudio.github.io/renv/index.html) which makes use of `.Rprofile` and `renv` files. You can use `renv::restore()` to set the project library.
