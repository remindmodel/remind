# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

suppressPackageStartupMessages(library(tidyverse))

lucode2::readArgs("outputdirs")

gdxs    <- file.path(outputdirs, "fulldata.gdx")
configs <- file.path(outputdirs, "config.Rdata")
scens   <- lucode2::getScenNames(outputdirs)
if (length(unique(scens)) < length(outputdirs)) {
  stop("Sorry, I cannot run with multiple scenarios of the same name.")
}

mifs    <- file.path(outputdirs, paste0("REMIND_generic_", scens, ".mif"))

d <- quitte::as.quitte(mifs)

dout <- NULL

for (i in seq_along(outputdirs)) {
  envi <- new.env()
  load(configs[[i]], env =  envi)
  title <- envi$cfg$title
  stopifnot(title == scens[[i]])
  inputref <- envi$cfg$files2export$start[["input_ref.gdx"]]
  inputref <- gsub("_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}\\.[0-9]{2}\\.[0-9]{2}", "", basename(dirname(inputref)))
  startyear <- envi$cfg$gms$cm_startyear
  if (! inputref %in% levels(d$scenario)) {
    inputref <- gms::chooseFromList(levels(d$scenario), type = paste("scenario to fix", title, "on"), multiple = FALSE,
                     userinfo = paste0("For scenario '", title, "', no scenario ", inputref, " to fix on found, please select one."))
  }
  message("Comparing ", title, " with reference run ", inputref, " for t < ", startyear)
  mismatches <- d %>%
    filter(period <= startyear, scenario %in% c(title, inputref)) %>%
    group_by(model, region, variable, unit, period) %>%
    filter(0 != var(value)) %>%
    ungroup() %>%
    distinct(variable, period) %>%
    group_by(variable) %>%
    summarise(period = paste(sort(period), collapse = ', '))
  if (nrow(mismatches) == 0) {
    message("All fine!")
  } else {
    print(mismatches, n = 30)
    message("Do you want to fix that by overwriting ", title, " with reference run ", inputref, " for t < ", startyear, "? y/N")
    if (tolower(gms::getLine()) %in% c("y", "yes")) {
      di <- rbind(
          filter(d, scenario == title, period >= startyear),
          mutate(filter(d, scenario == inputref, period < startyear), scenario = title)
      )
      quitte::write.mif(di, paste0(mifs[[i]], "test"))
    }
  }
}
