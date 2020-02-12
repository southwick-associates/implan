## code to prepare `sectors_crosswalk` dataset goes here

library(dplyr)
library(readxl)

f <- "inst/extdata/Bridge_Implan536ToImplan546.xlsx"
x <- read_excel(f) %>%
    select(sector546 = Implan546Index, sector536 = Implan536Index, crosswalk_ratio = CewAvgRatio)
sectors_crosswalk <- bind_rows(
    mutate(x, group = "Ind"),
    mutate(x, group = "Comm") %>%
        mutate_at(vars(sector546, sector536), function(x) x + 3000)
)

usethis::use_data(sectors_crosswalk)
