*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/IntC/realization.gms

*' @description  
*'
*'The `IntC` realization (Integrated Costs) assumes a single electricity market balance.
*'
*'This module determines power system supply specific technology behavior, which sums up to the general core capacity equations to define the power sector operation and investment decisions.
*'
*'Contrary to other secondary energy types in REMIND, this requires to move the electricity secondary energy balance (supply = demand) from the core to the module code.
*'
*'
*'In summary, the specific power technology equations found in this module reflect the points below.
*'
*'
*'Storage requirements are based on intermittent renewables share, synergies between different renewables production profiles and curtailment.
*'
*'Additional grid capacities are calculated for high intermittent renewable capacity (solar and wind) and regional spatial differences. 
*'
*'Combined heat and power technologies flexibility is limited to technology and spatial observed data.
*'
*'Operation reserve requirements are enforced to provide enough flexibility to the power system frequency regulation.   
*'
*'Hydrogen can be used to reduce renewable power curtailment and provide flexibility to the system future generation. 
*'
*' @authors Robert Pietzcker, Falko Ueckerdt, Renato Rodrigues

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/32_power/IntC/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/32_power/IntC/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/32_power/IntC/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/32_power/IntC/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/32_power/IntC/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/32_power/IntC/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/32_power/IntC/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/32_power/IntC/realization.gms
