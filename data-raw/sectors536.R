## code to prepare `sectors536` dataset goes here

library(dplyr)
library(readxl)

f <- "inst/extdata/Implan536_Industries_and_Commodities.xlsx"
x <- read_excel(f, sheet = "Industry") %>%
    select(sector = Implan536Index, description = ImplanDescription) %>%
    mutate(group = "Ind")
y <- read_excel(f, sheet = "Commodity") %>%
    select(sector = Implan536CommodityIndex, description = ImplanDescription) %>%
    mutate(group = "Comm")
sectors536 <- bind_rows(x, y)

usethis::use_data(sectors536)
