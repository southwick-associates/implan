
<!-- write-excel.md is generated from write-excel.Rmd. Please edit that file -->

## Overview

The implan package includes convenience functions for writing to Excel.
This can be helpful for packaging multiple results (e.g., spending
profiles) into a single file for easily sharing with colleagues. It uses
[package openxlsx](https://ycphs.github.io/openxlsx/index.html).

### Initializing a Workbook

The first step is to create an Excel workbook using
`xlsx_initialize_workbook()`. This makes an Excel file with a single
“README” tab. I recommend always including a README for documentation
(to be edited manually in Excel).

``` r
library(dplyr)
library(implan)

xlsx_initialize_workbook("tmp.xlsx")
openxlsx::getSheetNames("tmp.xlsx")
#> [1] "README"
```

### Adding Results

R data frames can be written directly to an Excel file with
`xlsx_write_table()`:

``` r
# use sample data from implan package
data(spending)
head(spending, 2)
#> # A tibble: 2 x 3
#>   type  item      spend
#>   <chr> <chr>     <dbl>
#> 1 trip  food  14824024.
#> 2 trip  lodge  3589912.

xlsx_write_table(spending, "spending", "tmp.xlsx")
openxlsx::getSheetNames("tmp.xlsx")
#> [1] "README"   "spending"
```

### Updating Results

Additional calls to `xlsx_write_table()` will simply overwrite tabs with
the same name, so you can easily update results. This does imply that
you shouldn’t manually edit the Excel file (other than the README tab).

``` r
# update "spending" to show by category
data(categories) 
left_join(spending, categories, by = c("type", "item")) %>%
    mutate(spend = spend * share) %>%
    xlsx_write_table("spending", "tmp.xlsx")

openxlsx::readWorkbook("tmp.xlsx", "spending") %>% head(2)
#>   type item   spend          category share
#> 1 trip food 7412012 Food - Restaurant   0.5
#> 2 trip food 7412012  Food - Groceries   0.5
```
