*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/declarations.gms
Parameters
p35_fe2es_aux(tall,all_regi,all_GDPscen,all_demScen,EDGE_scenario_all,all_teEs) "Aggregate energy efficiency of transport fuel technologies [trn pkm/Twa or trn tkm/Twa]"
;
Equations
q35_demFeTrans(ttot,all_regi,all_enty,all_emiMkt) "Transport final energy demand"
$IFTHEN.transpGDPscale "%cm_transpGDPscale%" == "on" 
q35_transGDPshare(ttot,all_regi)  "Calculating dampening factor to align edge-t non-energy transportation costs with historical GDP data"
$ENDIF.transpGDPscale
;

*** EOF ./modules/35_transport/edge_esm/declarations.gms
