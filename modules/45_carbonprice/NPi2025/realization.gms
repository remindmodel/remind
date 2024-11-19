*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi2025/realization.gms

*' @description: This realization uses the carbon prices from the input (/p/projects/rd3mod/inputdata/sources/ExpertGuess) data up to 2025 (and for EUR, up to 2030) and thereafter assumes a linear increase to 20 USD in the period from 2025 to 2100.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/NPi2025/datainput.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/45_carbonprice/NPi2025/realization.gms
