*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/11_aerosols.gms

*' @title aerosols
*'
*' @description  The 11_aerosols module calculates the air pollution emissions.
*'
*' @authors Sebastian Rauner, David Klein, Jessica Strefler

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%aerosols%" == "exoGAINS" $include "./modules/11_aerosols/exoGAINS/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/11_aerosols/11_aerosols.gms
