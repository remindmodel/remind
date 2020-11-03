*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/42_banking/42_banking.gms

*' @title Banking 
*'
*' @description The Banking module allows for banking of emission permits. 

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%banking%" == "banking" $include "./modules/42_banking/banking/realization.gms"
$Ifi "%banking%" == "off" $include "./modules/42_banking/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/42_banking/42_banking.gms
