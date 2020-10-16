*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/exogenous.gms

*' @description
*' The exogenous growth realization makes no changes to the (macroeconomic) efficiency growth rate parameters.
*' In effect, it leaves all respective parameter specifications to be dealt with by the calibration (usually to given SSP GDP paths) and loading
*' in module 29_CES_parameters, respectively.

*' @limitations
*' Apart from variation of exogenous GDP scenarios, the model can (in contrast to the endogenous/spillover realization) only slightly correct
*' growth paths in reaction of policy shocks. This correction is done by an adjustment of capital accumulation.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/20_growth/exogenous/declarations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/20_growth/exogenous/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/20_growth/exogenous.gms
