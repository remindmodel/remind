*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*' @title Calibration of PE and FE parameters
*'
*' @description This realization calibrates PE and FE parameters

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%PE_FE_parameters%" == "iea2014" $include "./modules/04_PE_FE_parameters/iea2014/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
