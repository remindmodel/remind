*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/53_adaptation/module.gms

*' @title Adaptation
*'
*' @description This module allows for adaptation to be applied to reduce damages. It was developed for the ACCREU project and only works for the ACCREU damage functions, otherwise it has to be turned off. It uses adaptation cost functions for non-SLR and SLR damages and provides the net damages after adaptation accounting for adaptation costs.
*'
*' @authors Franziska Piontek

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%adaptation%" == "ACCREU" $include "./modules/53_adaptation/ACCREU/realization.gms"
$Ifi "%adaptation%" == "off" $include "./modules/53_adaptation/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################

*** EOF ./modules/53_adaptation/module.gms
