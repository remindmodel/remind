# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
#' select scenarios to run from a scenario config file based on command line arguments
#'
#' @param settings the dataframe of scenarios read from the config file
#' @param interactive should we ask the user which scenarios to start
#' @param startgroup user-provided group of scenarios which should be started
#' @author Mika Pflüger, Baseer Baheer
#' @return dataframe with scenarios from settings which should be started

selectScenarios <- function (settings, interactive, startgroup) {
    scenariosInGroup <- grepl(paste0("(^|,)", startgroup, "($|,)"), as.character(settings$start), perl = TRUE)
    if (interactive | ! any(scenariosInGroup)) {
      scenariosInGroup <- gms::chooseFromList(setNames(rownames(settings), settings$start), type = "runs", returnBoolean = TRUE)
    }
    return(settings[scenariosInGroup, ])
}
