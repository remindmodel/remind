*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/linadjust.gms

*#' @description This realization increases the carbon price linearly over time. In the period of staged accession, the carbon price is the linear interpolation
*#' between the reference policy and the first-best policy as calculated from iterative adjustment. 


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/linadjust/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/linadjust/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/linadjust/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/45_carbonprice/linadjust.gms
