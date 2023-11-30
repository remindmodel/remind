# |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("combine_slurmConfig works", {
  teststring <- "--qos=priority --time=03:30:00"
  expect_identical(combine_slurmConfig(teststring, teststring), teststring)
  expect_identical(combine_slurmConfig(teststring, NULL), teststring)
  expect_identical(combine_slurmConfig(NULL, NULL), "")
  expect_identical(combine_slurmConfig(teststring, ""), teststring)
  expect_identical(combine_slurmConfig(teststring, "--qos=standby"), "--qos=standby --time=03:30:00")
  expect_identical(combine_slurmConfig(teststring, "--bla=blub"), paste("--bla=blub", teststring))
  expect_identical(combine_slurmConfig(teststring, "--wait"), paste("--wait", teststring))
  teststring <- "--qos=priority --wait"
  expect_identical(combine_slurmConfig(teststring, "--qos=standby"), "--qos=standby --wait")
})
