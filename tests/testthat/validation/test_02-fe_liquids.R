# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# Source:  https://github.com/remindmodel/development_issues/issues/168
library(magclass)
library(quitte)
library(dplyr)
test_that("liquids demand in buildings in NPi and NDC is not higher than baseline", {
  dirs <- list.dirs("../../../output", recursive = FALSE)
  data <- NULL
  for (d in dirs) {
    mifs <- list.files(path = d, pattern = "REMIND_generic_.*_withoutPlus.mif", full.names = TRUE)
    if (length(mifs) == 1) {
      m <- suppressWarnings(read.report(mifs[1], as.list = FALSE)["GLO", , "FE|Buildings|Liquids (EJ/yr)"])
      data <- mbind(data, m)
    }
  }

  if (all(c("SSP2EU-Base", "SSP2EU-NPi", "SSP2EU-NDC") %in% getNames(data, dim = 1))) {
    xBase <- as.quitte(data[, , "SSP2EU-Base"])
    x <- as.quitte(data[, , c("SSP2EU-NPi", "SSP2EU-NDC")])
    # data frame with all data points where Base value is greater than NPi/NDC value,
    # excluding historical values
    x <- left_join(x, xBase, by = c("model", "region", "variable", "unit", "period")) %>%
      filter(value.x > value.y, period > 2025)
  }
  
  r <- expect_true(nrow(x) == 0)
  
  if (!r) {
    print("Examples of test violation:")
    print(head(x))
  }
})
