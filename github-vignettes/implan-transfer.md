
<!-- implan-transfer.md is generated from implan-transfer.Rmd. Please edit that file -->

# Overview

The implan package streamlines several steps otherwise done in Excel:

1.  [Prepare](#1-prepare-implan-sector-allocation): Allocate spending by
    Implan sector using crosswalks and validate using `implan::check`
    functions.
2.  [Input](#2-input-write-to-excel): Write Excel sheets for Implan
    import using `implan::input()`
3.  [Output](#3-output-read-from-implan): Pull Implan output (csv) into
    a table using `implan::output()`

### Elevator Pitch

R code can be easily scaled up/down or ported to a new project without
the manual restructuring needed in Excel. It also facilitates automated
checks/summaries. You can see a production example for B4W-19-01:
[implan-input](https://github.com/southwick-associates/B4W-19-01/blob/master/code/implan/1-implan-input.R),
[contributions](https://github.com/southwick-associates/B4W-19-01/blob/master/code/implan/2-contributions.R)

### Reference

There is an Office 365 group with useful files ([O365 \>
Implan](https://southwickassociatesinc.sharepoint.com/sites/Implan))
including master sectoring schemes (i.e., category to sector
crosswalks). I’ve also included template files from the Excel approach
in this package (details in [the last section](#excel-approach)).

## 1\. Prepare Implan Sector Allocation

Allocating spending to Implan sectors requires two crosswalk tables (
`item_to_category`, `category_to_sector`). The starting point is a table
of total spending estimates by activity-type-item:

``` r
library(dplyr)
library(implan)

data(spending) # spending by activity-type-item
spending
#> # A tibble: 212 x 5
#>    activity_group act    type  item           spend
#>    <chr>          <chr>  <chr> <chr>          <dbl>
#>  1 oia            picnic trip  food      297224986.
#>  2 oia            picnic trip  recreate  128068014.
#>  3 oia            picnic trip  souvenir   39766814.
#>  4 oia            picnic trip  transport 263321001.
#>  5 oia            bike   trip  entrance    8468958.
#>  6 oia            bike   trip  food      129033948.
#>  7 oia            bike   trip  lodge      37740741.
#>  8 oia            bike   trip  recreate   43518822.
#>  9 oia            bike   trip  souvenir   27497377.
#> 10 oia            bike   trip  transport  87046163.
#> # ... with 202 more rows
```

### Item to Category

Spending must first be reallocated from the item level (e.g., from
survey data) to the category level (e.g., “Food - Groceries”, etc.)
using an item-to-category crosswalk:

``` r
data(item_to_category)
head(item_to_category, 2)
#> # A tibble: 2 x 5
#>   activity_group type  item  category          share
#>   <chr>          <chr> <chr> <chr>             <dbl>
#> 1 oia            trip  food  Food - Restaurant 0.570
#> 2 oia            trip  food  Food - Groceries  0.43
```

Items in the example data mostly have a 1-to-1 correspondence with
categories, but several need to be split into multiple categories. The
crosswalk is specified by three dimensions (activity\_group, type, item)
across which share must sum to 100%. We can confirm this using
`check_share_sums()`:

``` r
# check the share variable - should print "TRUE"
check_share_sums(df = item_to_category, sharevar = share, activity_group, type, item)
#> [1] TRUE
```

Allocating is a simple matter of joining the spending and crosswalk
tables and then multiplying:

``` r
spend_category <- spending %>%
    left_join(item_to_category, by = c("activity_group", "type", "item")) %>%
    mutate(spend = spend * share) %>%
    select(-share) # no longer needed

head(spend_category, 2)
#> # A tibble: 2 x 6
#>   activity_group act    type  item       spend category         
#>   <chr>          <chr>  <chr> <chr>      <dbl> <chr>            
#> 1 oia            picnic trip  food  169418242. Food - Restaurant
#> 2 oia            picnic trip  food  127806744. Food - Groceries
```

We can use `check_spend_sums()` to confirm that expenditures still sum
to the correct quantities after we modify the data:

``` r
# check the spending allocation - should print "TRUE"
check_spend_sums(df_old = spending, df_new = spend_category, spendvar = spend, 
                 activity_group, type, item)
#> [1] TRUE
```

### Category to Sector

In the same way, allocating to sectors uses a category-to-sector
crosswalk (also referred to as an implan sectoring scheme). Note that
dated versions of sectoring schemes are stored in [O365 \> Implan \>
Sectoring
Schemes](https://southwickassociatesinc.sharepoint.com/:f:/s/Implan/EnL9nwfijuROuo34BCV47fkB9yuOh8l0lDdaEtmEfL9TNA?e=R2dby9))
and these can be used directly (or with minor modifications) for any
given project.

``` r
data(category_to_sector546)
head(category_to_sector546, 2)
#> # A tibble: 2 x 6
#>   group category       sector share retail description                         
#>   <chr> <chr>           <dbl> <dbl> <chr>  <chr>                               
#> 1 Comm  Boat fuel        3157 0.023 Yes    Petroleum lubricating oil and grease
#> 2 Ind   Boat launching    502 0.690 No     Amusement parks and arcades

check_share_sums(category_to_sector546, sharevar = share, category)
#> [1] TRUE
```

``` r
spend_sector <- spend_category %>%
    left_join(category_to_sector546, by = "category") %>%
    mutate(spend = spend * share)

check_spend_sums(df_old = spend_category, df_new = spend_sector, spendvar = spend, category)
#> [1] TRUE
```

## 2\. Input Write to Excel

Writing to Excel (for Implan import) can be done with the `input()`
function. This function combines two steps that are worth
distinguishing:

  - `input_prep()` converts spending by sector to the two tables
    (header, data) needed in each Excel sheet

<!-- end list -->

``` r
ind <- input_prep_ind(spend_sector, activity_name = "Ind", event_year = 2019)
comm <- input_prep_comm(spend_sector, activity_name = "Comm", event_year = 2019)

comm$header
#> # A tibble: 1 x 4
#>   `Activity Type`  `Activity Name` `Activity Level` `Activity Year`
#>   <chr>            <chr>                      <dbl>           <dbl>
#> 1 Commodity Change Comm                           1            2019

head(comm$dat, 2)
#> # A tibble: 2 x 5
#>   Sector `Event Value` EventYear Retail `Local Direct Purchase`
#>    <dbl>         <dbl>     <dbl> <chr>                    <dbl>
#> 1   3002      1794094.      2019 Yes                          1
#> 2   3003     21865892.      2019 Yes                          1
```

  - `input_write()` adds the prepared data to an Excel file

<!-- end list -->

``` r
input_write(comm, "tmp.xlsx")
input_write(ind, "tmp.xlsx")

openxlsx::getSheetNames("tmp.xlsx")
#> [1] "Comm" "Ind"
```

It’s convenient to wrap the prep/write steps into a single function for
production. To be on the safe side, we can also run
`check_implan_sums()` to ensure the Excel data look correct. Note that
for Implan import, you’ll first need to open the `.xlsx` file and save
to the legacy `.xls` format which Implan requires.

``` r
input(spend_sector, "tmp2.xlsx", 2019)
check_implan_sums(spend_sector, "tmp2.xlsx") # should print TRUE
#> [1] TRUE

openxlsx::getSheetNames("tmp2.xlsx")
#> [1] "Comm" "Ind"
```

The `input()` function also allows grouping at an arbitrary number of
dimensions, which get written to separate Excel sheets. For example, we
could split the results by `act` and `type`:

``` r
input(spend_sector, "tmp3.xlsx", 2019, act, type)
check_implan_sums(spend_sector, "tmp3.xlsx", act, type)
#> [1] TRUE

openxlsx::getSheetNames("tmp3.xlsx")
#>  [1] "bikeequipComm"     "bikeequipInd"      "biketripComm"     
#>  [4] "biketripInd"       "campequipComm"     "campequipInd"     
#>  [7] "camptripComm"      "camptripInd"       "fishequipComm"    
#> [10] "fishequipInd"      "fishtripComm"      "fishtripInd"      
#> [13] "huntequipComm"     "huntequipInd"      "hunttripComm"     
#> [16] "hunttripInd"       "picnictripComm"    "picnictripInd"    
#> [19] "snowequipComm"     "snowequipInd"      "snowtripComm"     
#> [22] "snowtripInd"       "trailequipComm"    "trailequipInd"    
#> [25] "trailtripComm"     "trailtripInd"      "waterequipComm"   
#> [28] "waterequipInd"     "watertripComm"     "watertripInd"     
#> [31] "wildlifeequipComm" "wildlifeequipInd"  "wildlifetripComm" 
#> [34] "wildlifetripInd"
```

In practice we might want to delineate one of these dimensions with
separate Excel files. That’s easily accomplished using a for loop:

``` r
for (i in c("equip", "trip")) {
    dat <- filter(spend_sector, type == i)
    filename <- paste0("tmp-", i, ".xlsx")
    input(dat, filename, 2019, act)
}
openxlsx::getSheetNames("tmp-trip.xlsx")
#>  [1] "bikeComm"     "bikeInd"      "campComm"     "campInd"      "fishComm"    
#>  [6] "fishInd"      "huntComm"     "huntInd"      "picnicComm"   "picnicInd"   
#> [11] "snowComm"     "snowInd"      "trailComm"    "trailInd"     "waterComm"   
#> [16] "waterInd"     "wildlifeComm" "wildlifeInd"
```

## 3\. Output Read from Implan

From Implan, you’ll need to save output results into csv files, where
each Implan activity should have its own folder of results. Two example
activities are included in this package to demonstrate:

``` r
output_dir <- system.file("extdata", "output", "region1", package = "implan")
list.files(output_dir)
#> [1] "bike" "hunt"
```

Typically, you’ll have five sets of results per activity:

``` r
hunt_dir <- file.path(output_dir, "hunt")
list.files(hunt_dir)
#> [1] "B4W_ColoradoModelFedDirect.csv"   "B4W_ColoradoModelFedTotal.csv"   
#> [3] "B4W_ColoradoModelStateDirect.csv" "B4W_ColoradoModelStateTotal.csv" 
#> [5] "B4W_ColoradoModelSummary.csv"
```

### output()

We can use the `output()` function to pull the data, but I’ll break out
its two subprocesses for illustration:

  - `output_read_csv()` pulls all csv files for an activity into an R
    list, with one data frame per input file. The names of the list
    correspond to a title row that Implan includes in the output csv
    files

<!-- end list -->

``` r
dat <- output_read_csv(hunt_dir)
names(dat)
#> [1] "federal tax impact by direct"        
#> [2] "federal tax impact by total"         
#> [3] "state and local tax impact by direct"
#> [4] "state and local tax impact by total" 
#> [5] "impact summary"
```

  - `output_combine()` aggregates the tax results and appends to the
    overall summary

<!-- end list -->

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

In practice we’ll usually want to pull multiple activities. This is
easily accomplished with `output()` because it will parse out the
directories and store their names in a “dimension” variable:

``` r
list.files(output_dir)
#> [1] "bike" "hunt"

df <- output(output_dir)
glimpse(df)
#> Observations: 8
#> Variables: 8
#> $ ImpactType      <chr> "Direct Effect", "Indirect Effect", "Induced Effect...
#> $ Employment      <dbl> 2893.4122, 807.9625, 962.0801, 4663.4548, 1694.1600...
#> $ LaborIncome     <dbl> 113060079, 54793181, 48677587, 216530848, 51488607,...
#> $ TotalValueAdded <dbl> 185259583, 82309563, 88529239, 356098385, 77127905,...
#> $ Output          <dbl> 340859796, 160323464, 152913486, 654096746, 1476797...
#> $ FedTax          <dbl> 26130695, NA, NA, 48060734, 11001048, NA, NA, 20375212
#> $ LocalTax        <dbl> 31961988, NA, NA, 46878467, 9377690, NA, NA, 15554404
#> $ dimension       <chr> "bike", "bike", "bike", "bike", "hunt", "hunt", "hu...
```

The `output()` function also arbitrarily scales up to multiple
dimensions. The example data actually includes two dimensions (region by
activity) which we can use to demonstrate:

``` r
output_dir <- system.file("extdata", "output", package = "implan")
list.files(output_dir)
#> [1] "region1" "region2"

df <- output(output_dir)
count(df, dimension)
#> # A tibble: 4 x 2
#>   dimension        n
#>   <chr>        <int>
#> 1 region1/bike     4
#> 2 region1/hunt     4
#> 3 region2/bike     4
#> 4 region2/hunt     4
```

It’s probably more useful to have the dimensions represented by distinct
variables:

``` r
library(tidyr)
df <- separate(df, dimension, c("region", "act"))
count(df, region, act)
#> # A tibble: 4 x 3
#>   region  act       n
#>   <chr>   <chr> <int>
#> 1 region1 bike      4
#> 2 region1 hunt      4
#> 3 region2 bike      4
#> 4 region2 hunt      4
```

## Excel Approach

The Excel approach combines steps 1 & 2 into an Excel workbook. I
included a basic example (for wildlife watching) in this package:

``` r
filepath <- system.file(
  "extdata", "templates", "fhwar-implan-import.xls", package = "implan"
)
file.copy(filepath, "tmp-input.xls") # copy to your working directory
#> [1] TRUE
```

Step 3 can be accomplished by copy/pasting implan results into an Excel
sheet and running embedded macros:

``` r
filepath <- system.file(
  "extdata", "templates", "implan-output.xlsm", package = "implan"
)
file.copy(filepath, "tmp-output.xlsm")
#> [1] TRUE
```
