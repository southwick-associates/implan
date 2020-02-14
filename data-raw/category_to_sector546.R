## code to prepare `category_to_sector546` dataset goes here

library(dplyr)
library(implan)

data(category_to_sector536, sectors_crosswalk, sectors546)
category_to_sector546 <- sector_update(category_to_sector536, sectors_crosswalk, sectors546) %>%
    select(group, category, sector, description, share, retail)

usethis::use_data(category_to_sector546)
