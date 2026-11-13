# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de

library(stringr)
library(glue)

#' check if delimiters only occur paired in a file. No nesting allowed.
#'
#' @param file_path where to check
#' @param openDelim string of the open delimiter
#' @param closeDelim string of the closing delimiter
#'
#' @return boolean
validatePairedDelimiters <- function(file_path, openDelim = "$onDelim", closeDelim = "$offDelim") {
  content <- paste(readLines(file_path, warn = FALSE), collapse = "\n")
  matches <- str_extract_all(content, glue("{str_escape(openDelim)}|{str_escape(closeDelim)}"))[[1]]

  # Build expected alternating sequence
  expected <- rep_len(c(openDelim, closeDelim), length(matches))

  # Valid if matches alternating pattern AND count is even
  return(length(matches) %% 2 == 0 && identical(matches, expected))
}

test_that("start.R config/tests/scenario_config_quick.csv works", {
  skipIfPreviousFailed()
  output <- localSystem2("Rscript", c("start.R", "config/tests/scenario_config_quick.csv"))
  printIfFailed(output)
  expectSuccessStatus(output)
  expect_true(file.exists("../../output/testOneRegi/REMIND_generic_testOneRegi.mif"))

  # Check if we have nested $onDelim/$offDelim blocks (unnecessarily large) or $onDelim/$offDelim are not correctly matched.
  # prepare.R contains some string manipulation that might break if this does not hold
  expect_true(validatePairedDelimiters("../../output/testOneRegi/full.gms", "$onDelim", "$offDelim"))
})
