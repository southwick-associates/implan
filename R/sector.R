# functions to get spending by implan sector

#' Update sectoring scheme with crosswalk table
#'
#' @param sectors_old data frame that holds spending by old sector
#' @param crosswalk data frame for converting between new and old sectors
#' @param description_new data frame that contains descriptions for new sectors
#' @param id_old id_old variable name for the old sector id
#' @param id_new variable name for the new sector id
#' @family functions to get spending by implan sector
#' @export
sector_update <- function(
    sectors_old, crosswalk, description_new,
    id_old = "sector536", id_new = "sector546"
) {
    new <- sectors_old %>%
        select(-.data$description) %>%
        left_join(crosswalk, by = c("group", id_old)) %>%
        mutate(share = .data$share * .data$crosswalk_ratio)
    new$sector <- new[[id_new]]
    new[[id_old]] <- NULL
    new[[id_new]] <- NULL
    new$crosswalk_ratio <- NULL
    left_join(new, description_new, by = c("group", "sector"))
}
