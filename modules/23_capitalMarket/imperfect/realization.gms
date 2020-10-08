*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./module/23_capitalMarket/perfect.gms

*'
*' @description
*' This realization considers imperfections on capital markets represented by constraints
*' (e.g. limits on debt accumulation) and risk mark-ups on capital flows. Moreover, regionally differentiated
*' preference paramters (so-called savings wedges) cover institutional imperfections. Compared to the perfect
*' capital market realization, this realization substantially improves the fit of simulation results (initial 
*' consumption paths and current accounts) with the data.
*'
*' @limitations
*' This implementation ist still under construction.
*'


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/23_capitalMarket/imperfect/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/23_capitalMarket/imperfect/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/23_capitalMarket/imperfect/equations.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./module/23_capitalMarket/perfect.gms
