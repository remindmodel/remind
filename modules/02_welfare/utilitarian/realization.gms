*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/realization.gms

*' @description
*' The utilitarian realization loads the utilitarian aka. Benthamite social welfare function, in which social welfare is equal to the discounted intertemporal sum of utility, which itself is a function of per capita consumption.
*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/02_welfare/utilitarian/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/02_welfare/utilitarian/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/02_welfare/utilitarian/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/02_welfare/utilitarian/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/02_welfare/realization.gms
