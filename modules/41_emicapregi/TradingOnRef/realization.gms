*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/TradingOnRef/realization.gms

*' @description: Emission caps/permits are allocated according to a reference run
*' There are three different trade patterns currently available.
*'     cm_permittradescen  = 1;         !! def = 1  !! regexp = [1-3]
*' *  (1): full permit trade (no restrictions)
*' *  (2): no permit trade (only domestic mitigation)
*' *  (3): limited trade (certain percentage of regional allowances)
*'         for limited trade use cm_pemittradefinalyr   to set the final year until permit trading is allowed
*'         with cm_pemittraderatio set the percentage of allowed trade


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/41_emicapregi/TradingOnRef/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/41_emicapregi/TradingOnRef/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/41_emicapregi/TradingOnRef/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/41_emicapregi/TradingOnRef/realization.gms
