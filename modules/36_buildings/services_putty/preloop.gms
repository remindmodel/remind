*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_putty/preloop.gms

v36_floorspace_delta.lo(tall,all_regi) = 1e-6;

if( (cm_startyear gt 2005),
    Execute_Loadpoint 'input_ref' p36_floorspace_delta_gdx = v36_floorspace_delta.L;
    v36_floorspace_delta.fx(ttot,regi)$( (ttot.val ge 2005) and (ttot.val lt cm_startyear)) = p36_floorspace_delta_gdx(ttot,regi);
);   

s36_switch_floor = 1;

model putty_paths_floor /
q36_pathConstraint
q36_putty_obj
/;



if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve putty_paths_floor minimizing v36_putty_obj using nlp;

if ( NOT ( putty_paths_floor.solvestat eq 1  AND (putty_paths_floor.modelstat eq 1 OR putty_paths_floor.modelstat eq 2)),
  execute_unload "abort.gdx";
  abort "model putty_paths_floor is infeasible";
);

p36_floorspace_delta(ttot,regi_dyn36(regi)) $ v36_floorspace_delta.L(ttot,regi) = v36_floorspace_delta.L(ttot,regi);

s36_switch_floor = 0;


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

if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

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

*** EOF ./modules/36_buildings/services_putty/preloop.gms

