# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

configureCfg <- function(icfg, iscen, iscenarios, verboseGamsCompile = TRUE) {
    # Define colors for output
    red   <- "\033[0;31m"
    green <- "\033[0;32m"
    NC    <- "\033[0m"   # No Color

    # Edit run title
    icfg$title <- iscen
    if (verboseGamsCompile) message("   Configuring cfg for ", iscen)

    # Edit main model file, region settings and input data revision based on scenarios table, if cell non-empty
    for (switchname in intersect(c("model", setdiff(names(icfg), c("gms", "output"))), names(iscenarios))) {
      if ( ! is.na(iscenarios[iscen, switchname] )) {
        icfg[[switchname]] <- iscenarios[iscen, switchname]
      }
    }
    if (icfg$slurmConfig %in% paste(seq(1:16)) & ! any(c("--debug", "--gamscompile", "--quick", "--testOneRegi") %in% flags)) {
      icfg$slurmConfig <- choose_slurmConfig(identifier = icfg$slurmConfig)
    }
    if (icfg$slurmConfig %in% c(NA, ""))       {
      if(! exists("slurmConfig")) slurmConfig <- choose_slurmConfig()
      icfg$slurmConfig <- slurmConfig
    }

    # Set description
    if ("description" %in% names(iscenarios) && ! is.na(iscenarios[iscen, "description"])) {
      icfg$description <- iconv(gsub('"', '', iscenarios[iscen, "description"]), from = "UTF-8", to = "ASCII//TRANSLIT")
    } else {
      icfg$description <- paste0("REMIND run ", iscen, " started by ", config.file, ".")
    }

    # Set reporting script
    if ("output" %in% names(iscenarios) && ! is.na(iscenarios[iscen, "output"])) {
      scenoutput <- gsub('c\\("|\\)|"', '', trimws(unlist(strsplit(iscenarios[iscen, "output"], split = ','))))
      icfg$output <- unique(c(if ("cfg$output" %in% scenoutput) icfg$output, setdiff(scenoutput, "cfg$output")))
    }  

    # Edit switches in config based on scenarios table, if cell non-empty
    for (switchname in intersect(names(icfg$gms), names(iscenarios))) {
      if ( ! is.na(iscenarios[iscen, switchname] )) {
        icfg$gms[[switchname]] <- iscenarios[iscen, switchname]
      }
    }

    # didremindfinish is TRUE if full.log exists with status: Normal completion
    didremindfinish <- function(fulldatapath) {
      logpath <- paste0(str_sub(fulldatapath,1,-14),"/full.log")
      return( file.exists(logpath) && any(grep("*** Status: Normal completion", readLines(logpath, warn = FALSE), fixed = TRUE)))
    }

    if (verboseGamsCompile) {
      # for columns path_gdx…, check whether the cell is non-empty, and not the title of another run with start = 1
      # if not a full path ending with .gdx provided, search for most recent folder with that title
      if (any(iscen %in% iscenarios[iscen, setdiff(names(path_gdx_list), "path_gdx")])) {
        stop("Self-reference: ", iscen , " refers to itself in a path_gdx... column.")
      }
      # if a scenario is referenced that is not in the list of scenarios to be started, try to find a gdx automatically
      for (path_to_gdx in names(path_gdx_list)) {
        if (!is.na(iscenarios[iscen, path_to_gdx]) & ! iscenarios[iscen, path_to_gdx] %in% setdiff(row.names(iscenarios), iscen)) {
          if (! str_sub(iscenarios[iscen, path_to_gdx], -4, -1) == ".gdx") {
            # search for fulldata.gdx in output directories starting with the path_to_gdx cell content.
            # may include folders that only _start_ with this string. They are sorted out later.
            dirfolders <- unique(c(dirname(icfg$results_folder), "output", icfg$modeltests_folder))
            for (dirfolder in dirfolders) {
              dirs <- Sys.glob(file.path(dirfolder, paste0(iscenarios[iscen, path_to_gdx], "*/fulldata.gdx")))
              # if path_to_gdx cell content exactly matches folder name, use this one
              if (file.path(dirfolder, iscenarios[iscen, path_to_gdx], "fulldata.gdx") %in% dirs) {
                message(paste0("   For ", path_to_gdx, " = ", iscenarios[iscen, path_to_gdx], ", a folder with fulldata.gdx was found."))
                iscenarios[iscen, path_to_gdx] <- file.path(dirfolder, iscenarios[iscen, path_to_gdx], "fulldata.gdx")
                if (dirfolder == icfg$modeltests_folder) modeltestRunsUsed <<- modeltestRunsUsed + 1
              } else {
                # sort out unfinished runs and folder names that only _start_ with the path_to_gdx cell content
                # for folder names only allows: cell content, _, datetimepattern
                datetimepattern <- "[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}\\.[0-9]{2}\\.[0-9]{2}"
                dirs <- dirs[unlist(lapply(dirs, didremindfinish)) & grepl(paste0(iscenarios[iscen, path_to_gdx],"_", datetimepattern, "/fulldata.gdx"), dirs)]
                # if anything found, pick latest
                if(length(dirs) > 0 && ! all(is.na(dirs))) {
                  lapply(dirs, str_sub, -32, -14) %>%
                    strptime(format='%Y-%m-%d_%H.%M.%S') %>%
                    as.numeric %>%
                    which.max -> latest_fulldata
                  msg_latest <- gsub(file.path("", "fulldata.gdx"), "",
                                     gsub(file.path(dirname(icfg$results_folder), ""), "", dirs[latest_fulldata], fixed = TRUE), fixed = TRUE)
                  message(paste0("   Use newest normally completed run for ", path_to_gdx, " = ", iscenarios[iscen, path_to_gdx],
                                 ":\n     ", msg_latest))
                  iscenarios[iscen, path_to_gdx] <- dirs[latest_fulldata]
                  if (dirfolder == icfg$modeltests_folder) modeltestRunsUsed <<- modeltestRunsUsed + 1
                }
              }
            }
          }
          # if the above has not created a path to a valid gdx, stop
          if (!file.exists(iscenarios[iscen, path_to_gdx])) {
            if (   path_to_gdx == "path_gdx"
                && iscenarios[iscen, path_to_gdx] == iscen) {
              iscenarios[iscen, path_to_gdx] <- NA
            } else {
              icfg$errorsfoundInConfigureCfg <- sum(icfg$errorsfoundInConfigureCfg, 1)
              message(red, "Error", NC, ": Can't find a gdx specified as '", iscenarios[iscen, path_to_gdx], "' in column ",
                      path_to_gdx, ".\nPlease specify full path to gdx or name of output subfolder that contains a ",
                      "fulldata.gdx from a previous normally completed run.")
            }
          }
        }
      }
    }
    
    # Define path where the GDXs will be taken from
    gdxlist <- unlist(iscenarios[iscen, names(path_gdx_list)])
    names(gdxlist) <- path_gdx_list
    
    # if MAgPIE coupled prepend 'C_' to name of reference scenarios
    if(icfg$gms$cm_MAgPIE_Nash > 0) {
      gdxlist[gdxlist %in% rownames(iscenarios)] <- paste0("C_", gdxlist[gdxlist %in% rownames(iscenarios)])
    }

    # add gdxlist to list of files2export
    icfg$files2export$start <- c(icfg$files2export$start, gdxlist, config.file)

    # add table with information about runs that need the fulldata.gdx of the current run as input
    icfg$RunsUsingTHISgdxAsInput <- iscenarios %>% select(contains("path_gdx")) %>%              # select columns that have "path_gdx" in their name
                                                   filter(rowSums(. == iscen, na.rm = TRUE) > 0) # select rows that have the current scenario in any column
                                                   
    # For coupled runs add "C_" to scenario names
    if(nrow(icfg$RunsUsingTHISgdxAsInput) > 0 & icfg$gms$cm_MAgPIE_Nash > 0) {
      selection <- !is.na(icfg$RunsUsingTHISgdxAsInput)
      icfg$RunsUsingTHISgdxAsInput[selection] <- paste0("C_", icfg$RunsUsingTHISgdxAsInput[selection])
      rownames(icfg$RunsUsingTHISgdxAsInput) <- paste0("C_", rownames(icfg$RunsUsingTHISgdxAsInput))
    }

    return(icfg)
}
