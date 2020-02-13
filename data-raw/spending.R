## code to prepare `spending` dataset goes here

library(dplyr)

spending <- readRDS("inst/extdata/spend2019.rds") %>%
    filter(activity_group == "hunt") %>%
    select(-activity_group, -act)

usethis::use_data(spending, overwrite = TRUE)
