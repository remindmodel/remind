*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KWLike/realization.gms

*' @description Output damages are calculated based on the damage function from
*' Matthias Kalkuhl, Leonie Wenz: The impact of climate conditions on economic production.
*' Evidence from a global panel of regions. Journal of Environmental Economics and Management,
*' Volume 103, 2020, 102360, DOI: 10.1016/j.jeem.2020.102360
*' It is implemented similar to the Burke damage module, as a one-time growth effect

*' @limitations: Unless the realization "KWlikeItr" is used for module 51_internalizeDamages, the damages are not actually part of the optimization, but just enter as a fixed variable reducing output, updated in between iterations.  

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KWLike/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KWLike/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KWLike/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KWLike/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/50_damages/KWLike/realization.gms

