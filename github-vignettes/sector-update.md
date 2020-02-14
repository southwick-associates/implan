
<!-- sector-update.md is generated from sector-update.Rmd. Please edit that file -->

## Overview

The implan package includes some data and functions to help update
category-sector crosswalks between implan sectoring schemes (e.g.,
[version 536
to 546](https://implanhelp.zendesk.com/hc/en-us/articles/360034896614-546-Industries-Conversions-Bridges-Construction-2018-Data)).
Note that the included function provides a direct crosswalk update and
doesn’t do any respecification (for example if the market basket of
goods changes).

## Pull Data

The necessary crosswalk file has been included in this package. I did
some pre-processing to get the crosswalk data into a more useful format
([code
here](https://github.com/southwick-associates/implan/blob/master/data-raw/sector536_to_sector546.R)).

``` r
library(dplyr)
library(implan)

data("sector536_to_sector546")
glimpse(sector536_to_sector546)
#> Observations: 1,098
#> Variables: 4
#> $ sector546       <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, ...
#> $ sector536       <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, ...
#> $ crosswalk_ratio <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...
#> $ group           <chr> "Ind", "Ind", "Ind", "Ind", "Ind", "Ind", "Ind", "I...
```

Note that the `CewAvgRatio` variable from the raw data was renamed to
`crosswalk_ratio`. This variable was used for the small number of cases
when 536 sectors were expanded to multiple sectors in the 546 scheme.

``` r
check_share_sums(sector536_to_sector546, crosswalk_ratio, group, sector536)
#> [1] TRUE
```

We need the 536 sectoring scheme for the update:

``` r
data("category_to_sector536")
glimpse(category_to_sector536)
#> Observations: 140
#> Variables: 6
#> $ group       <chr> "Comm", "Comm", "Comm", "Comm", "Comm", "Comm", "Comm",...
#> $ category    <chr> "Ammo", "Ammo", "Bass boat", "Binoculars", "Boat fuel",...
#> $ sector      <dbl> 3257, 3258, 3364, 3272, 3156, 3159, 3286, 3419, 3418, 3...
#> $ description <chr> "Small arms ammunition", "Ammunition, except for small ...
#> $ share       <dbl> 0.3248092, 0.6751908, 1.0000000, 1.0000000, 0.9770000, ...
#> $ retail      <chr> "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes",...
```

The `sector_update()` function converts from one sectoring scheme to the
next.

``` r
data("sectors546")
category_to_sector546 <- sector_update(
    scheme_old = category_to_sector536, 
    crosswalk = sector536_to_sector546, 
    description_new = sectors546
)
glimpse(category_to_sector546)
#> Observations: 152
#> Variables: 6
#> $ group       <chr> "Comm", "Comm", "Comm", "Comm", "Comm", "Comm", "Comm",...
#> $ category    <chr> "Ammo", "Ammo", "Bass boat", "Binoculars", "Boat fuel",...
#> $ share       <dbl> 0.3248092, 0.6751908, 1.0000000, 1.0000000, 0.9770000, ...
#> $ retail      <chr> "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes",...
#> $ sector      <dbl> 3255, 3256, 3361, 3270, 3154, 3157, 3284, 3425, 3424, 3...
#> $ description <chr> "Small arms ammunition", "Ammunition, except for small ...
```
