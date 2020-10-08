*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/none.gms


*#' @description: This realization is for runs without carbon prices (BAU). 

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/none/datainput.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/45_carbonprice/none.gms
