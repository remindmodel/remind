# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("GAMS code follows the coding etiquette", {
  # have to run this via localSystem2 so that it uses the renv, where gms
  # is actually installed.
  codecheckcode <- "'options(warn = 1); invisible(gms::codeCheck(strict = TRUE));'"
  output <- localSystem2("Rscript", c("-e", codecheckcode))
  printIfFailed(output)
  expectSuccessStatus(output)
})

test_that("No four asterisks in code", {
  notavailable <- Sys.which("grep") == ""
  if (notavailable) {
    skip("'grep' not available, please check yourself whether code starts with four asterisks.")
  } else {
    files <- paste0("../../", c("*.gms", "core/*.gms", "modules/*.gms", "modules/*/*.gms", "modules/*/*/*.gms"))
    grepcode <- paste("grep", "'^\\*\\*\\*\\*'", paste(files, collapse = " "))
    starlines <- suppressWarnings(system(grepcode, intern = TRUE))
    if (length(starlines) > 0) {
      warning("The following lines start with four asterisks, reserved for GAMS error messages.\n",
              paste(starlines, collapse = "\n"))
    }
    expect_true(length(starlines) == 0)
  }
})
