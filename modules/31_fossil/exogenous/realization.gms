*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/exogenous.gms

*' @description For this realization exogenous fossil extraction and costs are used. The data are from a baseline run.
*' 
*' @limitations Fossil fuel extraction and costs are fixed to exogenous values.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/31_fossil/exogenous/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/31_fossil/exogenous/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/31_fossil/exogenous/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/31_fossil/exogenous.gms
