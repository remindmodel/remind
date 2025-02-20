# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

skipIfFast()
coupledConfig <- "config/tests/scenario_config_coupled_shortCascade.csv"
magpie_folder <- "../../magpie"
if (! dir.exists(magpie_folder)) magpie_folder <- paste0("../", magpie_folder)
config <- readCheckScenarioConfig(file.path("..", "..", coupledConfig), remindPath <- file.path("..", ".."))
max_iterations <- if ("max_iterations" %in% names(config)) max(config$max_iterations) else 5
# for a fresh run, delete all left-overs from previous test
deleteallfiles <- paste0("C_TESTTHAT_startlog_", seq(6), ".txt")
Rprofile <- ".Rprofile"
for (scen in rownames(config)) {
  deleteallfiles <- c(deleteallfiles,
    paste0("../../output/C_", scen, "-rem-", seq(max_iterations)),
    paste0("../../output/C_", scen, ".mif"),
    paste0("../../C_", scen, "-rem-", seq(max_iterations), ".RData"),
    paste0("../../output/gamscompile/main_", scen, ".gms"),
    paste0("../../output/gamscompile/main_", scen, ".lst"),
    file.path(magpie_folder, paste0("output/C_", scen, "-mag-", seq(max_iterations - 1)))
  )
}
expect_true(0 == unlink(deleteallfiles, recursive = TRUE, force = TRUE))

test_that("environment is suitable for coupled tests", {
  skipIfPreviousFailed()
  # magpie needs to be cloned by the user before running coupled tests
  expect_true(dir.exists(magpie_folder))
  # coupled tests need slurm
  expect_true(isSlurmAvailable())
})

test_that("using start_bundle_coupled.R --gamscompile works", {
  skipIfPreviousFailed()
  # try compiling
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", "--gamscompile", coupledConfig, "startgroup=1"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  printIfFailed(output)
  expectSuccessStatus(output)
  for (scen in rownames(config)[config$start == 1]) {
    expect_true(any(grepl(paste0("Compiling C_", scen), output)))
    expect_true(any(grepl(paste0(" OK .*", scen), output)))
    expectedFiles <- c(
      paste0("../../output/gamscompile/main_", scen, ".gms"),
      paste0("../../output/gamscompile/main_", scen, ".lst")
    )
    expect_true(all(file.exists(expectedFiles)))
  }
  expect_true(sum(grepl("REMIND and MAgPIE were never started", output)) == length(rownames(config)[config$start == 1]))
})

test_that("using start_bundle_coupled.R --test works", {
  skipIfPreviousFailed()
  # just test the settings and RData files are written
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", "--test", coupledConfig, "startgroup=1"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  printIfFailed(output)
  expectSuccessStatus(output)
  expect_true(any(grepl("TEST or gamscompile mode", output)))
  expect_true(any(grepl("NOT submitted", output)))
  for (scen in rownames(config)[config$start == 1]) {
    expect_true(any(grepl(paste0("starting with C_", scen, "-rem-1"), output)))
  }
})

test_that("runs coupled to MAgPIE work", {
  skipIfPreviousFailed()
  # try running actual runs
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", coupledConfig, "startgroup=1"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  printIfFailed(output)
  expectSuccessStatus(output)
  expect_true(xor("Copied REMIND .Rprofile to MAgPIE folder." %in% output,
                  any(grepl("^Finding R package dependencies.*Done.", output))))
  for (scen in rownames(config)[config$start == 1]) {
    expectedFiles <- c(
      paste0("../../output/C_", scen, "-rem-", seq(max_iterations)),
      paste0("../../output/C_", scen, ".mif"),
      paste0("../../C_", scen, "-rem-", seq(max_iterations), ".RData"),
      file.path(magpie_folder, paste0("output/C_", scen, "-mag-", seq(max_iterations - 1)))
    )
    expect_true(all(file.exists(expectedFiles)))
    # check -rem-1 config file
    configfile <- paste0("../../C_", scen, "-rem-1.RData")
    envir <- new.env()
    load(configfile, envir = envir)
    expect_true(envir$runname == paste0("C_", scen))
    expect_true(envir$fullrunname == paste0("C_", scen, "-rem-1"))
    expect_true(is.null(envir$path_report))
    expect_true(envir$max_iterations == max_iterations)
    expect_true(envir$magpie_empty)
    expect_true(envir$cfg_rem$RunsUsingTHISgdxAsInput[paste0("C_", scen, "-rem-2"), "path_gdx"] == envir$fullrunname)
    expect_true(envir$cfg_rem$gms$cm_nash_autoconverge == 1)
    # check config file for last rem iteration
    configfile <- paste0("../../C_", scen, "-rem-", max_iterations, ".RData")
    envir <- new.env()
    load(configfile, envir = envir)
    expect_true(envir$runname == paste0("C_", scen))
    expect_true(envir$fullrunname == paste0("C_", scen, "-rem-", max_iterations))
    expect_true(grepl(paste0("C_", scen), envir$path_report, fixed = TRUE))
    expect_true(envir$max_iterations == max_iterations)
    expect_true(envir$magpie_empty)
    if ("cm_nash_autoconverge_lastrun" %in% names(config)) {
      expect_true(envir$cfg_rem$gms$cm_nash_autoconverge == config[scen, "cm_nash_autoconverge_lastrun"])
    }
    # check path_mif_ghgprice_land
    if ("path_mif_ghgprice_land" %in% names(config)[config$start == 1]) {
      configfile <- paste0("../../C_", scen, "-rem-", (max_iterations - 1), ".RData")
      envir <- new.env()
      load(configfile, envir = envir)
      bothna <- is.na(envir$cfg_mag$path_to_report_ghgprices) && is.na(config[scen, "path_mif_ghgprice_land"])
      containsotherrun <- grepl(paste0("REMIND_generic_C_", config[scen, "path_mif_ghgprice_land"], "-rem-", (max_iterations - 1), ".mif"), envir$cfg_mag$path_to_report_ghgprices, fixed = TRUE)
      expect_true(bothna || containsotherrun)
      magpie_config <- file.path(magpie_folder, "output", paste0("C_", scen, "-mag-", (max_iterations - 1)), "config.yml")
      expect_true(file.exists(magpie_config))
      cfg_mag <- gms::loadConfig(magpie_config)
      if (bothna) {
        folder <- paste0("C_", scen, "-rem-", (max_iterations - 1))
        miffile <- normalizePath(file.path("../../output", folder, paste0("REMIND_generic_", folder, ".mif")), mustWork = FALSE)
        expect_identical(miffile, cfg_mag$path_to_report_ghgprices)
      } else {
        expect_true(identical(cfg_mag$path_to_report_ghgprices, envir$cfg_mag$path_to_report_ghgprices))
      }
    }
    # check subfolder mifs
    qscen <- quitte::as.quitte(paste0("../../output/C_", scen, "-rem-1/REMIND_generic_C_", scen, "-rem-1.mif"))
    expect_true(any(grepl("^REMIND", levels(qscen$model))))
    expect_false(any(grepl("^MAgPIE", levels(qscen$model))))
    lengthwithoutmag <- nrow(qscen)
    expect_true(lengthwithoutmag > 600000)
    qscen <- quitte::as.quitte(paste0("../../output/C_", scen, "-rem-", max_iterations, "/REMIND_generic_C_", scen, "-rem-", max_iterations, ".mif"))
    expect_true(any(grepl("^REMIND", levels(qscen$model))))
    expect_true(any(grepl("^MAgPIE", levels(qscen$model))))
    lengthwithmag <- nrow(qscen)
    expect_true(lengthwithmag > lengthwithoutmag && lengthwithmag > 700000)
    # check main mif
    qscen <- quitte::as.quitte(paste0("../../output/C_", scen, ".mif"))
    expect_no_warning(quitte::reportDuplicates(piamutils::deletePlus(qscen)))
    expect_true(all(grepl("^REMIND-MAgPIE", levels(qscen$model))))
    expect_true(nrow(qscen) == lengthwithmag)
    # here we could add checks which variables etc. must be in the mif file
  }
})

test_that("don't run again if completed", {
  skipIfPreviousFailed()
  # do not delete anything to simulate re-running already completed run
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", coupledConfig, "startgroup=1"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  printIfFailed(output)
  writeLines(output, "C_TESTTHAT_startlog_1.txt")
  expectSuccessStatus(output)
  expect_true(sum(grepl("This scenario is already completed", output)) == sum(config$start == 1))
  expect_false(any(grepl("Starting REMIND run", output)))
  expect_false(any(grepl("Starting MAgPIE run", output)))
})

test_that("delete last REMIND run to simulate re-starting aborted run", {
  skipIfPreviousFailed()
  scen <- rownames(config)[[2]]
  filestodelete <- c(
    paste0("../../output/C_", scen, "-rem-", max_iterations),
    paste0("../../output/C_", scen, "-", max_iterations, ".pdf"),
    paste0("../../output/C_", scen, ".mif")
  )
  expect_true(0 == unlink(filestodelete, recursive = TRUE, force = TRUE))
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", coupledConfig, "startgroup=1"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  writeLines(output, "C_TESTTHAT_startlog_2.txt")
  printIfFailed(output)
  expectSuccessStatus(output)
  expect_true(any(grepl(paste0("Starting REMIND run C_", scen, "-rem-", max_iterations), output)))
  expect_false(any(grepl("Starting MAgPIE run", output)))

  # delete the last MAgPIE, but not the last REMIND scenario and expect fail
  filestodelete <- file.path(magpie_folder, "output", paste0("C_", scen, "-mag-", (max_iterations - 1)))
  expect_true(0 == unlink(filestodelete, recursive = TRUE, force = TRUE))
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", coupledConfig, "startgroup=1"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  writeLines(output, "C_TESTTHAT_startlog_3.txt")
  expectFailStatus(output)
  expect_true(any(grepl("Something is wrong", output)))


  # also delete the last REMIND scenario so it must start with MAgPIE
  filestodelete <- c(
    paste0("../../output/C_", scen, "-rem-", max_iterations),
    paste0("../../output/C_", scen, "-", max_iterations, ".pdf"),
    paste0("../../output/C_", scen, ".mif")
  )
  expect_true(0 == unlink(filestodelete, recursive = TRUE, force = TRUE))
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", coupledConfig, "startgroup=1"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  printIfFailed(output)
  writeLines(output, "C_TESTTHAT_startlog_4.txt")
  expectSuccessStatus(output)

  expect_false(any(grepl("Starting REMIND run", output)))
  expect_true(any(grepl(paste0("Starting MAgPIE run C_", scen, "-mag-", (max_iterations - 1)), output)))

  # delete all REMIND, but not MAgPIE, and expect fail
  # when adjusting this, be careful because it is used at the end to determine files that need to exist
  filestodelete <- paste0("../../output/C_", scen, "-rem-", seq(max_iterations))
  expect_true(0 == unlink(filestodelete, recursive = TRUE, force = TRUE))
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", coupledConfig, "startgroup=1"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  writeLines(output, "C_TESTTHAT_startlog_5.txt")
  expectFailStatus(output)
  expect_true(any(grepl("Something is wrong", output)))
})

test_that("Check path_mif_ghgprice_land with file", {
  # note: needs Base-rem-1 and -2 still present
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("start_bundle_coupled.R --gamscompile", coupledConfig, "startgroup=2"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  printIfFailed(output)
  expectSuccessStatus(output)
  output <- localSystem2("Rscript", c("start_bundle_coupled.R", coupledConfig, "startgroup=2"),
                         env = paste0("R_PROFILE_USER=", Rprofile))
  writeLines(output, "C_TESTTHAT_startlog_6.txt")
  expectSuccessStatus(output)
  scen <- rownames(config)[config$start == 2][[1]]
  if ("path_mif_ghgprice_land" %in% names(config)) {
    configfile <- paste0("../../C_", scen, "-rem-", (max_iterations - 1), ".RData")
    envir <- new.env()
    load(configfile, envir = envir)
    expect_true(envir$cfg_mag$path_to_report_ghgprices == normalizePath(file.path("../..", config[scen, "path_mif_ghgprice_land"]), mustWork = FALSE))
    magpie_config <- file.path(magpie_folder, "output", paste0("C_", scen, "-mag-", (max_iterations - 1)), "config.yml")
    expect_true(file.exists(magpie_config))
    cfg_mag <- gms::loadConfig(magpie_config)
    expect_true(identical(cfg_mag$path_to_report_ghgprices, envir$cfg_mag$path_to_report_ghgprices))
  }
})

csvfiles <- system("git ls-files ../../config/scenario_config_coupled*.csv ../../config/*/scenario_config_coupled*.csv", intern = TRUE)
if (length(csvfiles) == 0) {
  csvfiles <- Sys.glob(c(file.path("../../config/scenario_config_coupled*.csv"),
                         file.path("../../config", "*", "scenario_config_coupled*.csv")))
}
csvfiles <- normalizePath(csvfiles)
test_that("coupled csv files found", {
  expect_true(length(csvfiles) > 0)
})

skipfiles <- c("scenario_config_coupled_shortCascade") # fails on missing mif file which is present while running other tests

for (csvfile in csvfiles) {
  test_that(paste("start_bundle_coupled.R --test succeeds on", basename(csvfile)), {
    skipIfPreviousFailed()
    skip_if(grepl(paste(skipfiles, collapse = "|"), csvfile), message = paste(csvfile, "skipped."))
    testthat::with_mocked_bindings(
      {
        output <- localSystem2("Rscript",
                               c("start_bundle_coupled.R", "--test", "startgroup=*", csvfile))
        printIfFailed(output)
        expectSuccessStatus(output)
      },
      getLine = function() stop("getLine should not called."),
      .package = "gms"
    )
    unlink("../../*TESTTHAT.RData", force = TRUE)
    expect_no_warning(config <- readCheckScenarioConfig(csvfile, remindPath <- file.path("..", "..")))
  })
}

test_that("delete files to leave clean state", {
  # leave clean state
  skipIfPreviousFailed()
  missingfiles <- setdiff(deleteallfiles[! file.exists(deleteallfiles)],
                          paste0("../../output/C_TESTTHAT-SSP2-NDC-rem-", seq(2)))
  if (length(missingfiles) > 0) {
    warning("files do not exist: ", paste(gsub("../.", "", missingfiles, fixed = TRUE), collapse = ", "))
    skip("Not cleaning up coupled tests as not all required files exist.")
  } else {
    expect_true(0 == unlink(deleteallfiles, recursive = TRUE, force = TRUE))
  }
})
