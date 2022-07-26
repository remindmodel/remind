*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/KW_SEitr/realization.gms

*' @description The social cost of carbon corresponding to the Kalkuhl&Wenz (2020) damages including the standard error calculated in module 50_damages/KW_SE is calculated. The analytical approach from Schultes et al (2021) does not work here due to the missing interaction terms in the damage marginals. Therefore this is based on a direct calculation of the SCC as the discounted difference between a GDP path with climate change and a GDP path with climate change and an additional emission pulse (done in 50_damages/KW_SE), following Ricke et al. (2018).

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/51_internalizeDamages/KW_SEitr/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/51_internalizeDamages/KW_SEitr/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/51_internalizeDamages/KW_SEitr/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/51_internalizeDamages/KW_SEitr/realization.gms
