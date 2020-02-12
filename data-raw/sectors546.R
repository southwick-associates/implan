## code to prepare `sectors546` dataset goes here

library(dplyr)
library(readxl)

f <- "inst/extdata/Implan546IndustriesandCommodities.xlsx"
x <- read_excel(f, sheet = "Industries") %>%
    rename(sector = Implan546Index, description = Implan546Description) %>%
    mutate(group = "Ind")
y <- read_excel(f, sheet = "Commodities") %>%
    rename(sector = Implan546CommodityIndex, description = ImplanDescription ) %>%
    mutate(group = "Comm")
sectors546 <- bind_rows(x, y)

usethis::use_data(sectors546, overwrite = TRUE)
