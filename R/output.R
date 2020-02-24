# functions for implan output loading

#' Read Implan CSV output into R data frames for an implan activity
#'
#' @param dirname directory name that stores files for selected activity
#' @family functions for implan output loading
#' @export
#' @examples
#' output_dir <- system.file("extdata", "output", package = "implan")
#' dirname <- file.path(output_dir, "region1", "hunt")
#' dat <- output_read_csv(dirname)
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
#' @family functions for implan output loading
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
#' @family functions for implan output loading
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

#' Read and Summarize Implan output
#'
#' This wraps \code{\link{output_read_csv}} and \code{\link{output_combine}}. It
#' also will assume nested directories represent dimensions of interest. For
#' example, if the top-level directory contains no csv files, it will inspect
#' sub-directories and append the subdirectory names to a "dimension" variable.
#'
#' @inheritParams output_read_csv
#' @family functions for implan output loading
#' @export
#' @examples
#' output_dir <- system.file("extdata", "output", package = "implan")
#'
#' # we can see the nested struture of these files (i.e., multiple dimensions)
#' list.files(output_dir, recursive = TRUE)
#'
#' # pull one dimension of results
#' dirname <- file.path(output_dir, "region1", "bike")
#' output(dirname)
#'
#' # pull all results
#' df <- output(output_dir)
#'
#' # parse dimensions
#' tidyr::separate(df, dimension, c("region", "act"), "/")
output <- function(dirname) {
    f <- list.files(dirname, recursive = TRUE)

    # where there are no nested directories
    if (identical(f, basename(f))) {
        df <- output_read_csv(dirname) %>% output_combine()
        return(df)
    }

    # otherwise, first get a vector showing the directory tree
    dirs <- stringr::str_remove(f, basename(f)) %>%
        unique() %>%
        stringr::str_sub(1, -2) # drop the trailing "/"

    # then pull files from each directory, label, and stack
    sapply(dirs, function(x) {
        output_read_csv(file.path(dirname, x)) %>%
            output_combine() %>%
            mutate(dimension = x) # label
    }, simplify = FALSE) %>%
        bind_rows()
}
