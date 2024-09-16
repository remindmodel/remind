*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/realization.gms

*' @description This realization implements a carbon price trajectory consistent with the NDC targets (up to 2030) and
*' a trajectory of comparable ambition post 2030 (1.25%/yr price increase and regional convergence of carbon price).

*' @limitations The NDC emission target refers to GHG emissions w/o land-use change and international bunkers. However, the submitted NDC targets of
*' several countries include land-use emissions (e.g. Australia and US). See https://www4.unfccc.int/sites/NDCStaging/Pages/All.aspx. To be checked!

*** Next update (2025):
*** - Add NDC_2025-12-31.xlsx in /p/projects/rd3mod/inputdata/sources/UNFCCC_NDC/ on cluster, see README.txt in this folder
*** - Set switch cm_NDC_version in ./main.gms to new year
*** - add 2025_cond, 2025_uncond to set NDC_version in ./core/sets.gms
*** - Add new 2026 option in mrremind: calcEmiTarget, calcCapTarget, readUNFCCC_NDC


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/NDC/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/NDC/datainput.gms"
$Ifi "%phase%" == "preloop" $include "./modules/45_carbonprice/NDC/preloop.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/NDC/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/45_carbonprice/NDC/realization.gms
