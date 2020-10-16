*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/include.gms

$setglobal phase %1

*######################## R SECTION START (MODULES) ############################
$include "./modules/01_macro/module.gms"
$include "./modules/02_welfare/module.gms"
$include "./modules/04_PE_FE_parameters/module.gms"
$include "./modules/05_initialCap/module.gms"
$include "./modules/11_aerosols/module.gms"
$include "./modules/15_climate/module.gms"
$include "./modules/16_downscaleTemperature/module.gms"
$include "./modules/20_growth/module.gms"
$include "./modules/21_tax/module.gms"
$include "./modules/22_subsidizeLearning/module.gms"
$include "./modules/23_capitalMarket/module.gms"
$include "./modules/24_trade/module.gms"
$include "./modules/26_agCosts/module.gms"
$include "./modules/29_CES_parameters/module.gms"
$include "./modules/30_biomass/module.gms"
$include "./modules/31_fossil/module.gms"
$include "./modules/32_power/module.gms"
$include "./modules/33_CDR/module.gms"
$include "./modules/35_transport/module.gms"
$include "./modules/36_buildings/module.gms"
$include "./modules/37_industry/module.gms"
$include "./modules/38_stationary/module.gms"
$include "./modules/39_CCU/module.gms"
$include "./modules/40_techpol/module.gms"
$include "./modules/41_emicapregi/module.gms"
$include "./modules/42_banking/module.gms"
$include "./modules/45_carbonprice/module.gms"
$include "./modules/47_regipol/module.gms"
$include "./modules/50_damages/module.gms"
$include "./modules/51_internalizeDamages/module.gms"
$include "./modules/70_water/module.gms"
$include "./modules/80_optimization/module.gms"
$include "./modules/81_codePerformance/module.gms"
*######################## R SECTION END (MODULES) ##############################
*** EOF ./modules/include.gms
