## code to prepare `categories` dataset goes here

library(dplyr)
library(readxl)

categories <- read_excel("inst/extdata/implan-categories.xlsx") %>%
    filter(activity_group == "hunt") %>%
    select(-activity_group) %>%
    rename(type = spend_type)

usethis::use_data(categories, overwrite = TRUE)
