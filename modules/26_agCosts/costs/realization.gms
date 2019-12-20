*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/26_agCosts/costs.gms

*' @description
*' Agricultural production costs in REMIND consist of the following components: actual production costs 
*' (land conversion, crop cultivation, irrigation, technological change, ...), bioenergy costs, cost for abating
*' emissions accruing from agricultural activity (marginal abatement costs = MAC cost). 


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/26_agCosts/costs/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/26_agCosts/costs/datainput.gms"
$Ifi "%phase%" == "presolve" $include "./modules/26_agCosts/costs/presolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/26_agCosts/costs.gms
