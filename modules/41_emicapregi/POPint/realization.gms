*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/POPint.gms

*' @description
*' Emission caps/permits are allocated according to each region's share on
*' cumulated population 
*' 

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/41_emicapregi/POPint/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/41_emicapregi/POPint/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/41_emicapregi/POPint/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/41_emicapregi/POPint/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/41_emicapregi/POPint/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/41_emicapregi/POPint.gms
