## code to prepare `sector_scheme536` dataset goes here

library(dplyr)
library(readxl)

f <- "inst/extdata/implan-sectors536.xlsx"
sector_scheme536 <- read_excel(f, sheet = "hunt")
usethis::use_data(sector_scheme536)
