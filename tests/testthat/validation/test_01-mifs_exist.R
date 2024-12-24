# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("each output folder contains standard mif files", {
  dirs <- list.dirs("../../../output", recursive = FALSE, full.names = FALSE)
  for (dir in dirs) {
    d <- paste0("../../../output/", dir)
    r <- expect_true(
      length(list.files(path = d, pattern = "REMIND_generic_.*.mif")) == 2
    )

    if (!r) {
      print(paste0("some mifs are missing in ", dir))
    }
  }
})
