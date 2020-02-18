## code to prepare `category_to_sector536` dataset goes here

library(dplyr)
library(readxl)

# data that includes work to remove discrepancies
# https://github.com/southwick-associates/B4W-19-01/blob/master/code/summary/compare-implan-sectoring.md
f <- "inst/extdata/master-implan-sectoring536.xlsx"

# load category-sectors with discrepancies between activities now fixed
fixed <- read_excel(f, sheet = "master_new")

# load remaining category-sectors
master <- read_excel(f, "master")
category_to_sector536 <- bind_rows(
    fixed, anti_join(master, fixed, by = c("category", "sector"))
)
nrow(distinct(category_to_sector536, category, sector)) == nrow(category_to_sector536) # check

# update commodity codes to 3000 format (which were stripped when looking for discrepancies)
category_to_sector536 <- category_to_sector536 %>%
    mutate(sector = ifelse(group == "Comm", sector + 3000, sector)) %>%
    select(category, sector, group, retail, share)

# add descriptions from reference Implan table
load("data/sectors536.rda")
category_to_sector536 <- category_to_sector536 %>%
    left_join(sectors536, by = c("group", "sector"))
implan::check_share_sums(category_to_sector536, share, category)

usethis::use_data(category_to_sector536, overwrite = TRUE)
