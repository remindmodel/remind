*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS2025/realization.gms
 
*' @description  Calculation of air pollution emissions for those sectors
*'               (currently indst, trans, res, and power) and species 
*'               (currently BC, OC, and SO2) that are priced in REMIND.
*'               It uses the emission factors from mrremind::calcGAINS2025.
*'               Important note: These emissions are not reported, but only used to 
*'               calculate air pollution costs. Instead, the air pollutant emissions 
*'               for all species and all 35 GAINS sectors are calculated and reported
*'               in remind2::reportAirPollutantEmissions.

*' @limitations EDGE-transport runs in between iterations and is therefore not fully optimized.


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/11_aerosols/exoGAINS2025/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/11_aerosols/exoGAINS2025/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/11_aerosols/exoGAINS2025/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/11_aerosols/exoGAINS2025/equations.gms"
$Ifi "%phase%" == "presolve" $include "./modules/11_aerosols/exoGAINS2025/presolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/11_aerosols/exoGAINS2025/realization.gms
