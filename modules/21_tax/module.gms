*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/21_tax.gms

*' @title Tax Module
*'
*' @description The tax module includes different types of taxes or ignores all taxes. 

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%tax%" == "off" $include "./modules/21_tax/off/realization.gms"
$Ifi "%tax%" == "on" $include "./modules/21_tax/on/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/21_tax/21_tax.gms
