*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/preloop.gms

*** Vintage initialisation
v36_prodEs.lo(ttot,regi,fe2es_dyn36(enty,esty,teEs))      = 0;              
v36_deltaProdEs.lo(ttot,regi,fe2es_dyn36(enty,esty,teEs)) = 0;
v36_vintageInfes.lo(ttot,regi,fe2es_dyn36(enty,esty,teEs)) = 0;


s36_vintage_calib = 1;
v36_logitInfes.fx(ttot,regi_dyn36(regi),inViaEs_dyn36(in)) = 0;
v36_prodEs.fx(t36_hist(ttot),regi_dyn36(regi), fe2es_dyn36(entyFe,esty,teEs)) 
             = p36_prodEs(ttot,regi,entyFe,esty,teEs);

model vintage_36 /
q36_ueTech2Total
q36_cap
q36_vintage_obj
/;

solve vintage_36 minimizing v36_vintage_obj using nlp;

if ( NOT ( vintage_36.solvestat eq 1  AND (vintage_36.modelstat eq 1 OR vintage_36.modelstat eq 2)),
abort "model vintage_36 is infeasible";
);

p36_prodUEintern(t36_hist(ttot),regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs)) 
               = v36_deltaProdEs.L(ttot,regi,enty,esty,teEs);

s36_vintage_calib = 0;


*** Define model for logit shares
model logit_36 /
q36_ueTech2Total
q36_cap
q36_shares_obj
q36_budget
/
;
*** The value of the capital price cannot be set in datainput as in calibration runs, pm_cesdata is computed in preloop.gms of module 29
p36_kapPrice(t,regi_dyn36(regi)) = pm_cesdata(t,regi,"kap","price") - pm_delta_kap(regi,"kap"); 
loop (fe2ces_dyn36(entyFe,esty,teEs,in),
p36_kapPriceImplicit(t,regi_dyn36(regi),teEs) = p36_kapPrice(t,regi) + p36_implicitDiscRateMarg(t,regi,in);
);

*** EOF ./modules/36_buildings/services_with_capital/preloop.gms
