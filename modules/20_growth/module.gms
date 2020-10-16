*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/20_growth.gms

*' @title Growth
*'
*' @description
*' The growth module decides whether to follow a quasi exogenous growth path(calibrated to SSP GDP paths)
*' or an endogenous growth path that includes innovation, immitation and spillover effects  
*'
*' @authors Marian Leimbach, Lavinia Baumstark

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%growth%" == "exogenous" $include "./modules/20_growth/exogenous/realization.gms"
$Ifi "%growth%" == "spillover" $include "./modules/20_growth/spillover/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/20_growth/20_growth.gms
