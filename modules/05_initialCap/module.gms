*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/05_initialCap/module.gms

*' @title Initial Capacities
*'
*' @description This modules initialises the vintage stocks of all energy 
*' convertion technologies.
*'
*' @authors Robert Pietzcker

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%initialCap%" == "on" $include "./modules/05_initialCap/on/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################

*** EOF ./modules/05_initialCap/module.gms

