*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/29_CES_parameters.gms

*' @title CES parameters
*'
*' @description The CES parameters module either loads CES parameters or calibrates new CES parameters. 

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%CES_parameters%" == "calibrate" $include "./modules/29_CES_parameters/calibrate/realization.gms"
$Ifi "%CES_parameters%" == "load" $include "./modules/29_CES_parameters/load/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/29_CES_parameters/29_CES_parameters.gms
