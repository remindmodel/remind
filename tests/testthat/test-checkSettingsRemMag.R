test_that("checkSettingsRemMag() works", {
  works <- list(c("SSP2", "SSP2", "SSP2"),
                c("SSP3", "SSP3", "SSP3"),
                c("SDP_AB", "SDP_AB", "SDP_AB"),
                c("SSP2", "SSP2", "SSP2India"),
                c("strange", "whatever", "noother"))
  for (item in works) {
    cfg_mag <- list(gms = list(c09_pop_scenario = item[[1]],
                               c09_gdp_scenario = item[[2]],
                               c60_1stgen_biodem = "const2030"))
    cfg_rem <- list(gms = list(cm_GDPpopScen = item[[3]],
                               cm_1stgen_phaseout = 0))
    expect_equal(checkSettingsRemMag(cfg_rem, cfg_mag), 0)
  }
  fails <- list(c("SSP2", "SSP2", "SSP3"),
                c("SSP2", "SSP3", "SSP2"),
                c("SSP3", "SSP2", "SSP2"),
                c("SSP2", "SSP2", "SSP3India"),
                c("SDP_AB", "SDP_BC", "SDP_BC"))
  for (item in fails) {
    cfg_mag <- list(gms = list(c09_pop_scenario = item[[1]],
                               c09_gdp_scenario = item[[2]],
                               c60_1stgen_biodem = "const2030"))
    cfg_rem <- list(gms = list(cm_GDPpopScen = item[[3]]
                               cm_1stgen_phaseout = 0))
    expect_error(checkSettingsRemMag(cfg_rem, cfg_mag))
  }
})
