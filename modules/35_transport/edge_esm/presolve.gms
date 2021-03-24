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
$ifthen.EDGEtr_ElecEraEur "%cm_EDGEtr_scen%" == "ElecEraEur"
    pm_esCapCost(t,regi, teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_esCapCost(t,regi, "%cm_GDPscen%","ConvCase",teEs_dyn35);
    pm_esCapCost(t,"EUR",teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_esCapCost(t,"EUR","%cm_GDPscen%","ElecEra", teEs_dyn35);

$elseif.EDGEtr_ElecEraEur "%cm_EDGEtr_scen%" == "ElecEraEurWise"
    pm_esCapCost(t,regi, teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_esCapCost(t,regi, "%cm_GDPscen%","ConvCase",    teEs_dyn35);
    pm_esCapCost(t,"EUR",teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_esCapCost(t,"EUR","%cm_GDPscen%","ElecEraWise", teEs_dyn35);

$else.EDGEtr_ElecEraEur
    pm_esCapCost(t,regi,teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_esCapCost(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%",teEs_dyn35);
$endif.EDGEtr_ElecEraEur


    Execute_Loadpoint "p35_fe2es", p35_fe2es_aux = p35_fe2es;
$ifthen.EDGEtr_ElecEraEur "%cm_EDGEtr_scen%" == "ElecEraEur"
    pm_fe2es(t,regi, teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100)
    = p35_fe2es_aux(t,regi, "%cm_GDPscen%","ConvCase",teEs_dyn35);
    pm_fe2es(t,"EUR",teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100)
    = p35_fe2es_aux(t,"EUR","%cm_GDPscen%","ElecEra", teEs_dyn35);
$elseif.EDGEtr_ElecEraEur "%cm_EDGEtr_scen%" == "ElecEraEurWise"
    pm_fe2es(t,regi, teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100)
    = p35_fe2es_aux(t,regi, "%cm_GDPscen%","ConvCase",teEs_dyn35);
    pm_fe2es(t,"EUR",teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100)
    = p35_fe2es_aux(t,"EUR","%cm_GDPscen%","ElecEraWise", teEs_dyn35);
$else.EDGEtr_ElecEraEur
    pm_fe2es(t,regi,teEs_dyn35)$(t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100)
    = p35_fe2es_aux(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%",teEs_dyn35);
$endif.EDGEtr_ElecEraEur

    Execute_Loadpoint 'p35_shFeCes' p35_shFeCes;
$ifthen.EDGEtr_ElecEraEur "%cm_EDGEtr_scen%" == "ElecEraEur"
    pm_shFeCes(t,regi, entyFe,ppfen_dyn35,teEs_dyn35)$(p35_shFeCes(t,regi, "%cm_GDPscen%","ConvCase",entyFe,ppfen_dyn35,teEs_dyn35) AND t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_shFeCes(t,regi, "%cm_GDPscen%","ConvCase",entyFe,ppfen_dyn35,teEs_dyn35);
    pm_shFeCes(t,"EUR",entyFe,ppfen_dyn35,teEs_dyn35)$(p35_shFeCes(t,"EUR","%cm_GDPscen%","ElecEra", entyFe,ppfen_dyn35,teEs_dyn35) AND t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_shFeCes(t,"EUR","%cm_GDPscen%","ElecEra", entyFe,ppfen_dyn35,teEs_dyn35);
$elseif.EDGEtr_ElecEraEur "%cm_EDGEtr_scen%" == "ElecEraEurWise"
    pm_shFeCes(t,regi, entyFe,ppfen_dyn35,teEs_dyn35)$(p35_shFeCes(t,regi, "%cm_GDPscen%","ConvCase",    entyFe,ppfen_dyn35,teEs_dyn35) AND t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_shFeCes(t,regi, "%cm_GDPscen%","ConvCase",    entyFe,ppfen_dyn35,teEs_dyn35);
    pm_shFeCes(t,"EUR",entyFe,ppfen_dyn35,teEs_dyn35)$(p35_shFeCes(t,"EUR","%cm_GDPscen%","ElecEraWise", entyFe,ppfen_dyn35,teEs_dyn35) AND t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_shFeCes(t,"EUR","%cm_GDPscen%","ElecEraWise", entyFe,ppfen_dyn35,teEs_dyn35);
$else.EDGEtr_ElecEraEur
    pm_shFeCes(t,regi,entyFe,ppfen_dyn35,teEs_dyn35)$(p35_shFeCes(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%",entyFe,ppfen_dyn35,teEs_dyn35) AND t.val gt 2010 AND t.val ge cm_startyear AND t.val le 2100) = p35_shFeCes(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%",entyFe,ppfen_dyn35,teEs_dyn35);
$endif.EDGEtr_ElecEraEur
);
$endif.calibrate

*** EOF ./modules/35_transport/edge_esm/presolve.gms
