# sample data

#' Implan 546 sector descriptions
#'
#' A dataset containing sector IDs and descriptions prepared from
#' `system.file("extdata", "Implan546 Industries & Commodities.xlsx", package = "implan")`
#'
#' @format A data frame with 1092 rows and 3 variables:
#' \describe{
#'   \item{sector}{sector ID}
#'   \item{description}{sector description}
#'   \item{group}{group: "Ind" or "Comm"}
#' }
#' @source \url{https://implanhelp.zendesk.com/hc/en-us/articles/360034895094-BEA-Benchmark-The-New-546-Sectoring-Scheme}
#' @family data
"sectors546"

#' Implan 536 sector descriptions
#'
#' A dataset containing sector IDs and descriptions prepared from
#' `system.file("extdata", "Implan536_Industries_and_Commodities.xlsx", package = "implan")`
#'
#' @format A data frame with 1072 rows and 3 variables:
#' \describe{
#'   \item{sector}{sector ID}
#'   \item{description}{sector description}
#'   \item{group}{group: "Ind" or "Comm"}
#' }
#' @source \url{https://implanhelp.zendesk.com/hc/en-us/articles/115002997573-536-Sector-Industries-Conversions-Bridges-Construction-2013-2017-Data}
#' @family data
"sectors536"

#' Implan 546/536 crosswalk
#'
#' A dataset for relating different Implan sectoring schemes (546 and 536) prepared from
#' `system.file("extdata", "Bridge_Implan536ToImplan546.xlsx", package = "implan")`
#'
#' @format A data frame with 1098 rows and 4 variables:
#' \describe{
#'   \item{sector546}{ID for 546}
#'   \item{sector536}{ID for 536}
#'   \item{crosswalk_ratio}{for allocation, from variable originally named "CewAvgRatio"}
#'   \item{group}{"Ind" or "Comm"}
#' }
#' @source \url{https://implanhelp.zendesk.com/hc/en-us/articles/360034895094-BEA-Benchmark-The-New-546-Sectoring-Scheme}
#' @family data
"sectors_crosswalk"

#' Implan sectoring scheme (536) for hunting
#'
#' A dataset that defines how hunting expenditures will be allocated to implan
#' sectors, prepared from `system.file("extdata", "implan-sectors536.xlsx", package = "implan")`
#'
#' @format A data frame with 140 rows (uniquely identified with category-sector) and 6 columns:
#' \describe{
#'   \item{group}{"Ind" or "Comm"}
#'   \item{category}{spending category (e.g., "Food - Groceries", etc.)}
#'   \item{sector}{implan sector ID}
#'   \item{description}{implan sector description}
#'   \item{share}{share of category to be allocated by sector}
#'   \item{retail}{"Yes" or "No"}
#' }
#' @family data
"sector_scheme536"

#' Implan hunting spending categories
#'
#' A dataset to relate national survey spending data with implan spending categories
#' prepared from `system.file("extdata", "implan-categories.xlsx", package = "implan")`
#'
#' @format A data frame with 46 rows and 4 columns"
#' \describe{
#'   \item{spend_type}{"trip" or "equip"}
#'   \item{item}{food, lodge, etc.}
#'   \item{category}{implan spending category}
#'   \item{share}{category share for item}
#' }
#' @family data
"categories"

#' Implan total hunting spending
#'
#' A dataset that defines spending in the format of national survey data prepared
#' from `system.file("extdata", "spend2019.rds", package = "implan")`
#'
#' @format A data frame with 46 rows and 3 columns"
#' \describe{
#'   \item{spend_type}{"trip" or "equip"}
#'   \item{item}{food, lodge, etc.}
#'   \item{spend}{total spending}
#' }
#' @family data
"spending"
