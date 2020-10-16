*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC2018.gms

*#' @description This realization implements a carbon price trajectory consistent with the NDC targets (up to 2030) and 
*# a trajectory of comparable ambition post 2030 (1.25%/yr price increase and regional convergence of carbon price). 

*#' @limitations The NDC emission target refers to GHG emissions w/o land-use change and international bunkers. However, the submitted NDC targets of 
*#' several countries include land-use emissions (e.g. Australia and US). See https://www4.unfccc.int/sites/NDCStaging/Pages/All.aspx. To be checked!

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/NDC2018/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/NDC2018/datainput.gms"
$Ifi "%phase%" == "preloop" $include "./modules/45_carbonprice/NDC2018/preloop.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/NDC2018/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/45_carbonprice/NDC2018.gms
