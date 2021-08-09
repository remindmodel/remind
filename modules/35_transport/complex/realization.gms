*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex.gms

*' @description Transport demand composition is calculated for LDV categories, electric trains and an aggregate category HDV.
*' The CES transport branch has 3 nodes (LDV, HDV and electric trains). LDVs are in turn divided into ICE cars, BEVs, FCEVs.
*' The CES branch is in useful energy units (EJ). A correction for the different efficiency of LDV powertrains is therefore included.
*' HDVs include both passenger and freight modes. Vehicles capacity addition for LDVs is calculated in REMIND.

*' @limitations Not very flexible implementation of new transport alternatives

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/35_transport/complex/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/35_transport/complex/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/35_transport/complex/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/35_transport/complex/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/35_transport/complex/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/35_transport/complex/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/35_transport/complex/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/35_transport/complex.gms
