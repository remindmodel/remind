*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/35_transport.gms

*' @title Transport
*'
*' @description  The 35_transport module calculates the transport demand composition as a part of the CES structure.
*'
*' @authors Alois Dirnaichner, Robert Pietzcker, Marianna Rottoli

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%transport%" == "complex" $include "./modules/35_transport/complex/realization.gms"
$Ifi "%transport%" == "edge_esm" $include "./modules/35_transport/edge_esm/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
*** EOF ./modules/35_transport/35_transport.gms
