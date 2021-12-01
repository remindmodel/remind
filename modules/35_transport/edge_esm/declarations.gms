*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/declarations.gms
Parameters
p35_fe2es_aux(tall,all_regi,all_GDPscen,EDGE_scenario_all,all_teEs) "Aggregate energy efficiency of transport fuel technologies [trn pkm/Twa or trn tkm/Twa]"
;
Equations
q35_demFeTrans(ttot,all_regi,all_enty,all_emiMkt) "Transport final energy demand"
;

*** EOF ./modules/35_transport/edge_esm/declarations.gms
