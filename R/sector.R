# functions to get spending by implan sector

#' Update sectoring scheme with crosswalk table
#'
#' @param scheme_old data frame that holds old sectoring scheme
#' @param crosswalk data frame for converting between new and old sectors
#' @param description_new data frame that contains descriptions for new sectors
#' @param id_old id_old variable name for the old sector id
#' @param id_new variable name for the new sector id
#' @family functions to get spending by implan sector
#' @export
#' @examples
#' # load sample data
#' data(category_to_sector536, sector536_to_sector546, sectors546)
#'
#' # check the sector allocation for the 536 sector scheme (should be TRUE)
#' check_share_sums(category_to_sector536, share, category)
#'
#' # update to 546 sector scheme and check
#' category_to_sector546 <- sector_update(category_to_sector536, sector536_to_sector546, sectors546)
#' check_share_sums(category_to_sector546, share, category)
sector_update <- function(
    scheme_old, crosswalk, description_new,
    id_old = "sector536", id_new = "sector546"
) {
    scheme_old[[id_old]] <- scheme_old$sector
    new <- scheme_old %>%
        select(-.data$description, -.data$sector) %>%
        left_join(crosswalk, by = c("group", id_old)) %>%
        mutate(share = .data$share * .data$crosswalk_ratio)
    new$sector <- new[[id_new]]
    new[[id_old]] <- NULL
    new[[id_new]] <- NULL
    new$crosswalk_ratio <- NULL
    left_join(new, description_new, by = c("group", "sector"))
}

#' Check whether the share variable sums to 100 percent
#'
#' @param df input data frame
#' @param sharevar unquoted name of variable that identifies share
#' @param ... unquoted variables to use as dimensions (that defines share allocation)
#' @family functions to get spending by implan sector
#' @export
#' @examples
#' # see ?sector_update()
check_share_sums <- function(df, sharevar, ...) {
    sharevar <- enquo(sharevar)
    dims <- enquos(...)
    x <- group_by(df, !!! dims) %>% summarise(share = sum( !! sharevar))
    all.equal(x$share, rep(1, nrow(x)))
}

#' Check whether reallocated spending retains the correct sum
#'
#' @param df_old data frame with spending before reallocation
#' @param df_new data frame with spending post-reallocation
#' @param spendvar unquoted name of spending variable
#' @param ... unquoted variables to use as grouping dimension
#' @family functions to get spending by implan sector
#' @export
#' @examples
#' # see ?input_prep()
check_spend_sums <- function(df_old, df_new, spendvar, ...) {
    spendvar <- enquo(spendvar)
    dims <- enquos(...)
    x <- group_by(df_old, !!! dims) %>% summarise(spend = sum(!! spendvar))
    y <- group_by(df_new, !!! dims) %>% summarise(spend = sum(!! spendvar))
    all.equal(x$spend, y$spend)
}

