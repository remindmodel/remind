test_that("manipulate config with default configuration does not change main.gms", {
  # copy main file and manipulate it based on default settings
  cfg_init <- gms::readDefaultConfig("../..")
  tmpfile <- tempfile(pattern = "main-TESTTHAT-", tmpdir = "../..", fileext = ".gms")
  file.copy("../../main.gms", tmpfile)

  # generate arbitrary settings, manipulate file, read them again and check identity
  cfg_new <- cfg_init
  cfg_new$gms[names(cfg_new$gms)] <- rep(c(0, 1, "asdf", "bc3", "3bc"), length(cfg_new$gms))[1:length(cfg_new$gms)]
  lucode2::manipulateConfig(tmpfile, cfg_new$gms)
  cfg_new_after <- gms::readDefaultConfig("../..", basename(tmpfile))
  expect_equal(cfg_new_after, cfg_new)

  # reset to initial setting and check that nothing has changed at all in the file
  lucode2::manipulateConfig(tmpfile, cfg_init$gms)
  cfg_after <- gms::readDefaultConfig("../..", basename(tmpfile))

  # check diff
  diffresult <- NULL
  diffavailable <- ! Sys.which("diff") == ""
  if (diffavailable) {
    diffresult <- suppressWarnings(system(paste("diff ../../main.gms", tmpfile), intern = TRUE))
    if (length(diffresult) > 0) {
      warning("Applying manipulateConfig with the default configuration leads to this diff between main.gms and ",
              basename(tmpfile), ":\n",
              paste(diffresult, collapse = "\n"))
    }
    expect_equal(length(diffresult), 0)
  }

  # check for switches missing in the new cfg
  removedgms <- setdiff(names(cfg_init$gms), names(cfg_after$gms))
  if (length(removedgms) > 0) {
    warning("These cfg$gms switches can't be found after manipulation of main.gms, see ", basename(tmpfile), ".\n",
            "Please file an issue in the gms package and try to adjust the code until the error goes away:\n",
            paste("-", removedgms, collapse = "\n"))
  }
  expect_length(removedgms, 0)

  # check for switches added to the new cfg
  addedgms <- setdiff(names(cfg_after$gms), names(cfg_init$gms))
  if (length(addedgms) > 0) {
    warning("These cfg$gms switches were somehow added by manipulateConfig to main.gms, see ", basename(tmpfile), ".\n",
            "Please file an issue in the gms package and try to adjust the code until the error goes away:\n",
            paste("-", addedgms, collapse = "\n"))
  }
  expect_length(addedgms, 0)

  # check for switches with different content between old and new cfg
  joinednames <- intersect(names(cfg_after$gms), names(cfg_init$gms))
  contentdiff <- joinednames[! unlist(cfg_init$gms[joinednames]) == unlist(cfg_after$gms[joinednames])]
  if (length(contentdiff) > 0) {
    warning("After file manipulation, the following cfg$gms switches differ, see ", basename(tmpfile), ":\n",
            paste0("- ", contentdiff, ": ", unlist(cfg_init$gms[contentdiff]), " -> ", unlist(cfg_after$gms[contentdiff]), collapse = "\n"))
  }
  expect_length(contentdiff, 0)

  # cleanup if no error found
  if (length(addedgms) + length(removedgms) + length(contentdiff) + length(diffresult) == 0) {
    file.remove(list.files(path = "../..", pattern = "main-TESTTHAT.*gms", full.names = TRUE))
  }
})
