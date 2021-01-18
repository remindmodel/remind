*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./module/23_capitalMarket/23_capitalMarket.gms

*' @title Capital Market
*'
*' @description
*' The capital market module determines direction and volume of capital flows (which are linked to the export and import
*' of goods and energy,  and which is accounted for in the intertemporal trade balance). By directing the goods trade, the
*' capital market implementation affects the consumption path.
*'
*' @authors Marian Leimbach

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%capitalMarket%" == "debt_limit" $include "./modules/23_capitalMarket/debt_limit/realization.gms"
$Ifi "%capitalMarket%" == "imperfect" $include "./modules/23_capitalMarket/imperfect/realization.gms"
$Ifi "%capitalMarket%" == "perfect" $include "./modules/23_capitalMarket/perfect/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################

*** EOF ./module/23_capitalMarket/23_capitalMarket.gms
