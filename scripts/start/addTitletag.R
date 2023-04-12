#' Append titletag to scenario names in the scenario title and titles of reference scenarios
#'
#' @param titletag the tag that will be appended
#' @param scenarios dataframe with scenarios which will be modified
#' @author Mika Pflüger, Baseer Baheer
#' @return dataframe, scenarios but with modified titles

addTitletag <- function (titletag, scenarios) {
  oldNames <- row.names(scenarios)
  for (c in names(path_gdx_list)) {
    if (c %in% names(scenarios)) {
      column <- scenarios[[c]]
      selection <- column %in% oldNames
      scenarios[[c]][selection] <- paste0(column[selection], "-", titletag)
    }
  }
  row.names(scenarios) <- paste0(oldNames, "-", titletag)
  return(scenarios)
}
