# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
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
