# functions for implan input

#' Get a header table for Implan import
#'
#' This is a convenience function called from \code{\link{input_prep}}
#'
#' @inheritParams input_prep
#' @param activity_type either "Industry Change" or "Commodity Change"
#' @family functions for implan input
#' @export
#' @examples
#' # see ?input_prep
input_header <- function(activity_type, activity_name, event_year) {
    tribble(
        ~`Activity Type`, ~`Activity Name`, ~`Activity Level`, ~`Activity Year`,
        activity_type, activity_name, 1, event_year
    )
}

#' Prepare spending by sector for Excel implan import
#'
#' This function splits an input data frame into a list with 2 data frames:
#' (1) a sheet header with activity details used by implan, and (2) the
#' sector spending with additional columns which implan will calculate. The data
#' portion is also grouped by sector-retail to ensure the minimum number of rows.
#'
#' @param dat data frame with spending by sector with 4 required columns:
#' group ("Ind" or "Comm"), sector (numeric), retail ("Yes" or "No"), spend (numeric)
#' @param activity_name Activity Name used for Implan
#' @param event_year Activity Year for Implan
#' @param group Either "Ind" or "Comm"
#' @export
#' @family functions for implan input
#' @examples
#' # get necessary sectoring
#' data(category_to_sector536, sector536_to_sector546, sectors546)
#' category_to_sector546 <- sector_update(category_to_sector536, sector536_to_sector546, sectors546)
#'
#' # calculate total spending by sector
#' library(dplyr)
#' data(spending, item_to_category)
#'
#' spend_category <- spending %>%
#'     left_join(item_to_category, by = c("activity_group", "type", "item")) %>%
#'     mutate(spend = spend * share)
#' check_spend_sums(spending, spend_category, spend, activity_group, type, item)
#'
#' spend_sector <- spend_category %>%
#'     select(-share) %>%
#'     left_join(category_to_sector546, by = "category") %>%
#'     mutate(spend = spend * share)
#' check_spend_sums(spend_category, spend_sector, spend, type, item, category)
#'
#' # allocate for implan import (Industry)
#' comm <- input_prep_comm(spend_sector, "huntComm", 2019)
#' ind <- input_prep_ind(spend_sector, "huntInd", 2019)
#' ind
#'
#' # write to an excel worksheet
#' # you'll need to manually save as ".xls" (in Excel) from Implan import
#' \dontrun{
#' input_write(ind, "tmp.xlsx")
#' }
#'
#' # write sheets by activity-type
#' \dontrun{
#' input(spend_sector, "tmp2.xlsx", 2019, act, type)
#' }
input_prep <- function(dat, activity_name, event_year, group) {
    # collapse to sector-retail & add variables that might be needed
    sector_group <- group # to ensure the filter works correctly
    dat <- dat %>%
        filter(.data$group == sector_group) %>%
        group_by(.data$sector, .data$retail) %>%
        summarise(spend = sum(.data$spend)) %>%
        ungroup() %>%
        mutate(emp = 0, comp = 0, inc = 0, yr = event_year, loc = 1)

    if (group == "Ind") {
        header <- input_header("Industry Change", activity_name, event_year)
        dat <- dat %>% select(
            Sector = .data$sector, `Event Value` = .data$spend,
            Employment = .data$emp, `Employee Compensation` = .data$comp,
            `Proprietor Income` = .data$inc, EventYear = .data$yr,
            Retail = .data$retail, `Local Direct Purchase` = .data$loc
        )

    } else {
        header <- input_header("Commodity Change", activity_name, event_year)
        dat <- dat %>% select(
            Sector = .data$sector, `Event Value` = .data$spend,
            EventYear = .data$yr, Retail = .data$retail,
            `Local Direct Purchase` = .data$loc
        )
    }
    list("header" = header, "dat" = dat)
}

#' @describeIn input_prep Prepare industry data
#' @export
input_prep_ind <- function(dat, activity_name, event_year) {
    input_prep(dat, activity_name, event_year, "Ind")
}

#' @describeIn input_prep Prepare commodity data
#' @export
input_prep_comm <- function(dat, activity_name, event_year) {
    input_prep(dat, activity_name, event_year, "Comm")
}

#' Write data to a sheet for Excel Implan import
#'
#' @param ls list returned from implan_prepare_ind() or implan_prepare_comm()
#' @param filename file path for output excel file
#' @family functions for implan input
#' @export
#' @examples
#' # see ?input_prep()
input_write <- function(ls, filename) {
    if (!file.exists(filename)) {
        wb <- openxlsx::createWorkbook()
    } else {
        wb <- openxlsx::loadWorkbook(filename)
    }
    sheet <- ls$header$`Activity Name` # worksheet name will match activity name
    if (sheet %in% names(wb)) {
        openxlsx::removeWorksheet(wb, sheet)
    }
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet = sheet, ls$header)
    openxlsx::writeData(wb, sheet = sheet, ls$dat, startRow = 4)
    openxlsx::saveWorkbook(wb, filename, overwrite = TRUE)
}

#' Write spending to Excel for Implan import
#'
#' This writes separate sheets for commodity and industry by wrapping
#' \code{\link{input_prep}} and \code{\link{input_write}}. The dots
#' argument allows for an arbitrary number of grouping dimensions (for separate
#' sheets by dimensions).
#'
#' @inheritParams input_prep
#' @inheritParams input_write
#' @param ... Optional grouping variables (unquoted) for separating sheets
#' across one or more dimensions
#' @family functions for implan input
#' @export
#' @examples
#' # see ?input_prep()
input <- function(dat, filename, event_year, ...) {
    # wrapping prep & write steps into one function
    prep_write <- function(df, dim_name = "") {
        input_prep_ind(df, paste0(dim_name, "Ind"), event_year) %>%
            input_write(filename)
        input_prep_comm(df, paste0(dim_name, "Comm"), event_year) %>%
            input_write(filename)
    }
    dims <- enquos(...)
    if (length(dims) == 0) {
        prep_write(dat)
        return(invisible())
    }
    out <- group_split(dat, !!! dims) %>%
        lapply(function(df) {
            dim_vals <- select(df, !!! dims) %>% head(1)
            dim_name <- unlist(dim_vals) %>% paste(collapse = "")
            prep_write(df, dim_name)
        })
}
