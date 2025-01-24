# |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
# |  authors, and contributors see CITATION.cff file. This file is part
# |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
# |  AGPL-3.0, you are granted additional permissions described in the
# |  REMIND License Exception, version 1.0 (see LICENSE file).
# |  Contact: remind@pik-potsdam.de
test_that("checkFixCfg works", {
  remind_folder <- "../.."
  savecfg <- cfg <- gms::readDefaultConfig(remind_folder)
  expect_no_warning(checkFixCfg(cfg, remind_folder, testmode = TRUE))

  wrongsetting <- c(
    "cm_NDC_version" = "2004_cond",
    "cm_emiscen" = "123",
    "cm_nash_autoconverge" = "NA",
    "cm_gs_ew" = "2.2.2",
    "cm_taxCO2_expGrowth" = "333++",
    "c_macscen" = "-1",
    "cm_keep_presolve_gdxes" = "1.1",
    "cm_startyear" = "1985",
    "cm_netZeroScen" = "NöööGFS_v4",
    "cm_rcp_scen" = "apocalypse",
    "c_testOneRegi_region" = "LOONG",
    "c_shGreenH2" = "1.5",
    "cm_taxCO2_startyear" = "-2",
  NULL)

  cfg <- savecfg
  cfg$gms[names(wrongsetting)] <- wrongsetting
  w <- capture_warnings(checkFixCfg(cfg, remind_folder, testmode = TRUE))
  for (n in names(wrongsetting)) {
    expect_match(w, paste0(n, "=", wrongsetting[[n]]), all = FALSE, fixed = TRUE)
  }
  expect_match(w, paste0(length(wrongsetting), " errors found"), all = FALSE, fixed = TRUE)
  expect_match(w, "Chosen RCP scenario 'apocalypse' might currently not be fully operational", all = FALSE, fixed = TRUE)
  expect_length(w, length(wrongsetting) + 2)
})
