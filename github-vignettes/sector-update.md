
<!-- sector-update.md is generated from sector-update.Rmd. Please edit that file -->

## Overview

The implan package includes some data and functions to help update
category-sector crosswalks between implan sectoring schemes (e.g.,
[version 536
to 546](https://implanhelp.zendesk.com/hc/en-us/articles/360034896614-546-Industries-Conversions-Bridges-Construction-2018-Data)).
Note that the included function provides a direct crosswalk update and
doesn’t do any respecification (for example if the market basket of
goods changes).

#### Master Sector Schemes

The master sectoring schemes (category to sector) are stored on Office
365: [Implan \> Sectoring
Schemes](https://southwickassociatesinc.sharepoint.com/:f:/s/Implan/EnL9nwfijuROuo34BCV47fkB9yuOh8l0lDdaEtmEfL9TNA?e=Pkiaai).

## Pull Data

The 536to546 crosswalk file has been included in this package. I did
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

We need the 536 sectoring scheme for the update, an example of which has
been included in this package:

``` r
data("category_to_sector536")
glimpse(category_to_sector536)
#> Observations: 247
#> Variables: 6
#> $ category    <chr> "Boat fuel", "Boat launching", "Boat launching", "Boat ...
#> $ sector      <dbl> 3159, 494, 496, 494, 496, 59, 3060, 63, 440, 515, 3516,...
#> $ group       <chr> "Comm", "Ind", "Ind", "Ind", "Ind", "Ind", "Comm", "Ind...
#> $ retail      <chr> "Yes", "No", "No", "No", "No", "No", "No", "No", "No", ...
#> $ share       <dbl> 0.023000000, 0.689787900, 0.310212100, 0.689787900, 0.3...
#> $ description <chr> "Petroleum lubricating oil and grease", "Amusement park...
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
#> Observations: 266
#> Variables: 6
#> $ category    <chr> "Boat fuel", "Boat launching", "Boat launching", "Boat ...
#> $ group       <chr> "Comm", "Ind", "Ind", "Ind", "Ind", "Ind", "Comm", "Ind...
#> $ retail      <chr> "Yes", "No", "No", "No", "No", "No", "No", "No", "No", ...
#> $ share       <dbl> 0.023000000, 0.689787900, 0.310212100, 0.689787900, 0.3...
#> $ sector      <dbl> 3157, 502, 504, 502, 504, 57, 3058, 61, 447, 448, 523, ...
#> $ description <chr> "Petroleum lubricating oil and grease", "Amusement park...
```
