*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/BurkeLike.gms

*' @description Output damages are calculated based on the damage function from @Burke2015, extended by a finite persistence term. The details are described in @Schultes2020. The persistence is a parameter to be specified in the config file (cm_damages_BurkeLike_persistenceTime). Two different damage realizations can be chosen via the switch cm_damages_BurkeLike_specification. "0" uses the short-run specification without lags, "1" the long-run specification. Damages are calculated on the regional level, the global temperature path from MAGICC is scaled to REMIND regions in module 16_downscaleTemperature, requiring the setting downscaleTemperature=CMIP5. 

*' @limitations: Currently only valid for RCP2.6, as for higher RCPs there is no limit for too extreme out-of-sample extrapoliations in terms of temperature (as it is done in Burke paper). Also the temperature downscaling requires a scaling parameter which is currently only included for RCP2.6 and RCP8.5 and for SSP2 population. Furthermore, unless the realization "BurkeLikeItr" is used for module 51_internalizeDamages, the damages are not actually part of the optimization, but just enter as a fixed variable reducing output, updated in between iterations.  

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/50_damages/BurkeLike/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/50_damages/BurkeLike/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/50_damages/BurkeLike/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/50_damages/BurkeLike/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/50_damages/BurkeLike.gms
