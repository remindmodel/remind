*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/realization.gms

*' @description
*' (DAC) Direct air capture uses heat and electricity to capture CO2 from the atmosphere,
*' which can then either be used or stored. Modelled is a low-temperature solid adsorbent process based 
*' on the climeworks technology described in Beuttler et al. 2019.
*' We assume 5.28 EJ/Gt C (* 12 Gt C/44 Gt CO2) = 1.44 GJ/tCO2 (*10^6 kJ / GJ * 1h/3600s) =  400 kWh/tCO2
*' electricity and 21.12 EJ/Gt C (* 12 Gt C/44 Gt CO2) = 5,76 GJ/tCO2 (*10^6 kJ / GJ * 1h/3600s) = 1600 kWh/tCO2
*' low-temperature heat demand. The heat can be provided via district heat, electricity, gas, or H2. If gas is used,
*' the resulting CO2 is captured with a capture rate of 90%.
*'
*' (EW) Basalt is mined and ground to fine grain sizes (specified in cm_gs_ew, by default 20 µm), and then spread
*' on crop fields where it weathers in reaction with water and atmospheric CO2. Electricity is needed to grind the
*' rocks and diesel is needed for transportation and spreading on crop fields. The weathering process leads to an exponential
*' decay over time of the spread rocks. There is an upper limit on the amount of rock that can be on the fields, so that
*' in equilibrium only the part that decays in one timestep can be replaced in the next. In addition, an arbitrary
*' limit of the amount of rock spread each year can be set in cm_LimRock. Costs consist of costs for capital, O&M,
*' distribution and transport (grades depend on region specific transport distance from mine to fields).
*'
*' (OAE) Ocean alkalinity enhancement via ocean liming draws down CO2 from the atmosphere by adding (hydrated) lime
*' to the coastal or open ocean. Calcination process, which involves heating limestone to typically around 900-1000°C,
*' results in lime (CaO) and CO2. The CO2 from the process as well as burning gas  (if used for fueling the calciner)
*' is assumed to be captured with a capture rate of 90%. The steps required to produce hydrated lime for ocean liming,
*' including limestone extraction, comminution, calcination, and hydration, are already well-established and used at a
*' large scale in the cement industry. Two options for ocean liming are parametrized: obtaining lime using a traditional
*' calciner fueled by natural gas and a novel calciner that can be fueled by either electricity or hydrogen. The efficiency
*' of the method depends on exogenous parameter cm_33_OAE_eff and distribution scenario (which can be optimistic or
*' pesimistic depending on the discharge rate, e.g., how hard it is to avoid precipitation when distributing the alkaline
*' material).
*'
*' Equations for each option determine the capacity, emissions, energy demand, costs and limits.
***----------------------------------------------------

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/33_CDR/portfolio/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/33_CDR/portfolio/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/33_CDR/portfolio/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/33_CDR/portfolio/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/33_CDR/portfolio/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/33_CDR/portfolio/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/33_CDR/portfolio/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/33_CDR/portfolio/realization.gms
