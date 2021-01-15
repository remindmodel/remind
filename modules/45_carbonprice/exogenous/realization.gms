*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/exogenous.gms

*#' @description This realization implements carbon price trajectories from an exogenous file (p45_tau_co2_tax.inc).  


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/exogenous/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/exogenous/datainput.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/45_carbonprice/exogenous.gms
