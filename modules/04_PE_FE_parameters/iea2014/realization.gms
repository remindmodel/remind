*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de


*' @description This realization used IEA data from 2014.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/04_PE_FE_parameters/iea2014/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/04_PE_FE_parameters/iea2014/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/04_PE_FE_parameters/iea2014/datainput.gms"
*######################## R SECTION END (PHASES) ###############################
