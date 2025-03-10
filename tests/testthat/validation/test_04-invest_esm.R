# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
library(magclass)
library(quitte)
library(dplyr)
test_that("Non-ESM Investments never drop more than 50% in comparison to previous timestep until 2100", {
  dirs <- list.dirs("../../../output", recursive = FALSE)
  data <- NULL
  reg <- c(
    "CAZ", "CHA", "EUR", "IND", "JPN", "LAM", "MEA",
    "NEU", "OAS", "REF", "SSA", "USA", "GLO"
  )
  for (d in dirs) {
    mifs <- list.files(path = d, pattern = "REMIND_generic_.*_withoutPlus.mif", full.names = TRUE)
    if (length(mifs) == 1) {
      m <- suppressWarnings(
        read.report(mifs[1], as.list = FALSE)
      )[reg, , "Investments|Non-ESM (billion US$2017/yr)"]
      data <- mbind(data, m)
    }
  }
  data <- data[, getYears(data, as.integer = TRUE) <= 2100, ]
  x <- as.quitte(data)
  xPrev <- mutate(x, period_next := period + 5)
  xDiff <- inner_join(x, xPrev, by = c("period" = "period_next", "model", "scenario", "region", "variable", "unit")) %>%
    mutate(value := (value.x - value.y) / value.x) %>%
    filter(value < -0.5)

  r <- expect_true(nrow(xDiff) == 0)

  if (!r) {
    print("Examples of test violation:")
    print(head(xDiff))
  }
})
