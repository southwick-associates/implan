# functions to transfer to/from implan

# TODO: add xlsx_write_implan() example to input_prep

# Prep Input -------------------------------------------------------------------

#' Get a header table for Implan import
#'
#' This is a convenience function called from \code{\link{input_prep}}
#'
#' @inheritParams input_prep
#' @param activity_type either "Industry Change" or "Commodity Change"
#' @family functions to transfer to/from implan
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
#' sector spending with additional columns which implan will calculate
#'
#' @param dat data frame with spending by sector
#' @param activity_name Activity Name used for Implan
#' @param event_year Activity Year for Implan
#' @name input_prep
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
#' ls <- input_prep_ind(spend_sector, "huntInd")
#' ls
#'
#' # write to an excel file
NULL

#' @describeIn input_prep Prepare industry data
#' @export
input_prep_ind <- function(dat, activity_name, event_year = 2019) {
    header <- input_header("Industry Change", activity_name, event_year)
    dat <- dat %>%
        filter(.data$group == "Ind") %>%
        arrange(.data$sector) %>%
        mutate(emp = 0, comp = 0, inc = 0, yr = event_year, loc = 1) %>%
        select(
            Sector = .data$sector, `Event Value` = .data$spend,
            Employment = .data$emp, `Employee Compensation` = .data$comp,
            `Proprietor Income` = .data$inc, EventYear = .data$yr,
            Retail = .data$retail, `Local Direct Purchase` = .data$loc
        )
    list("header" = header, "dat" = dat)
}

#' @describeIn input_prep Prepare commodity data
#' @export
input_prep_comm <- function(dat, activity_name, event_year = 2019) {
    header <- input_header("Commodity Change", activity_name, event_year)
    dat <- dat %>%
        filter(.data$group == "Comm") %>%
        arrange(.data$sector) %>%
        mutate(yr = event_year, loc = 1) %>%
        select(
            Sector = .data$sector, `Event Value` = .data$spend,
            EventYear = .data$yr, Retail = .data$retail,
            `Local Direct Purchase` = .data$loc
        )
    list("header" = header, "dat" = dat)
}

# Write Input -------------------------------------------------------------

#' Initialize an Excel Workbook with a README tab
#'
#' The README sheet is intended to serve as documentation for the results
#' stored in the Excel file.
#'
#' @param filename path where the Excel workbook will be written
#' @family functions to transfer to/from implan
#' @export
xlsx_initialize_workbook <- function(filename) {
    if (file.exists(filename)) {
        return(invisible()) # an existing file won't be overwritten
    }
    wb <- openxlsx::createWorkbook()
    openxlsx::addWorksheet(wb, "README")
    openxlsx::saveWorkbook(wb, filename)
}

#' Write a data frame to an Excel tab
#'
#' Requires an existing Excel file, preferably created using
#' \code{\link{xlsx_initialize_workbook}}. The selected tab will be removed
#' (if it already exists) and a new tab will be written.
#'
#' @param df data frame to write to the Excel worksheet
#' @param tabname name to use for Excel worksheet
#' @inheritParams xlsx_initialize_workbook
#' @family functions to transfer to/from implan
#' @export
xlsx_write_table <- function(df, tabname, filename) {
    wb <- openxlsx::loadWorkbook(filename)
    if (tabname %in% openxlsx::getSheetNames(filename)) {
        openxlsx::removeWorksheet(wb, tabname)
    }
    openxlsx::addWorksheet(wb, tabname)
    openxlsx::writeData(wb, sheet = tabname, df)
    openxlsx::saveWorkbook(wb, filename, overwrite = TRUE)
}

#' Write data to a sheet for Excel Implan import
#'
#' @param ls list returned from implan_prepare_ind() or implan_prepare_comm()
#' @param xls_out file path for output excel file
#' @param tabname name of sheet to be written to xls_out
#' @family functions to transfer to/from implan
#' @export
xlsx_write_implan <- function(ls, xls_out, tabname) {
    tabname <- ls$header$`Activity Name` # worksheet name will match activity name
    xlsx_initialize_workbook(xls_out)
    wb <- openxlsx::loadWorkbook(xls_out)
    if (tabname %in% openxlsx::getSheetNames(xls_out)) {
        openxlsx::removeWorksheet(wb, tabname)
    }
    openxlsx::addWorksheet(wb, tabname)
    openxlsx::writeData(wb, sheet = tabname, ls$header)
    openxlsx::writeData(wb, sheet = tabname, ls$dat, startRow = 4)
    openxlsx::saveWorkbook(wb, xls_out, overwrite = TRUE)
}

# Load Output -------------------------------------------------------------

# TODO: will need different versions for various outputs

#' Read Implan CSV output into R data frames
csv_read_implan <- function() {

}
