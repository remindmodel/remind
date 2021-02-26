*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/51_internalizeDamages/off/off.gms

*' @description The off-realization of the internalizeDamages module sets the parameter pm_taxCO2eqSCC to zero, meaning no social costs of carbon are included in the optimization.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/off/datainput.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/51_internalizeDamages/51_internalizeDamages/off/off.gms
