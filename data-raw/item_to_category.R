## code to prepare `item_to_category` dataset goes here

library(dplyr)
library(readxl)

item_to_category <- read_excel("inst/extdata/implan-categories.xlsx") %>%
    rename(type = spend_type)

usethis::use_data(item_to_category, overwrite = TRUE)
