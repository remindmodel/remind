*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/timeDepGrades.gms

*' @description This realization represents fossil fuel resources as a time-dependent cost grade structure. The grades are each defined   
*' by a minimum and a maximum price, and these cost brackets change over time based on the rate of technological change as prescribed 
*' exogenously by the socioeconomic scenario. Each model region contains different volumes of each cost grade of each fuel (oil, gas 
*' and coal) based on data compiled from IIASA's 2012 Global Energy Assessment and the German Federal Institute for Geosciences and  
*' Natural Resources (BGR) The model extracts resources in a Hotelling fashion, such that lower cost grades are depleted in each region  
*' before shifting production to higher-cost grades.
*'
*' @limitations p31_grades used in equation emissengregi in core/equations.gms, calculation of p31_prod_ini, 
*' p31_prod_share in grades/preloop.gms uses additional interfaces (pm_fosadjco_xi7xi8 and vm_edemini) not used


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/31_fossil/timeDepGrades/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/31_fossil/timeDepGrades/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/31_fossil/timeDepGrades/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/31_fossil/timeDepGrades/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/31_fossil/timeDepGrades/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/31_fossil/timeDepGrades/bounds.gms"
$Ifi "%phase%" == "output" $include "./modules/31_fossil/timeDepGrades/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/31_fossil/timeDepGrades.gms
