# functions to transfer to/from implan

# Input -------------------------------------------------------------------

#' Get a header table for Implan import
#'
#' This is a convenience function called from \code{\link{implan_prepare}}
#'
#' @inheritParams implan_prepare
#' @param activity_type either "Industry Change" or "Commodity Change"
#' @family functions to transfer to/from implan
#' @export
#' @examples
#' # see ?implan_prepare
implan_header <- function(activity_type, activity_name, event_year) {
    tribble(
        ~`Activity Type`, ~`Activity Name`, ~`Activity Level`, ~`Activity Year`,
        activity_type, activity_name, 1, event_year
    )
}

#' Prepare spending by sector for Excel implan import
#'
#' This function splits an input data frame into a list with 2 data frames:
#' (1) a sheet header with activity details used by implan, and (2) the
#' sector spending with additional columns which implan will calculate
#'
#' @param dat data frame with spending by sector
#' @param activity_name Activity Name used for Implan
#' @param event_year Activity Year for Implan
#' @name implan_prepare
#' @family functions to transfer to/from implan
#' @examples
#' # get necessary sectoring
#' data(sector_scheme536, sectors_crosswalk, sectors546)
#' sector_scheme546 <- sector_update(sector_scheme536, sectors_crosswalk, sectors546)
#'
#' # calculate total spending by sector
#' library(dplyr)
#' data(spending, categories)
#'
#' spend_category <- spending %>%
#'     left_join(categories, by = c("type", "item")) %>%
#'     mutate(spend = spend * share)
#' check_spend_sums(spending, spend_category, spend, type, item)
#'
#' spend_sector <- spend_category %>%
#'     select(-share) %>%
#'     left_join(sector_scheme546, by = "category") %>%
#'     mutate(spend = spend * share)
#' check_spend_sums(spend_category, spend_sector, spend, type, item, category)
#'
#' # allocate for implan import (Industry)
#' ls <- implan_prepare_ind(spend_sector, "huntInd")
#' ls
#'
#' # write to an excel file
NULL

#' @describeIn implan_prepare Prepare industry data
#' @export
implan_prepare_ind <- function(dat, activity_name, event_year = 2019) {
    header <- implan_header("Industry Change", activity_name, event_year)
    dat <- dat %>%
        filter(.data$group == "Ind") %>%
        arrange(.data$sector) %>%
        mutate(emp = 0, comp = 0, inc = 0, yr = event_year, loc = 1) %>%
        select(Sector = .data$sector, `Event Value` = .data$spend,
               Employment = .data$emp, `Employee Compensation` = .data$comp,
               `Proprietor Income` = .data$inc, EventYear = .data$yr,
               Retail = .data$retail, `Local Direct Purchase` = .data$loc)
    list("header" = header, "dat" = dat)
}
