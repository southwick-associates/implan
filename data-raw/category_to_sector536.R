## code to prepare `category_to_sector536` dataset goes here

library(dplyr)
library(readxl)

f <- "inst/extdata/implan-sectors536.xlsx"
category_to_sector536 <- read_excel(f, sheet = "hunt")
usethis::use_data(category_to_sector536)
