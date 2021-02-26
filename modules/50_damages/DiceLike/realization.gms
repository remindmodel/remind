*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/DiceLike.gms

*' @description Output damages are calculated based on the DICE-based damage function (see @DICEdocumentation). Multiple different specifications can be chosen: DICE2013R, DICE2016, Howard (@Howard2017) or different options from Kalkuhl & Wenz (2020) (KWcross for the cross-sectional specification, KWpanelPop for the panel specification with population weighting) through the switch cm_damage_DiceLike_specification. They are based on the global mean temperature pathway from MAGICC.

*' @limitations: Unless the realization "DiceLikeItr" is used for module 51_internalizeDamages, the damages are not actually part of the optimization, but just enter as a fixed variable updated in between iterations.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/DiceLike/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/DiceLike/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/DiceLike/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/DiceLike/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/50_damages/DiceLike.gms
