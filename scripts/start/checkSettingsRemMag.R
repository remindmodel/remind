#' checks compatibility of REMIND and MAgPIE settings
#' @param cfg_rem REMIND settings
#' @param cfg_mag MAgPIE settings
#' @param testmode if TRUE, generates warnings, else fails
checkSettingsRemMag <- function(cfg_rem, cfg_mag, testmode = FALSE) {
  errorsfound <- 0

  # check that if population and gdp scenario starts with SDP_?? or SSP?, they are identical.
  popgdp <- c(cfg_mag$gms$c09_pop_scenario, cfg_mag$gms$c09_gdp_scenario, cfg_rem$gms$cm_GDPpopScen)
  popgdp <- stringr::str_match(popgdp, "^SDP_[A-Z]{2}|^SSP[1-5]?")[,1]
  if (length(unique(popgdp)) > 1) {
    text <- paste0("Population and GDP scenarios differ in REMIND and MAgPIE for ", cfg_rem$title, ":",
                   "\n- cfg_mag$gms$c09_pop_scenario = ", popgdp[[1]],
                   "\n- cfg_mag$gms$c09_gdp_scenario = ", popgdp[[2]],
                   "\n- cfg_rem$gms$cm_GDPpopScen = ", popgdp[[3]])
    if (isTRUE(testmode)) warning(text) else message(text)
    errorsfound <- errorsfound + 1
  }

  # allowed bioenergy phaseout (yes/no) options
  allowed <- list(yes1 = c("phaseout2020", 1), yes2 = c("phaseout2030", 1),
                  no1 = c("const2030", 0), no2 = c("const2020", 0))
  if (! list(c(cfg_mag$gms$c60_1stgen_biodem, cfg_rem$gms$cm_1stgen_phaseout)) %in% allowed) {
    text <- paste0("Those settings lead to an inconsistency on bioenergy phaseout for ", cfg_rem$title, ":",
                   "\n- cfg_mag$gms$c60_1stgen_biodem = ", cfg_mag$gms$c60_1stgen_biodem,
                   "\n- cfg_rem$gms$cm_1stgen_phaseout = ", cfg_rem$gms$cm_1stgen_phaseout)
    if (isTRUE(testmode)) warning(text) else message(text)
    errorsfound <- errorsfound + 1
  }

  # damage settings
  if (! isTRUE(cfg_mag$gms$c14_yields_scenario == "cc") &&
      ! isTRUE(cfg_rem$gms$damages == "off")) {
    text <- paste0("You did not select MAgPIE climate damages, but REMIND damages for ", cfg_rem$title, ":",
                   "\n- cfg_mag$gms$c14_yields_scenario = ", cfg_mag$gms$c14_yields_scenario,
                   "\n- cfg_rem$gms$damages = ", cfg_rem$gms$damages)
    if (isTRUE(testmode)) warning(text) else message(text)
    errorsfound <- errorsfound + 1
  }

  if (errorsfound > 0) {
    if (testmode) warning(errorsfound, " errors found in checkSettingsRemMag.")
      else stop(errorsfound, " errors found in checkSettingsRemMag, see explanation in warnings.")
  }
  return(errorsfound)
}
