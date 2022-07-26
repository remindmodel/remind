*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/KW_SE/realization.gms

*' @description Output damages are calculated based on the damage function from
*' Matthias Kalkuhl, Leonie Wenz: The impact of climate conditions on economic production.
*' Evidence from a global panel of regions. Journal of Environmental Economics and Management,
*' Volume 103, 2020, 102360, DOI: 10.1016/j.jeem.2020.102360
*' It is implemented similar to the Burke damage module, as a one-time growth effect
*' Compared to module KWLike here we add the standard error (as shown in the paper Figure 1) to explore the upper end of the damage uncertainty

*' @limitations: Unless the realization "KW_SEitr" is used for module 51_internalizeDamages, the damages are not actually part of the optimization, but just enter as a fixed variable reducing output, updated in between iterations.  

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/KW_SE/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/KW_SE/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/KW_SE/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/KW_SE/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/50_damages/KW_SE/realization.gms
