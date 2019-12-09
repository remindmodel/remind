*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/datainput.gms
Parameter
  p35_cesdata_sigma(all_in)  "substitution elasticities"
  /
    entrp           1.3
      entrp_pass    1.1
      entrp_frgt    1.1
  /
;
pm_cesdata_sigma(ttot,in)$p35_cesdata_sigma(in) = p35_cesdata_sigma(in);

parameters
p35_esCapCost(tall,all_regi,all_in)    "???"
/
$ondelim
$include "./modules/35_transport/edge_esm/input/esCapCost.cs4r"
$offdelim
/

p35_fe2es(tall,all_regi,all_teEs)     "???"
/
$ondelim
$include "./modules/35_transport/edge_esm/input/fe2es.cs4r"
$offdelim
/

p35_shFeCes(tall,all_regi,all_enty,all_in)    "???"
/
$ondelim
$include "./modules/35_transport/edge_esm/input/shFeCes.cs4r"
$offdelim
/
;

*** starting points:
pm_esCapCost(t,regi,ppfen_dyn35) = p35_esCapCost(t,regi,ppfen_dyn35);

pm_fe2es(t,regi,teEs_dyn35) = p35_fe2es(t,regi,teEs_dyn35);

pm_shFeCes(t,regi,entyFe,ppfen_dyn35)$p35_shFeCes(t,regi,entyFe,ppfen_dyn35) = p35_shFeCes(t,regi,entyFe,ppfen_dyn35);


*** EOF ./modules/35_transport/edge_esm/datainput.gms
