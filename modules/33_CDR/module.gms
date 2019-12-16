*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/33_CDR.gms

*' @title CDR
*'
*' @description  The 33_CDR module calculates CO2 removed from the atmosphere by options other than BECCS or afforestation, which are calculated in the core.
*'
*' @authors Jessica Strefler

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%CDR%" == "DAC" $include "./modules/33_CDR/DAC/realization.gms"
$Ifi "%CDR%" == "all" $include "./modules/33_CDR/all/realization.gms"
$Ifi "%CDR%" == "off" $include "./modules/33_CDR/off/realization.gms"
$Ifi "%CDR%" == "weathering" $include "./modules/33_CDR/weathering/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/33_CDR/33_CDR.gms
