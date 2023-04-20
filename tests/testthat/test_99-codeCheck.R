# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("GAMS code follows the coding etiquette", {
  # have to run this via localSystem2 so that it uses the renv, where gms
  # is actually installed.
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("-e", "'invisible(gms::codeCheck(strict=TRUE))'"))
  printIfFailed(output)
  expectSuccessStatus(output)
})
