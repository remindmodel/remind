*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/spillover.gms

*' @description
*' This realization implies an endogenous growth path. It replaces and overwrites, respectively, the exogenous SSP GDP growth paths.
*' The spillover module computes new efficiency growth parameters for labor and energy that enter the upper level of the CES production function.
*' The implemented growth engine allows to increase growth by R&D investments into innovation and imitation. It also allows for spillover effects that
*' represent the catch-up with technological frontier. The model implemented as well as its parameetrization is based on Huebler et al. (2012).

*' @limitations
*' This realization was last applied with REMIND version 1.6, but not yet with REMIND2.0. In order to work properly it might be necessary to resolve
*' interference with the calibration and module 29_CES_parameters.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/20_growth/spillover/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/20_growth/spillover/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/20_growth/spillover/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/20_growth/spillover/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/20_growth/spillover/bounds.gms"
$Ifi "%phase%" == "output" $include "./modules/20_growth/spillover/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/20_growth/spillover.gms
