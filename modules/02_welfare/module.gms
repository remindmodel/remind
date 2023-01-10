*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/module.gms
*' @title Welfare
*'
*' @description The welfare module enables the implementation of different social welfare functions. The ineqLognormal realization includes subregional inequality in the welfare function through a log-normal distribution. Any change in the utilitarian realization needs to be mirrored in the ineqLognormal realization!

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%welfare%" == "ineqLognormal" $include "./modules/02_welfare/ineqLognormal/realization.gms"
$Ifi "%welfare%" == "utilitarian" $include "./modules/02_welfare/utilitarian/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/02_welfare/module.gms
