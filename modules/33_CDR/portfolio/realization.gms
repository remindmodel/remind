*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/realization.gms

*' @description
*' (DACCS) Direct air capture uses heat and electricity to capture CO2 from the atmosphere,
*' which can then either be used or stored. Based on the climeworks technology described in Beutler et al. 2019,
*' we assume 5.28 EJ/Gt C (* 12 Gt C/44 Gt CO2) = 1.44 GJ/tCO2 (*10^6 kJ / GJ * 1h/3600s) =  400 kWh/tCO2
*' electricity and 21.12 EJ/Gt C (* 12 Gt C/44 Gt CO2) = 5,76 GJ/tCO2 (*10^6 kJ / GJ * 1h/3600s) = 1600 kWh/tCO2
*' low-temperature heat demand. The heat can be provided via district heat, electricity, gas, or H2. If gas is used,
*' the resulting CO2 is captured with a capture rate of 90%.
*' (EW) Basalt is mined and ground to fine grain sizes (specified in cm_gs_ew, by default 20 µm), and then spread
*' on crop fields where it weathers in reaction with water and atmospheric CO2. Electricity is needed to grind the
*' rocks and diesel is needed for transportation and spreading on crop fields. The weathering process leads to an exponential
*' decay over time of the spread rocks. There is an upper limit on the amount of rock that can be on the fields, so that
*' in equilibrium only the part that decays in one timestep can be replaced in the next. In addition, an arbitrary
*' limit of the amount of rock spread each year can be set in cm_LimRock. Costs consist of costs for capital, O&M,
*' distribution and transport (grades depend on region specific transport distance from mine to fields).
*'
*' Equations for each option determine the capacity, emissions, energy demand, costs and limits.
***----------------------------------------------------

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/33_CDR/portfolio/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/33_CDR/portfolio/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/33_CDR/portfolio/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/33_CDR/portfolio/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/33_CDR/portfolio/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/33_CDR/portfolio/realization.gms
