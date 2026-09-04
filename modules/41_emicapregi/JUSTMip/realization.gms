*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  REMIND and licensed under AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/realization.gms

*' @description: Emission permits are only restricted by 1% of global GDP and can relax regional emission budgets


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/41_emicapregi/JUSTMip/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/41_emicapregi/JUSTMip/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/41_emicapregi/JUSTMip/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/41_emicapregi/JUSTMip/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/41_emicapregi/JUSTMip/realization.gms
