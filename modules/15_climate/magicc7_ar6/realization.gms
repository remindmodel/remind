*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/magicc7_ar6/realization.gms

*' @description 
*' In this realization, concentration, forcing, and temperature values are calculated using a version of the 
*' MAGICC climate emulator. MAGICC has to be installed in a separate folder, which can be set in the `magicc_template`
*' switch. MAGICC version 6.4 is used as default, but other versions with compatible path structure and variable names 
*' can be used as well as long as it has the proper interfacing R scripts.
*'
*' The actual generation of MAGICC input data from REMIND emissions is not handled here, but in the core. Emissions that are not 
*' calculated by REMIND, such as F-gases, are taken from RCP trajectories. 
*'
*' With this module activated, MAGICC is run between iterations one time or several, depending on specific switches. 

*' By default, the global mean temperature change is simply read and passed on to other modules.

*' Depending on the choice of carbon tax adjustment in `cm_emiscen`, the total carbon budget will also be adjusted based on 
*' the MAGICC radiation forcing or temperature outcomes between iterations. This can allow the carbon tax, which is adjusted based on the carbon budget, to be optimized
*' for a given temperature target.

*' If `cm_magicc_temperatureImpulseResponse` is on, a new Temperature Impulse Response Function (TIRF)
*' is also generated between iterations. The TIRF is a smooth function that estimates the effect of an additional unit
*' of emissions in global temperature, and it's used by some damage modules that internalize climate damages (i.e. account
*' for damages within the optimization). To derive a TIRF, MAGICC is run several times with pulse emissions added around the
*' the emissions of that iteration.  

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/15_climate/magicc7_ar6/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/15_climate/magicc7_ar6/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/15_climate/magicc7_ar6/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/15_climate/magicc7_ar6/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/15_climate/magicc7_ar6/realization.gms
