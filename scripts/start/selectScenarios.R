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
