*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/module.gms

*' @title internalizeDamages
*'
*' @description If turned on, the module 51_internalizeDamages calculates in between iterations the social cost of carbon based on the damages calculated in module 50_damages. These are then stored in the parameter pm_taxCO2eqSCC which is to the carbon tax, endogenizing the social cost of carbon into the model. The method is described in @Schultes2020. The options correspond to the damages calculated in module 50_damages. Aside from the damages, a temperature impulse response is required, which is calculated with MAGICC based on the given emissions pathway. The calculation is done with an annual time step, input from REMIND is interpolated to that. The parameter p51_sccConvergenceMaxDeviation is an indicator for the difference of the SCC to that of the previous iteration, assessing convergence.
*' Note: the effect of inequality on the SCC is ONLY implemented for KWlikeItr at this point!
*'
*' @authors Anselm Schultes, Franziska Piontek

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%internalizeDamages%" == "BurkeLikeItr" $include "./modules/51_internalizeDamages/BurkeLikeItr/realization.gms"
$Ifi "%internalizeDamages%" == "DiceLikeItr" $include "./modules/51_internalizeDamages/DiceLikeItr/realization.gms"
$Ifi "%internalizeDamages%" == "KWTCintItr" $include "./modules/51_internalizeDamages/KWTCintItr/realization.gms"
$Ifi "%internalizeDamages%" == "KW_SEitr" $include "./modules/51_internalizeDamages/KW_SEitr/realization.gms"
$Ifi "%internalizeDamages%" == "KWlikeItr" $include "./modules/51_internalizeDamages/KWlikeItr/realization.gms"
$Ifi "%internalizeDamages%" == "KWlikeItrCPnash" $include "./modules/51_internalizeDamages/KWlikeItrCPnash/realization.gms"
$Ifi "%internalizeDamages%" == "KWlikeItrCPreg" $include "./modules/51_internalizeDamages/KWlikeItrCPreg/realization.gms"
$Ifi "%internalizeDamages%" == "LabItr" $include "./modules/51_internalizeDamages/LabItr/realization.gms"
$Ifi "%internalizeDamages%" == "TCitr" $include "./modules/51_internalizeDamages/TCitr/realization.gms"
$Ifi "%internalizeDamages%" == "off" $include "./modules/51_internalizeDamages/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/51_internalizeDamages/module.gms
