
<!-- implan-transfer.md is generated from implan-transfer.Rmd. Please edit that file -->

## Overview

The implan package streamlines the steps otherwise done in Excel:

1.  Allocate spending by Implan sector
2.  Write Excel tabs (Industry/Commercial) for Implan import
3.  Pull all Implan output (csv) into one results table

### Elevator Pitch

Using R makes it easy to scale-up (or down) without the tedious manual
editing in Excel. It’s also less error-prone because you can write
straightforward scripts with built-in checks & summaries.

## Implan Sector Allocation

Results expenditures need to be specified at the correct dimension
(Implan sectors).

``` r
library(dplyr)
library(implan)
```