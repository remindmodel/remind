test_that("combine_slurmConfig works", {
  teststring <- "--qos=priority --time=03:30:00"
  expect_identical(combine_slurmConfig(teststring, "--qos=standby"), "--qos=standby --time=03:30:00")
  expect_identical(combine_slurmConfig(teststring, "--bla=blub"), paste("--bla=blub", teststring))
  teststring <- "--qos=priority --wait"
  expect_identical(combine_slurmConfig(teststring, "--qos=standby"), "--qos=standby --wait")
})
