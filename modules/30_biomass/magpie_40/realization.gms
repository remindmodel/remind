*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_linear.gms

*' @description
*' The costs for purpose grown ligno-cellulosic biomass 
*' are the integral under the supplycurve. The supplycurves have been derived from MAgPIE 4.1

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/30_biomass/magpie_40/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/30_biomass/magpie_40/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/30_biomass/magpie_40/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/30_biomass/magpie_40/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/30_biomass/magpie_40/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/30_biomass/magpie_40/bounds.gms"
$Ifi "%phase%" == "output" $include "./modules/30_biomass/magpie_40/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/30_biomass/magpie_linear.gms
