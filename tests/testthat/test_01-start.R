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
