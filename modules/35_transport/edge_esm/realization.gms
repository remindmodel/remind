*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm.gms

*' @description Transport demand composition is calculated based on the EDGE-transport model.
*' This realization allows the EDGE-transport model to interact with REMIND. EDGE is set to run in between iterations. 
*' EDGE runs every 5 iterations, to allow REMIND to stabilize in between. Transport structure is defined in detail in 
*' EDGE, and only aggregate values are then fed to REMIND. The CES transport branch has 2 nodes (passenger and freight 
*' transport) each divided into Short-Medium distance and Long distance options. The CES branch is in energy services units 
*' (passenger or ton km). Bunkers (Shipping and Internaitional Aviation) represent the Long distance CES leaves. Vehicles 
*' capacity addition is calculated in EDGE (REMIND has no vintage tracking).

*' @limitations EDGE-transport runs in between iterations and is therefore not fully optimized.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/35_transport/edge_esm/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/35_transport/edge_esm/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/35_transport/edge_esm/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/35_transport/edge_esm/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/35_transport/edge_esm/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/35_transport/edge_esm/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/35_transport/edge_esm/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/35_transport/edge_esm/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/35_transport/edge_esm.gms
