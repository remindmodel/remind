*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalFormRegi/realization.gms

*' @description: Carbon price trajectory follows a prescribed functional form (linear/exponential) - either until peak year or until end-of-century.
*'               It is endogenously adjusted to meet regional end-of-century CO2 budget targets. 


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/functionalFormRegi/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/functionalFormRegi/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/functionalFormRegi/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/45_carbonprice/functionalFormRegi/realization.gms
