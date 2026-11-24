# |  (C) 2006-2026 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("core/input/f_technoeconomic.csv matches technoeconomic/create_input.py and the uv.lock", {
  source("../../scripts/input/create_input_for_technoeconomic.R", local = TRUE)
  check <- technoeconomicCheck("../..")
  # 3 outdated or editable and 2 without uv or its .venv both mean the file on
  # disk is not something to test, a 1 or an unknown code is a failed check and
  # must fail here; on GitHub the technoeconomicCheck step of test-code.yaml is
  # what refuses a commit
  skip_if(check$status %in% c(2L, 3L), check$message)
  expect_equal(check$status, 0L, info = check$message)
})
