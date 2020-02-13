## code to prepare `sector_scheme546` dataset goes here

library(dplyr)
library(implan)

data(sector_scheme536, sectors_crosswalk, sectors546)
sector_scheme546 <- sector_update(sector_scheme536, sectors_crosswalk, sectors546) %>%
    select(group, category, sector, description, share, retail)

usethis::use_data(sector_scheme546)
