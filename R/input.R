# functions to transfer to/from implan

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
#' sector spending with additional columns which implan will calculate. The data
#' portion is also grouped by sector-retail to ensure the minimum number of rows.
#'
#' @param dat data frame with spending by sector with 4 required columns:
#' group ("Ind" or "Comm"), sector (numeric), retail ("Yes" or "No"), spend (numeric)
#' @param activity_name Activity Name used for Implan
#' @param event_year Activity Year for Implan
#' @param group Either "Ind" or "Comm"
#' @export
#' @family functions to transfer to/from implan
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
#'     left_join(item_to_category, by = c("type", "item")) %>%
#'     mutate(spend = spend * share)
#' check_spend_sums(spending, spend_category, spend, type, item)
#'
#' spend_sector <- spend_category %>%
#'     select(-share) %>%
#'     left_join(category_to_sector546, by = "category") %>%
#'     mutate(spend = spend * share)
#' check_spend_sums(spend_category, spend_sector, spend, type, item, category)
#'
#' # allocate for implan import (Industry)
#' comm <- input_prep_comm(spend_sector, "huntComm")
#' ind <- input_prep_ind(spend_sector, "huntInd")
#' ind
#'
#' # write to an excel worksheet
#' xlsx_write_implan(ind, "tmp.xlsx")
#' # you'll need to manually save as ".xls" (in Excel) from Implan import
input_prep <- function(dat, activity_name, event_year = 2019, group) {
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
input_prep_ind <- function(dat, activity_name, event_year = 2019) {
    input_prep(dat, activity_name, event_year, "Ind")
}

#' @describeIn input_prep Prepare commodity data
#' @export
input_prep_comm <- function(dat, activity_name, event_year = 2019) {
    input_prep(dat, activity_name, event_year, "Comm")
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
#' @examples
#' xlsx_initialize_workbook("tmp.xlsx")
xlsx_initialize_workbook <- function(filename) {
    if (file.exists(filename)) {
        return(invisible()) # an existing file won't be overwritten
    }
    wb <- openxlsx::createWorkbook()
    openxlsx::addWorksheet(wb, "README")
    openxlsx::saveWorkbook(wb, filename)
}

# TODO: in xlsx_write_table:
# - probably use sheet = NULL to default to name of data frame

#' Write a data frame to an Excel tab
#'
#' Requires an existing Excel file, preferably created using
#' \code{\link{xlsx_initialize_workbook}}. The selected tab will be removed
#' (if it already exists) and a new tab will be written.
#'
#' @param df data frame to write to the Excel worksheet
#' @param sheet name to use for Excel worksheet. If NULL (default) the name of
#' the df will be used.
#' @inheritParams xlsx_initialize_workbook
#' @family functions to transfer to/from implan
#' @export
#' @examples
#' xlsx_initialize_workbook("tmp.xlsx")
#' moria <- data.frame(a = 1:4, b = c("speak", "friend", "and", "enter"))
#' xlsx_write_table(moria, "tmp.xlsx")
xlsx_write_table <- function(df, filename, sheet = NULL) {
    if (is.null(sheet)) {
        sheet <- deparse(substitute(df))
    }
    wb <- openxlsx::loadWorkbook(filename)
    if (sheet %in% openxlsx::getSheetNames(filename)) {
        openxlsx::removeWorksheet(wb, sheet)
    }
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet = sheet, df)
    openxlsx::saveWorkbook(wb, filename, overwrite = TRUE)
}

#' Write data to a sheet for Excel Implan import
#'
#' @param ls list returned from implan_prepare_ind() or implan_prepare_comm()
#' @param xls_out file path for output excel file
#' @family functions to transfer to/from implan
#' @export
#' @examples
#' # see ?input_prep()
xlsx_write_implan <- function(ls, xls_out) {
    sheet <- ls$header$`Activity Name` # worksheet name will match activity name
    xlsx_initialize_workbook(xls_out)
    wb <- openxlsx::loadWorkbook(xls_out)
    if (sheet %in% openxlsx::getSheetNames(xls_out)) {
        openxlsx::removeWorksheet(wb, sheet)
    }
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet = sheet, ls$header)
    openxlsx::writeData(wb, sheet = sheet, ls$dat, startRow = 4)
    openxlsx::saveWorkbook(wb, xls_out, overwrite = TRUE)
}

# Load Output -------------------------------------------------------------

#' Read Implan CSV output into R data frames for an implan activity
#'
#' @param dirname directory name that stores files for selected activity
#' @family functions to transfer to/from implan
#' @export
#' @examples
#' output_dir <- system.file("extdata", "output", package = "implan")
#' hunt_dir <- file.path(output_dir, "hunt")
#' dat <- output_read_csv(hunt_dir)
#' output_combine(dat)
output_read_csv <- function(dirname) {
    # we only want csv files
    files <- list.files(dirname, ".*\\.csv", full.names = TRUE)

    # store tables in a list of data frames
    # - define convenience function for reading csv files
    read <- function(x, ...) suppressMessages(readr::read_csv(x, ...))

    # - the header row (column names) is on row 2
    dat <- files %>%
        sapply(function(i) read(i, skip = 1), simplify = FALSE)

    # - there is a title row that holds the table name
    names(dat) <- files %>%
        sapply(function(i) read(i, n_max = 1, col_names = FALSE)[1,1]) %>%
        tolower()
    dat
}

#' Combine csv output for an implan activity into one data frame
#'
#' Puts summary, tax fed, and tax local into a single table
#'
#' @param dat list produced by \code{\link{output_read_csv}}
#' @family functions to transfer to/from implan
#' @export
#' @examples
#' # see ?output_read_csv()
output_combine <- function(dat) {
    # define helper function for string matching
    output_match <- function(string, match) {
        is_match <- stringr::str_detect(string, match)
        string[is_match]
    }
    # define function to run federal and state/local separately
    get_tax <- function(match = "federal", tax_type = "FedTax") {
        output_match(names(dat), match) %>% sapply(function(x) {
            impact = ifelse(
                stringr::str_detect(x, "direct"),
                "Direct Effect", "Total Effect"
            )
            output_format_tax(dat[[x]], impact, tax_type)
        }, simplify = FALSE) %>% bind_rows()
    }
    fed <- get_tax("federal", "FedTax")
    local <- get_tax("local", "LocalTax")
    dat[["impact summary"]] %>%
        left_join(fed, by = "ImpactType") %>%
        left_join(local, by = "ImpactType")
}

#' A helper function to format Tax Impact csv files
#'
#' This simplifies the tax results to just show sum of taxes by direct/total.
#' Intended to be called from \code{\link{output_combine}}
#'
#' @param df data frame with tax results
#' @param impact_type either "Direct Effect" or "Total Effect"
#' @param tax_type either "FedTax" or "LocalTax"
#' @family functions to transfer to/from implan
#' @export
output_format_tax <- function(df, impact_type, tax_type) {
    strip_dollar <- function(x) {
        stringr::str_remove_all(x, "\\$") %>% stringr::str_remove_all(",")
    }
    total_tax <- tail(df, 1) %>%
        select(.data$`Employee Compensation`:.data$Corporations) %>%
        mutate_all(function(x) as.numeric(strip_dollar(x)))
    out <- tibble(impact_type, sum(total_tax))
    names(out) <- c("ImpactType", tax_type)
    out
}
