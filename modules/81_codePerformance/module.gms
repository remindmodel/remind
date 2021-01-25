*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/81_codePerformance/81_codePerformance.gms

*' @title Codeperformance
*'
*' @description The realization codeperformance can be used to test the performance of the model. test code performance: noumerous (30) succesive runs
*' performed in a triangle, tax0, tax30, tax150, all growing exponentially, therefore use carbonprice|exponential, c_emiscen|9, and cm_co2_tax_2020|0.
*'
*' @authors Anastasis Giannousakis, Robert Pietzcker

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%codePerformance%" == "off" $include "./modules/81_codePerformance/off/realization.gms"
$Ifi "%codePerformance%" == "on" $include "./modules/81_codePerformance/on/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/81_codePerformance/81_codePerformance.gms
