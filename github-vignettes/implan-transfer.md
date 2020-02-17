
<!-- implan-transfer.md is generated from implan-transfer.Rmd. Please edit that file -->

## Overview

The implan package streamlines several steps otherwise done in Excel:

1.  [Allocate spending by Implan sector](#implan-sector-allocation)
2.  [Write Excel tabs for Implan import](#write-to-excel)
3.  [Pull all Implan output (csv) into one table](#read-from-implan)

### Elevator Pitch

R code can be easily scaled up/down or ported to a new project without
the manual restructuring needed in Excel. It also facilitates automated
checks/summaries. You can see an example in the wild for B4W:
[implan-input](https://github.com/southwick-associates/B4W-19-01/blob/master/code/implan/1-implan-input.R),
[contributions](https://github.com/southwick-associates/B4W-19-01/blob/master/code/implan/2-contributions.R)

I’ve also included template files from the Excel approach in this
package (details in [the last section](#excel-approach)).

## Implan Sector Allocation

Allocating spending to Implan sectors requires a spending table and 2
crosswalk tables. The implan package includes example data to
demonstrate the allocation process:

``` r
library(dplyr)
library(implan)

data(spending) # total hunting spending by item
spending
#> # A tibble: 44 x 3
#>    type  item          spend
#>    <chr> <chr>         <dbl>
#>  1 trip  food      14824024.
#>  2 trip  lodge      3589912.
#>  3 trip  plane       703034.
#>  4 trip  pubtrans    438757.
#>  5 trip  privtrans 17689308.
#>  6 trip  guide      3893594.
#>  7 trip  publand     109853.
#>  8 trip  privland  10726392.
#>  9 trip  heat        610683.
#> 10 trip  rent       1209743.
#> # ... with 34 more rows
```

### Item to Category

Spending must first be reallocated from the item level (e.g., from
survey data) to the category level (e.g., “Food - Groceries”, etc.).
Spending in the sample data is specified by 2 dimensions (`type`,
`item`) for which `share` in the crosswalk table must sum to 100%:

``` r
data(item_to_category)
head(item_to_category, 2)
#> # A tibble: 2 x 4
#>   type  item  category          share
#>   <chr> <chr> <chr>             <dbl>
#> 1 trip  food  Food - Restaurant   0.5
#> 2 trip  food  Food - Groceries    0.5

# check the share variable - should print "TRUE"
check_share_sums(df = item_to_category, sharevar = share, type, item)
#> [1] TRUE
```

Allocating is a simple matter of joining with the crosswalk table and
multiplying:

``` r
spend_category <- spending %>%
    left_join(item_to_category, by = c("type", "item")) %>%
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

### Category to Sector

In the same way, allocating to sectors uses a crosswalk at the
`category` dimension (also referred to as implan sectoring schemes):

``` r
data(category_to_sector546)
head(category_to_sector546, 2)
#> # A tibble: 2 x 6
#>   group category sector description                       share retail
#>   <chr> <chr>     <dbl> <chr>                             <dbl> <chr> 
#> 1 Comm  Ammo       3255 Small arms ammunition             0.325 Yes   
#> 2 Comm  Ammo       3256 Ammunition, except for small arms 0.675 Yes

check_share_sums(category_to_sector546, sharevar = share, category)
#> [1] TRUE

spend_sector <- spend_category %>%
    left_join(category_to_sector546, by = "category") %>%
    mutate(spend = spend * share)

check_spend_sums(df_old = spend_category, df_new = spend_sector, spendvar = spend, category)
#> [1] TRUE
```

## Write to Excel

To prepare for implan import, we first convert spending by sector to the
necessary Industry/Commodity format. Each destination Excel tab requires
2 tables (header & data):

``` r
ind <- input_prep_ind(spend_sector, "huntInd")
comm <- input_prep_comm(spend_sector, "huntComm")

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

## Read from Implan

From Implan, you’ll need to save output results into csv files, where
each Implan activity should have its own folder of results. Two example
activities are included in this package:

``` r
output_dir <- system.file("extdata", "output", package = "implan", mustWork = TRUE)
list.files(output_dir)
#> [1] "bike" "hunt"
```

Typically, you’ll want 5 sets of results per activity:

``` r
hunt_dir <- file.path(output_dir, "hunt")
list.files(hunt_dir)
#> [1] "B4W_ColoradoModelFedDirect.csv"   "B4W_ColoradoModelFedTotal.csv"   
#> [3] "B4W_ColoradoModelStateDirect.csv" "B4W_ColoradoModelStateTotal.csv" 
#> [5] "B4W_ColoradoModelSummary.csv"
```

### Get CSV Files

The `output_read_csv()` function pulls all csv files for an activity
into an R list, with one data frame per input file. The names of the
list correspond to a title row that Implan includes in the output csv
files:

``` r
dat <- output_read_csv(hunt_dir)
names(dat)
#> [1] "federal tax impact by direct"        
#> [2] "federal tax impact by total"         
#> [3] "state and local tax impact by direct"
#> [4] "state and local tax impact by total" 
#> [5] "impact summary"
```

You can then combine these results into a single summary table with
`output_combine()`:

``` r
output_combine(dat)
#> # A tibble: 4 x 7
#>   ImpactType    Employment LaborIncome TotalValueAdded   Output  FedTax LocalTax
#>   <chr>              <dbl>       <dbl>           <dbl>    <dbl>   <dbl>    <dbl>
#> 1 Direct Effect      1694.   51488607.       77127905.   1.48e8  1.10e7  9377690
#> 2 Indirect Eff~       351.   22577739.       34465045.   6.75e7 NA            NA
#> 3 Induced Effe~       425.   21478274.       39058082.   6.75e7 NA            NA
#> 4 Total Effect       2469.   95544620.      150651032.   2.83e8  2.04e7 15554404
```

It’s easy to scale-up this operation using a for loop (or `sapply`):

``` r
impacts <- list()
for (i in c("bike", "hunt")) {
  impacts[[i]] <- output_read_csv(file.path(output_dir, i)) %>% 
    output_combine() %>% 
    mutate(activity = i)
}
bind_rows(impacts)
#> # A tibble: 8 x 8
#>   ImpactType Employment LaborIncome TotalValueAdded Output  FedTax LocalTax
#>   <chr>           <dbl>       <dbl>           <dbl>  <dbl>   <dbl>    <dbl>
#> 1 Direct Ef~      2893.  113060079.      185259583. 3.41e8  2.61e7 31961988
#> 2 Indirect ~       808.   54793181.       82309563. 1.60e8 NA            NA
#> 3 Induced E~       962.   48677587.       88529239. 1.53e8 NA            NA
#> 4 Total Eff~      4663.  216530848.      356098385. 6.54e8  4.81e7 46878467
#> 5 Direct Ef~      1694.   51488607.       77127905. 1.48e8  1.10e7  9377690
#> 6 Indirect ~       351.   22577739.       34465045. 6.75e7 NA            NA
#> 7 Induced E~       425.   21478274.       39058082. 6.75e7 NA            NA
#> 8 Total Eff~      2469.   95544620.      150651032. 2.83e8  2.04e7 15554404
#> # ... with 1 more variable: activity <chr>
```

## Excel Approach

The Excel approach combines steps 1 & 2 into an Excel workbook. I
included a basic example (for wildlife watching) in this package:

``` r
filepath <- system.file(
  "extdata", "templates", "fhwar-implan-import.xls", package = "implan", mustWork = TRUE
)
file.copy(filepath, "tmp.xls") # copy to your working directory
#> [1] TRUE
```

Step 3 can be accomplished by copy/pasting implan results into an Excel
sheet and running embedded macros:

``` r
filepath <- system.file(
  "extdata", "templates", "implan-output.xlsm", package = "implan", mustWork = TRUE
)
file.copy(filepath, "tmp.xlsm") # copy to your working directory
#> [1] TRUE
```
