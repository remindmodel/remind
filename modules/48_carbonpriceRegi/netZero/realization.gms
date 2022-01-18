*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_CarbonPriceRegi/netZero/realization.gms

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/48_carbonpriceRegi/netZero/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/48_carbonpriceRegi/netZero/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/48_carbonpriceRegi/netZero/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/48_carbonpriceRegi/netZero/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/48_CarbonPriceRegi/netZero/realization.gms
