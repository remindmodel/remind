*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/realization.gms

*' @description implements a carbon price trajectory consistent with the NDC emissions targets for 2030 and 2035 
*' based on PBL target collection and own target calculations. NDC emissions targets of major emitters (China, India, EU etc.) are calculated
*' in mrremind (see toolCalcNDCTarget.R) based on the PBL NDC target collection and own assumptions. 
*' For minor emitters, targets are taken directly from the PBL collection in the emissions scope total GHG excl LULUCF (see mrremind: calcEmiTarget.R).
*' This realization implement the NDC emissions target per REMIND region assuming that the emissions of countries wthout NDC follow the NPi trajecory.
*' Regional co2 price are iteratively adjusted until NDC emissions targets are met within a sufficiently small deviation. 
*' By default, the region-specific limits on co2 price increase in 2030 and 2035 are applied to have plausible short-term behavior (see cm_CO2PriceLimit).
*' By default, co2 prices are kept constant after the last NDC target year. 

*' @limitations NDC targets are calculated and aggregate across countries in the scope of total GHG excl. LULUCF and excl. bunker emissions. 
*' While bunker emissions are generally excluded from NDC targets, LULUCF emissions are often included. For the calculation of the NDC targets, 
*' we assume that LULUCF emissions follow the NDC trajectory given by Forsell et al. (https://pure.iiasa.ac.at/id/eprint/20368/). 
*' Hence, LULUCF emissions are exogenuous to the target optimization at the moment. Moreover, some countries (China 2030) have smaller emissions scope (CO2 emissions only).
*' To calculate targets on total GHG level we need to make further assumptions about non-CO2 emissions in the input data preparation based on previous runs. 
*' Hence, the accuracy of CO2 only targets is limited to the extend that the exogenous assumptions coindice with the model outcome. 

*' @authors: Rahel Mandaroux, Felix Schreyer, Léa Hayez

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/NDC/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/NDC/datainput.gms"
$Ifi "%phase%" == "preloop" $include "./modules/45_carbonprice/NDC/preloop.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/NDC/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/45_carbonprice/NDC/realization.gms
