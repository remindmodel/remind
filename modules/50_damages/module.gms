*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/50_damages/module.gms

*' @title Damages
*'
*' @description If turned on, the 50_damages module calculates damages between iterations based on global mean temperature paths from MAGICC. Different damage specifications are available, currently based on DICE and @Burke2015. Damages are internalized in the optimization in module 51_internalizeDamages. Without that, they enter the optimization as a fixed variable reducing output in the budget equation. The method and the advanced specification of the Burke damage function are described in @Schultes2020.
*'
*' @authors Anselm Schultes, Franziska Piontek

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%damages%" == "BurkeLike" $include "./modules/50_damages/BurkeLike/realization.gms"
$Ifi "%damages%" == "DiceLike" $include "./modules/50_damages/DiceLike/realization.gms"
$Ifi "%damages%" == "KWLike" $include "./modules/50_damages/KWLike/realization.gms"
$Ifi "%damages%" == "KWTCint" $include "./modules/50_damages/KWTCint/realization.gms"
$Ifi "%damages%" == "KW_SE" $include "./modules/50_damages/KW_SE/realization.gms"
$Ifi "%damages%" == "Labor" $include "./modules/50_damages/Labor/realization.gms"
$Ifi "%damages%" == "TC" $include "./modules/50_damages/TC/realization.gms"
$Ifi "%damages%" == "off" $include "./modules/50_damages/off/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/50_damages/module.gms
