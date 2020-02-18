## code to prepare `category_to_sector546` dataset goes here

library(dplyr)
library(implan)

load("data/category_to_sector536.rda")
load("data/sector536_to_sector546.rda")
load("data/sectors546.rda")

category_to_sector546 <- category_to_sector536 %>%
    sector_update(sector536_to_sector546, sectors546) %>%
    select(group, category, sector, share, retail, description)

usethis::use_data(category_to_sector546, overwrite = TRUE)
