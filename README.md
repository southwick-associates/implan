
# implan

A Southwick-only R package to streamline the process of working with Implan. It helps with:

1. Converting spending estimates to spending by implan sector
2. Writing excel worksheets (Industry/Commercial) to be imported as Implan activities
3. Synthesizing Implan output (csv) into a table of economic contribution results

## Installation

```r
install.packages("remotes")
remotes::install_github("southwick-associates/implan")
```

## Usage

See the vignettes:

- Preparing for Implan import & export
- Updating to a new sectoring scheme 
- Writing multiple results to one Excel workbook

```r
library(implan)

# for updating implan sectoring schemes & allocating spending
?sector_update()

# for preparing implan Excel input
?input_prep()
?xlsx_write_implan()
# then manually save as .xls

# for synthesizing implan csv output
?csv_read_implan()
```

## Package Development

See the [R packages](http://r-pkgs.had.co.nz/) book for instructions on package development. The software environment was specified using package [renv](https://rstudio.github.io/renv/index.html) which makes use of `.Rprofile` and `renv` files. You can use `renv::restore()` to set the project library.
