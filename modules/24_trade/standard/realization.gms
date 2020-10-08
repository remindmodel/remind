*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/realization.gms

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/24_trade/standard/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/24_trade/standard/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/24_trade/standard/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/24_trade/standard/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/24_trade/standard/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/24_trade/standard/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/24_trade/realization.gms
