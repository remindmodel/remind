*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/32_power/RLDC/realization.gms

*' @description  
*'
*'The `RLDC` realization (Residual Load Duration Curve) distinguish different operation electricity supply decisions under four distinct load bands, plus additional peak capacity requirements.
*'
*'This module determine power system supply specific technology behavior, which summs up to the general core capacity equations to define the power sector operation and investment decisions.
*'
*'Contrary to other secondary energies in REMIND, this requires to move the electricity secondary energy balance (supply = demand) from the core to the module code.
*'
*'
*'The residual load duration curve is obtained after discounting intermittent renewables generation (solar and wind) from the total demand.
*'
*'An exogenous unit commitment model (DIMES) is used to estimate a third degree fitting curve for each load band representing the intermittent renewables generation contribution at different renewable penetration shares in the system.
*'
*'Curtailament is defined using the same process - a per load band third degree fitting curve that determines the curtailment based on the renewables share.
*'
*'Dispatchable power generation technologies have their capacity factor endogenously determined by the use in the distinct load bands.
*'
*'Short term storage is dependable of wind and solar penetration shares and estimated exogenously to a third degree fitting curve.
*'
*'A reserve margin capacity is required to be provided by dispatchable technologies only. The reserve margin size is determined by the peak capacity that is also estimated exogenously for different levels of renewables penetration in the system.
*'
*'CSP co-firing with H2 or other gases is included. Self-correlation and PV correlation inside each load bands are considered.
*'
*'Hydrogen can be used to reduce renewable power curtailment and provide flexibility to the system future generation. 
*'
*'Hydropower load band flexibility is limited due to run-of-river power plants and water use regulation constraints.
*'
*'Combined heat and power technologies flexibility is limited to technology and spatial observed data.
*'
*'Additional grid capacities are calculated for high intermittent renewable capacity (solar and wind) and regional spatial differences. 
*'
*' @authors Robert Pietzcker, Falko Ueckerdt, Renato Rodrigues

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/32_power/RLDC/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/32_power/RLDC/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/32_power/RLDC/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/32_power/RLDC/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/32_power/RLDC/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/32_power/RLDC/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/32_power/RLDC/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/32_power/RLDC/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/32_power/RLDC/realization.gms

