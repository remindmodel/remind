*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/70_water/heat/realization.gms

*' @description Water demand is calculated based on data on water demand coefficients (both for consumption 
*' and withdrawal) and cooling shares.
*' 
*' For thermal power plants, water demand is proportional to excess heat production, which is calculated as fuel input minus
*' electricity output and smokestack losses (assumed to be 10% of fuel input for non-nuclear thermal power plants).
*'
*' For non-biomass renewable technologies, water demand is proportional to electricty output.
*'
*' The regional vintage structure of power plants enters the water demand calculation through the time- and region-dependent
*' conversion efficiencies in the excess heat calculation, and also through time- and region-dependent shares of cooling
*' technologies. Four cooling technologies are implemented: once trough, wet tower, dry tower and pond cooling. We assume
*' a shift away from once-through cooling systems towards recirculating or dry cooling technologies.
*' @limitations Water demand is calculated in a post-processing of REMIND; there is no market-based decision making process
*' for water allocation. Instead, a rule-based priorization is adopted: only 50% of available water is allowed to be used 
*' for agricultural purposes. Accordingly, there are no constraints on water quantity or quality for the expansion of
*' water-intense technologies.
*' 
*' Water demand in sectors other than electricity is not represented.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/70_water/heat/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/70_water/heat/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/70_water/heat/datainput.gms"
$Ifi "%phase%" == "output" $include "./modules/70_water/heat/output.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/70_water/heat/realization.gms
