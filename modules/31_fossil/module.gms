*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/31_fossil.gms

*' @title Fossil
*'
*' @description The Fossil Module calculates the costs of a specific amount of fossil resource extraction.
*' 
*' @authors Nico Bauer, Jerome Hilaire, Robert Pietzcker, Lavinia Baumstark

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%fossil%" == "MOFEX" $include "./modules/31_fossil/MOFEX/realization.gms"
$Ifi "%fossil%" == "exogenous" $include "./modules/31_fossil/exogenous/realization.gms"
$Ifi "%fossil%" == "grades2poly" $include "./modules/31_fossil/grades2poly/realization.gms"
$Ifi "%fossil%" == "timeDepGrades" $include "./modules/31_fossil/timeDepGrades/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/31_fossil/31_fossil.gms
