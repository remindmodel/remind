*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS2025/realization.gms

*' @description Bundle the air pollution emission results from different sources. We calculate the emissions for sectors that are available in the GAINS model with the interactively run script exoGAINS2025Airpollutants.R. Land related emissions are taken from MAGPIE. 

*' @limitations EDGE-transport runs in between iterations and is therefore not fully optimized.


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/11_aerosols/exoGAINS2025/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/11_aerosols/exoGAINS2025/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/11_aerosols/exoGAINS2025/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/11_aerosols/exoGAINS2025/equations.gms"
$Ifi "%phase%" == "presolve" $include "./modules/11_aerosols/exoGAINS2025/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/11_aerosols/exoGAINS2025/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/11_aerosols/exoGAINS2025/realization.gms
