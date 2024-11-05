# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
# Source:  https://github.com/remindmodel/development_issues/issues/91
library(magclass)
test_that("there are no negative electricity prices in historic years in EU regions", {
  dirs <- list.dirs("../../../output", recursive = FALSE)
  data <- NULL
  reg <- c("EU27", "DEU", "ECE", "ECS", "ENC", "ESC", "ESW", "EWN", "FRA")
  for (d in dirs) {
    mifs <- list.files(path = d, pattern = "REMIND_generic_.*_withoutPlus.mif", full.names = TRUE)
    if (length(mifs) == 1) {
      m <- suppressWarnings(
        read.report(mifs[1], as.list = FALSE)[
          , ,
          c(
            "Price|Secondary Energy|Electricity (US$2017/GJ)",
            "Price|Final Energy|Industry|Electricity (US$2017/GJ)"
          )
        ]
      )
      if (all(reg %in% getRegions(m))) {
        data <- mbind(data, m[reg, seq(2005, 2025, 5), ])
      }
    }
  }

  expect_true(length(data[data < 0 & !is.na(data)]) == 0)
})
