*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/module.gms

*' @title CDR
*'
*' @description The 33_CDR module adds further options to remove CO2 from the atmosphere beyond BECCS
*' and afforestation, which are calculated in the core. Currently, direct air carbon capture and storage (DACCS)
*' and enhanced weathering of rocks (EW) are available, ocean alkalinization (OAE) implemented as ocean liming.
*' All options can be switched on and off individually via the switches called cm_33[option abbreviation].
*' The module calculates capacities, emissions (including captured carbon), energy demand & supply, costs,
*' and limitations associated with the different options.
*' @authors Jessica Strefler, Katarzyna Kowalczyk, Anne Merfort, Tabea Dorndorf

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%CDR%" == "portfolio" $include "./modules/33_CDR/portfolio/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/33_CDR/module.gms
