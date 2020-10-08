*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*#' @description This realization chooses a carbon price trajectory consistent with a (non-overshoot) temperature target  
*#' by staying within a peak budget of cumulative CO2 emissions. 

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/temperatureNotToExceed/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/temperatureNotToExceed/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/temperatureNotToExceed/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
