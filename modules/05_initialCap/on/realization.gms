*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/05_initalCap/on/realization.gms

*' @description This realisation computes the initial capital stocks using a 
*' constrained non-linear model that ensures the production from capacities 
*' satisfies external and internal (energy system own-consumption) demand for 
*' all energy carriers (primary, secondary, and final) in the first time step 
*' $t_0$.  
*' 
*' Capacity additions up to $t_0$ are assigned according to the historic 
*' vintage structure such that discounted vintages equal the calculated 
*' capcaity in $t_0$.  
*' 
*' Conversion technology efficiencies ($\eta$) are adjusted to fit the 
*' calibration of initial capacities.  This is equired since time-variant 
*' $\eta$ values follow the same trajectory for all regions, but the base-year 
*' calibration results in regionally different values.  
*'
*' Upper bounds for emissions are calculated based on the Kyoto targets and 
*' $t_0$ emissions (fossil fuel consumption times emission factors). 

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/05_initialCap/on/declarations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/05_initialCap/on/preloop.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/05_initalCap/on/realization.gms

