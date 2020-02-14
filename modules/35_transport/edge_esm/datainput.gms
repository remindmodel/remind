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
    entrp           0.8
      entrp_pass    1.3
      entrp_frgt    1.3
  /
;
pm_cesdata_sigma(ttot,in)$p35_cesdata_sigma(in) = p35_cesdata_sigma(in);

parameters
p35_esCapCost(tall,all_regi,all_GDPscen,EDGE_scenario_all,all_teEs) "Capital costs for the transport system [$/pkm or $/tkm]"
/
$ondelim
$include "./modules/35_transport/edge_esm/input/esCapCost.cs4r"
$offdelim
/

p35_fe2es(tall,all_regi,all_GDPscen,EDGE_scenario_all,all_teEs) "Aggregate energy efficiency of transport fuel technologies [trn pkm/Twa or trn tkm/Twa]"
/
$ondelim
$include "./modules/35_transport/edge_esm/input/fe2es.cs4r"
$offdelim
/

p35_demByTech(tall,all_regi,all_GDPscen,EDGE_scenario_all,all_enty,all_in,all_teEs) "Aggregate FE Demand per transport fuel technology [TWa]"
/
$ondelim
$include "./modules/35_transport/edge_esm/input/fe_demand_tech.cs4r"
$offdelim
/

* p35_demLimit(tall,all_regi,all_GDPscen,EDGE_scenario_all,all_in)
* /
* $ondelim
* $include "./modules/35_transport/edge_esm/input/dem_smart_Elpush.csv"
* $offdelim
* /

p35_shFeCes(tall,all_regi,all_GDPscen,EDGE_scenario_all,all_enty,all_in,all_teEs)                "Shares of "
;

*** overwrite starting points for policy runs for ES
if (cm_startyear gt 2005,
Execute_Loadpoint 'input_ref' p35_demByTech=p35_demByTech, p35_fe2es=p35_fe2es;
p35_esCapCost(ttot,regi,"%cm_GDPscen%",EDGE_scenario,teEs_dyn35) = 0;
);

*** calculate shares for fuels by CES node
p35_shFeCes(ttot,regi,"%cm_GDPscen%",EDGE_scenario,entyFe,ppfen_dyn35,teEs_dyn35)$fe2ces_dyn35(entyFe,ppfen_dyn35,teEs_dyn35) =
        p35_demByTech(ttot,regi,"%cm_GDPscen%",EDGE_scenario,entyFe,ppfen_dyn35,teEs_dyn35) / sum((entyFe2,teEs_dyn35_2)$fe2ces_dyn35(entyFe2,ppfen_dyn35,teEs_dyn35_2),p35_demByTech(ttot,regi,"%cm_GDPscen%",EDGE_scenario,entyFe2,ppfen_dyn35,teEs_dyn35_2));


*** set starting points
pm_esCapCost(ttot,regi,teEs_dyn35) = p35_esCapCost(ttot,regi,"%cm_GDPScen%","%cm_EDGEtr_scen%",teEs_dyn35);

pm_fe2es(ttot,regi,teEs_dyn35) = p35_fe2es(ttot,regi,"%cm_GDPScen%","%cm_EDGEtr_scen%",teEs_dyn35);

pm_shFeCes(ttot,regi,entyFe,ppfen_dyn35,teEs_dyn35)$fe2ces_dyn35(entyFe,ppfen_dyn35,teEs_dyn35) = p35_shFeCes(ttot,regi,"%cm_GDPScen%","%cm_EDGEtr_scen%",entyFe,ppfen_dyn35,teEs_dyn35);

*** workaround for nat. gas for transport -> should go to mmoinput at some point
pm_cf(ttot,regi,"tdfosgat") = 0.65;
pm_cf(ttot,regi,"tdbiogat") = 0.65;

*** EOF ./modules/35_transport/edge_esm/datainput.gms
