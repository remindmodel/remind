# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

run <- function() {

  load("config.Rdata")

  # Save start time
  timeGAMSStart <- Sys.time()

  # De-compress fixing files if they have already been zipped (only valid if run is restarted)
  if (cfg$gms$cm_startyear > 2005) {
      if (file.exists("levs.gms.gz")) {
        cat("Unzip fixing files\n")
        system("gzip -d -f levs.gms.gz margs.gms.gz fixings.gms.gz")
      } else if (file.exists("levs.gms")) {
        cat("Found unzipped fixing files. Using them.\n")
      } else {
        stop("cm_startyear > 2005 but no fixing files found, neither zipped or unzipped.")
      }
  }

  # Print message
  cat("\nStarting REMIND...\n")
  cat("GAMS will provide logging in full.log.\n")

  # Call GAMS
  if (cfg$gms$CES_parameters == "load") {

    system(paste0(cfg$gamsv, " full.gms -errmsg=1 -a=", cfg$action,
                  " -ps=0 -pw=185 -pc=2 -gdxcompress=1 -holdFixedAsync=1 -logoption=", cfg$logoption))

  } else if (cfg$gms$CES_parameters == "calibrate") {

    # Remember file modification time of fulldata.gdx to see if it changed
    fulldata_m_time <- Sys.time();

    # Save original input
    file.copy("input.gdx", "input_00.gdx", overwrite = TRUE)

    # Iterate calibration algorithm
    for (cal_itr in 1:cfg$gms$c_CES_calibration_iterations) {
      cat("CES calibration iteration: ", cal_itr, "\n")

      # Update calibration iteration in GAMS file
      Sys.setenv(cm_CES_calibration_iteration = cal_itr)

      system(paste0(cfg$gamsv, " full.gms -errmsg=1 -a=", cfg$action,
                    " -ps=0 -pw=185 -pc=2 -gdxcompress=1 -holdFixedAsync=1 -logoption=", cfg$logoption))

      # If GAMS found a solution
      if (   file.exists("fulldata.gdx")
          && file.info("fulldata.gdx")$mtime > fulldata_m_time) {

        #create the file to be used in the load mode
        getLoadFile <- function(){

          file_name = sprintf('%s_ITERATION_%02i.inc',
                              cfg$gms$cm_CES_configuration, cal_itr)
          ces_in = system("gdxdump fulldata.gdx symb=in NoHeader Format=CSV", intern = TRUE) %>% gsub("\"","",.) #" This comment is just to obtain correct syntax highlighting
          expr_ces_in = paste0("(",paste(ces_in, collapse = "|") ,")")


          tmp = system("gdxdump fulldata.gdx symb=pm_cesdata", intern = TRUE)[-(1:2)] %>%
            grep("(quantity|price|eff|effgr|xi|rho|offset_quantity|compl_coef)", x = ., value = TRUE)
          tmp = tmp %>% grep(expr_ces_in,x = ., value = T)

          tmp %>%
            sub("'([^']*)'.'([^']*)'.'([^']*)'.'([^']*)' (.*)[ ,][ /];?",
                "pm_cesdata(\"\\1\",\"\\2\",\"\\3\",\"\\4\") = \\5;", x = .) %>%
            write(file_name)
        } 
        getLoadFile()

        # Store all the interesting output
        interestingOutput <- c("full.lst", "full.log", "fulldata.gdx", "non_optimal.gdx", "abort.gdx")
        file.copy(from = interestingOutput,
                  to = sub("^(.*)(\\.[^\\.]+)$",
                           sprintf("\\1_%02i\\2", cal_itr),
                           interestingOutput),
                  overwrite = TRUE,
                  copy.date = TRUE)
        file.copy("fulldata.gdx", "input.gdx", overwrite = TRUE)
        if (cal_itr < as.integer(cfg$gms$c_CES_calibration_iterations)) {
          unlink(c("abort.gdx", "non_optimal.gdx"))
        } else { # calibration was successful
          file.copy("fulldata.gdx", paste0(cfg$gms$cm_CES_configuration, ".gdx"))
          file.copy(from = sprintf('%s_ITERATION_%02i.inc',
                                   cfg$gms$cm_CES_configuration, cal_itr),
                    to = paste0(cfg$gms$cm_CES_configuration, ".inc"))
        }

        # Update file modification time
        fulldata_m_time <- file.info("fulldata.gdx")$mtime
      } else {
        break
      }
    }
  } else {
    stop("unknown realisation of 29_CES_parameters")
  }

  # Calculate run time statistics
  timeGAMSEnd  <- Sys.time()
  gams_runtime <- timeGAMSEnd - timeGAMSStart
  timeOutputStart <- Sys.time()

  # If REMIND actually did run
  if (cfg$action == "ce" && cfg$gms$c_skip_output != "on") {

    # Print Message.
    cat("\nREMIND run finished!\n\n")

    # Create solution report for Nash runs
    if (cfg$gms$optimization == "nash" && cfg$gms$cm_nash_mode != 1 && file.exists("fulldata.gdx")) {
      system("gdxdump fulldata.gdx Format=gamsbas Delim=comma Output=output_nash.gms")
      file.append("full.lst", "output_nash.gms")
      file.remove("output_nash.gms")
    }
  }
  if (cfg$action == "c") {
    cat("\nREMIND was compiled but not executed, because cfg$action was set to 'c'\n\n")
  }

  #====================== Model summary ===========================

  modelSummaryData <- modelSummary(".", gams_runtime)

  message("\nCollect and submit run statistics to central data base.")
  lucode2::runstatistics(file       = "runstatistics.rda",
                         modelstat  = modelSummaryData[["modelstat"]],
                         config     = cfg,
                         runtime    = gams_runtime,
                         setup_info = lucode2::setup_info(),
                         submit     = cfg$runstatistics,
                         timeGAMSStart = timeGAMSStart,
                         timeGAMSEnd   = timeGAMSEnd
  )

  if (modelSummaryData[["stoprun"]]) {
    stop("GAMS did not complete its run, so stopping here:\n       No output is generated, no subsequent runs are started.\n",
         "       See the debugging tutorial at https://github.com/remindmodel/remind/blob/develop/tutorials/10_DebuggingREMIND.md")
  }

  # Compress files with the fixing-information
  if (cfg$gms$cm_startyear > 2005)
    system("gzip -f levs.gms margs.gms fixings.gms")

  # go up to the main folder, where the cfg files for subsequent runs are stored and the output scripts are executed from
  setwd(cfg$remind_folder)
  on.exit(setwd(cfg$results_folder))

  #====================== Subsequent runs ===========================

  # Use the name to check whether it is a coupled run (TRUE if the name ends with "-rem-xx")
  coupled_run <- grepl("-rem-[0-9]{1,2}$",cfg$title)
  # Don't start subsequent runs form here if REMIND runs coupled. They are started in start_coupled.R instead.
  # Only if this run has been restarted manually cfg$restart_subsequent_runs is TRUE. If the run is resumed after
  # preemtion it is just NULL and isFALSE(NULL) is FALSE, so subsequent standalone runs will be started.
  start_subsequent_runs <- ! isFALSE(cfg$restart_subsequent_runs) && ! coupled_run

  if (start_subsequent_runs & (length(rownames(cfg$RunsUsingTHISgdxAsInput)) > 0)) {
    # track whether any subsequent run was actually started
    started_any_subsequent_run <- FALSE

    # Save the current cfg settings into a different data object, so that they are not overwritten
    cfg_main <- cfg

    # fulldatapath may be written into gdx paths of subsequent runs
    fulldatapath <- paste0(cfg_main$remind_folder,"/",cfg_main$results_folder,"/fulldata.gdx")
    possible_pathes_to_gdx <- c("input.gdx", "input_ref.gdx", "input_refpolicycost.gdx", "input_bau.gdx", "input_carbonprice.gdx")

    # Loop possible subsequent runs, saving path to fulldata.gdx of current run (== cfg_main$title) to their cfg files

    for (run in rownames(cfg_main$RunsUsingTHISgdxAsInput)) {
      message("\nPrepare subsequent run ", run, ":")
      RData_file <- paste0(run,".RData")
      load(RData_file)

      pathes_to_gdx <- intersect(possible_pathes_to_gdx, names(cfg$files2export$start))

      gdx_na <- is.na(cfg$files2export$start[pathes_to_gdx])
      needfulldatagdx <- names(cfg$files2export$start[pathes_to_gdx][cfg$files2export$start[pathes_to_gdx] == cfg_main$title & !gdx_na])
      if (length(needfulldatagdx) == 0) {
        message("Somehow, my gdx file was not needed although cfg$RunsUsingTHISgxAsInput expected that. Skipping ", run)
        next
      }
      message("In ", RData_file, ", use current fulldata.gdx path for ", paste(needfulldatagdx, collapse = ", "), ".")
      cfg$files2export$start[needfulldatagdx] <- fulldatapath
      # let the subsequent run use the renv.lock of this run
      message("In ", RData_file, ", use current renv.lock for subsequent run ", run, ".")
      cfg$renvLockFromPrecedingRun <- file.path(cfg_main$remind_folder, cfg_main$results_folder, "renv.lock")

      save(cfg, file = RData_file)

      # Subsequent runs will be started using submit.R, if all necessary gdx files were generated
      gdx_exist <- grepl(".gdx", cfg$files2export$start[pathes_to_gdx])

      if (all(gdx_exist | gdx_na)) {
        message("Starting subsequent run ",run)
        source("scripts/start/submit.R")
        submit(cfg)
        started_any_subsequent_run <- TRUE
      } else {
        message(run, " is still waiting for: ",
        paste(unique(cfg$files2export$start[pathes_to_gdx][!(gdx_exist | gdx_na)]), collapse = ", "), ".")
      }
    } # end of loop through possible subsequent runs

    # Set cfg back to original
    cfg <- cfg_main

    # Create script file that can be used later to restart the subsequent runs manually.
    # In case there are no subsequent runs (or it's coupled runs), the file contains only
    # a small message.

    subseq_start_file  <- paste0(cfg$results_folder,"/start_subsequentruns_manually.R")

    if(!any(cfg$RunsUsingTHISgdxAsInput == cfg$title)) {
      write("cat('\nNo subsequent run was set for this scenario\n')", file=subseq_start_file)
    } else {
      #  go up to the main folder, where the cfg. files for subsequent runs are stored
      filetext <- paste0("setwd('",cfg$remind_folder,"')\n")
      filetext <- paste0(filetext,"source('scripts/start/submit.R')\n")
      for (run in rownames(cfg$RunsUsingTHISgdxAsInput)) {
        filetext <- paste0(filetext,"\n")
        filetext <- paste0(filetext,"load('",run,".RData')\n")
        #filetext <- paste0(filetext,"cfg$results_folder <- 'output/:title::date:'\n")
        filetext <- paste0(filetext,"cat('",run,"')\n")
        filetext <- paste0(filetext,"submit(cfg)\n")
      }
      # Write the text to the file
      write(filetext, file=subseq_start_file)
    }
  } else {
    message("\nDid not try to start subsequent runs.\n")
  }

  #=================== END - Subsequent runs ========================

  # Copy important files into output_folder (after REMIND execution)
  for (file in cfg$files2export$end)
    file.copy(file, cfg$results_folder, overwrite = TRUE)

  # Set source_include so that loaded scripts know they are included as
  # source (instead of being executed from the command line)
  source_include <- TRUE

  # Postprocessing / Output Generation
  output    <- cfg$output
  outputdir <- cfg$results_folder

  # make sure the renv used for the run is also used for generating output
  if (!is.null(renv::project())) {
    if (normalizePath(renv::project()) != normalizePath(outputdir)) {
      warning("loaded renv=", normalizePath(renv::project()), " and outputdir=", normalizePath(outputdir), " must be equal.")
    }
    message("Using ", normalizePath(renv::project()), " as renv project")
    argv <- c(get0("argv"), paste0("--renv=", renv::project()))
  }

  sys.source("output.R",envir=new.env())
  # get runtime for output
  timeOutputEnd <- Sys.time()

  # Save run statistics to local file
  cat("\nSaving timeOutputStart and timeOutputEnd to runstatistics.rda\n")
  lucode2::runstatistics(file           = paste0(cfg$results_folder, "/runstatistics.rda"),
                       timeOutputStart = timeOutputStart,
                       timeOutputEnd   = timeOutputEnd)

  return(cfg$results_folder)
  # on.exit sets working directory back to results folder

}
