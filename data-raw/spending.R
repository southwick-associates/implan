## code to prepare `spending` dataset goes here

library(dplyr)

spending <- readRDS("inst/extdata/spend2019.rds") %>%
    select(activity_group, act:spend)

usethis::use_data(spending, overwrite = TRUE)
