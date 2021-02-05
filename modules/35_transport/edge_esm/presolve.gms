*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/presolve.gms
$ifthen.calibrate %CES_parameters% == "load"
if( (ord(iteration) le 25 and ord(iteration) ge 14 and (mod(ord(iteration), 3) eq 0))
    or (ord(iteration) le 45  and ord(iteration) gt 25 and  (mod(ord(iteration), 5) eq 0))
    or (ord(iteration)  gt 45 and  (mod(ord(iteration), 8) eq 0)),

    Execute "Rscript EDGE_transport.R";

    Execute_Loadpoint 'p35_esCapCost' p35_esCapCost;
    pm_esCapCost(t,regi,teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_esCapCost(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%",teEs_dyn35);

    !! load FE-to-ES results from EDGE-Transport into auxilliary parameter
    Execute_Loadpoint "p35_fe2es", p35_fe2es_aux = p35_fe2es;
    !! update module parameter with EDGE-Transport results, preserving 2005 data
    !! so no altered 2005 data gets passed on to potential fixed runs
    p35_fe2es(t,regi,all_GDPscen,EDGE_scenario,teES_dyn35)$( t.val gt 2005 ) 
    = p35_fe2es_aux(t,regi,all_GDPscen,EDGE_scenario,teES_dyn35);
    !! up date model parameter with data after 2010
    pm_fe2es(t,regi,teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100)
    = p35_fe2es_aux(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%",teEs_dyn35);

    Execute_Loadpoint 'p35_shFeCes' p35_shFeCes;
    pm_shFeCes(t,regi,entyFe,ppfen_dyn35,teEs_dyn35)$(p35_shFeCes(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%",entyFe,ppfen_dyn35,teEs_dyn35) AND t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_shFeCes(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%",entyFe,ppfen_dyn35,teEs_dyn35);
);
$endif.calibrate

*** EOF ./modules/35_transport/edge_esm/presolve.gms
