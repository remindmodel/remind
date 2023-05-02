# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("start.R fails on missing path_gdx* files", {
  csvfile <- tempfile(pattern = "scenario_config_a", fileext = ".csv")
  writeLines(c(";start;slurmConfig;path_gdx;path_gdx_carbonprice",
               "somearbitraryruntitle;1;8;whateverstring.noonewilluse_;another.unusedstring_"),
               con = csvfile, sep = "\n")
  output <- localSystem2("Rscript", c("start.R", "--test", csvfile))
  unlink("../../somearbitraryruntitle.RData")
  expect_true(any(grepl("2 errors were identified", output)))
  expectFailStatus(output)
})
