*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/presolve.gms
Execute "Rscript EDGE_sharecalculation.R"

Execute_Loadpoint 'p35_esCapCost' p35_esCapCost;
pm_esCapCost(t,regi,ppfen_dyn35) = p35_esCapCost(t,regi,ppfen_dyn35);

Execute_Loadpoint 'p35_fe2es' p35_fe2es;
pm_fe2es(t,regi,teEs_dyn35) = p35_fe2es(t,regi,teEs_dyn35);

Execute_Loadpoint 'p35_shFeCes' p35_shFeCes;
pm_shFeCes(t,regi,entyFe,ppfen_dyn35)$p35_shFeCes(t,regi,entyFe,ppfen_dyn35) = p35_shFeCes(t,regi,entyFe,ppfen_dyn35);

*** EOF ./modules/35_transport/edge_esm/presolve.gms
