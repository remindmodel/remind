*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/32_power/module.gms
*' @title Power sector
*'
*' @description  The 32_power module determines the operation production decisions for the electricity supply.
*'
*'
*'               The `IntC` realization (Integrated Costs) assumes a single electricity market balance.
*'
*'               The `RLDC` realization (Residual Load Duration Curve) distinguishes different operation electricity supply decisions under four distinct load bands, plus additional peak capacity requirements.
*'
*'               The `DTcoup` realization (DIETER-coupled) soft-couples REMIND to DIETER (an hourly power sector model), and is currently only at conceptual stage and not merged (it is only a copy of IntC)
*'
*' @authors Robert Pietzcker, Falko Ueckerdt, Renato Rodrigues, Chen Chris Gong

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%power%" == "DTcoup" $include "./modules/32_power/DTcoup/realization.gms"
$Ifi "%power%" == "IntC" $include "./modules/32_power/IntC/realization.gms"
$Ifi "%power%" == "RLDC" $include "./modules/32_power/RLDC/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/32_power/module.gms
