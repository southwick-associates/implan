
<!-- implan-transfer.md is generated from implan-transfer.Rmd. Please edit that file -->

## Overview

The implan package streamlines the steps otherwise done in Excel:

1.  [Allocate spending by Implan sector](#implan-sector-allocation)
2.  [Write Excel tabs for Implan import](#write-to-excel)
3.  [Pull all Implan output (csv) into one table](#read-from-csv)

### Elevator Pitch

R code can be easily scaled up/down or ported to a new project without
the manual restructuring needed in Excel. It’s also less error-prone and
facilitates automated checks/summaries.

## Implan Sector Allocation

Allocating spending to Implan sectors requires 1 or more crosswalk
tables. The implan package includes example data to demonstrate the
allocation process. You can use `read_excel` from the [readxl
package](https://readxl.tidyverse.org/) for data stored in Excel.

``` r
library(dplyr)
library(implan)

data(spending) # total hunting spending by item
head(spending, 2)
#> # A tibble: 2 x 3
#>   type  item      spend
#>   <chr> <chr>     <dbl>
#> 1 trip  food  14824024.
#> 2 trip  lodge  3589912.
```

### Categories

For the sample data, spending must first be reallocated from the “item”
level to the “category” level. Spending is specified by 2 dimensions
(`type`, `item`) for which `share` must sum to 100%:

``` r
data(categories) # item-category crosswalk
head(categories, 2)
#> # A tibble: 2 x 4
#>   type  item  category          share
#>   <chr> <chr> <chr>             <dbl>
#> 1 trip  food  Food - Restaurant   0.5
#> 2 trip  food  Food - Groceries    0.5

# check the share variable - should print "TRUE"
check_share_sums(df = categories, sharevar = share, type, item)
#> [1] TRUE
```

Allocating is a simple matter of joining with the crosswalk table and
multiplying:

``` r
spend_category <- spending %>%
    left_join(categories, by = c("type", "item")) %>%
    mutate(spend = spend * share) %>%
    select(-share) # no longer needed

head(spend_category, 2)
#> # A tibble: 2 x 4
#>   type  item     spend category         
#>   <chr> <chr>    <dbl> <chr>            
#> 1 trip  food  7412012. Food - Restaurant
#> 2 trip  food  7412012. Food - Groceries

# check the spending allocation - should print "TRUE"
check_spend_sums(df_old = spending, df_new = spend_category, spendvar = spend, type, item)
#> [1] TRUE
```

### Sectors

In the same way, allocating to sectors uses a sectoring scheme crosswalk
(at the `category` dimension):

``` r
data(sector_scheme546) # category-sector crosswalk
head(sector_scheme546, 2)
#> # A tibble: 2 x 6
#>   group category sector description                       share retail
#>   <chr> <chr>     <dbl> <chr>                             <dbl> <chr> 
#> 1 Comm  Ammo       3255 Small arms ammunition             0.325 Yes   
#> 2 Comm  Ammo       3256 Ammunition, except for small arms 0.675 Yes

check_share_sums(sector_scheme546, sharevar = share, category)
#> [1] TRUE

spend_sector <- spend_category %>%
    left_join(sector_scheme546, by = "category") %>%
    mutate(spend = spend * share)

check_spend_sums(df_old = spend_category, df_new = spend_sector, spendvar = spend, category)
#> [1] TRUE
```

## Write to Excel

A preparation step is needed to convert spending by sector to the
Industry/Commercial format that the Implan import requires:

``` r
ind <- input_prep_ind(spend_sector, "huntInd")
comm <- input_prep_comm(spend_sector, "huntComm")

# 2 tables are needed for each Excel tab
comm$header
#> # A tibble: 1 x 4
#>   `Activity Type`  `Activity Name` `Activity Level` `Activity Year`
#>   <chr>            <chr>                      <dbl>           <dbl>
#> 1 Commodity Change huntComm                       1            2019

head(comm$dat, 2)
#> # A tibble: 2 x 5
#>   Sector `Event Value` EventYear Retail `Local Direct Purchase`
#>    <dbl>         <dbl>     <dbl> <chr>                    <dbl>
#> 1   3002        11214.      2019 Yes                          1
#> 2   3003       136677.      2019 Yes                          1
```

After prepartion, the data can be written to Excel with
`xlsx_write_implan()`. Note that you’ll need to open the `.xlsx` file
and save as `.xls` prior to Implan import.

``` r
xlsx_write_implan(comm, "tmp.xlsx")
xlsx_write_implan(ind, "tmp.xlsx")

openxlsx::getSheetNames("tmp.xlsx")
#> [1] "README"   "huntComm" "huntInd"
```

It’s also easy to create tabs at whatever dimension is required for the
project:

``` r
for (i in c("trip", "equip")) {
    x <- filter(spend_sector, type == i)
    input_prep_ind(x, paste0(i, "Ind")) %>% xlsx_write_implan("tmp2.xlsx")
    input_prep_comm(x, paste0(i, "Comm")) %>% xlsx_write_implan("tmp2.xlsx")
}
openxlsx::getSheetNames("tmp2.xlsx")
#> [1] "README"    "tripInd"   "tripComm"  "equipInd"  "equipComm"
```

## Read from CSV
