*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/magicc.gms

*' @description 
*' In this realization, concentration, forcing, and temperature values are calculated using a MAGICC6.4. 
*' MAGICC is run in between iterations and can be used to adapt carbon tax pathways and budgets to meet a give climate target.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/15_climate/magicc/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/15_climate/magicc/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/15_climate/magicc/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/15_climate/magicc/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/15_climate/magicc.gms
