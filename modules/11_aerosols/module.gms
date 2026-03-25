*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/module.gms

*' @title aerosols
*'
*' @description  The 11_aerosols module calculates air pollution emissions for those
*'               sectors (currently indst, trans, res, and power) and species 
*'               (currently BC, OC, and SO2) that are priced in REMIND.
*'               It uses the emission factors from mrremind::calcGAINS2025.
*'               Important note: These emissions are not reported, but only used to 
*'               calculate air pollution costs. Instead, the air pollutant emissions 
*'               for all species and all 35 GAINS sectors are calculated and reported
*'               in remind2::reportAirPollutantEmissions.
*'
*' @authors Sebastian Rauner, David Klein, Jessica Strefler

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%aerosols%" == "exoGAINS2025" $include "./modules/11_aerosols/exoGAINS2025/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/11_aerosols/module.gms
