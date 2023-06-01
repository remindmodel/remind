# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
env <- paste0("unset R_PROFILE_USER;unset TESTTHAT;")
withr::with_dir("../..", {
  returnCode <- system2(
    "make", "ensure-reqs",
    env=env
  )
})
if (returnCode != 0) {
  stop("Not all requirements installed. Follow instructions above and re-start tests.")
}
