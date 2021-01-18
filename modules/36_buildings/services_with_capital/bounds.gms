*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/bounds.gms
if ((cm_noReboundEffect eq 1 ), !! Fix the upper bound of vm_cesIO to the level of input_ref if no rebound is allowed
vm_cesIO.up(t,regi,in)$(sameAs(in,"esswb") OR sameAs(in,"uealb") OR sameAs(in,"uecwb")) = (1 + 1e-14) * p36_cesIONoRebound(t,regi,in);
vm_cesIO.lo(t,regi,in)$(sameAs(in,"esswb") OR sameAs(in,"uealb") OR sameAs(in,"uecwb")) = (1 - 1e-14) * p36_cesIONoRebound(t,regi,in);
);


loop (t36_hist_last(ttot2) ,
       v36_deltaProdEs.lo(ttot,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs)) $ (
                    ttot.val le ttot2.val)  
                    = max ( 0,
                            v36_deltaProdEs.L(ttot,regi,enty,esty,teEs)
                            -1e-6
                            )
                     ;
       v36_deltaProdEs.up(ttot,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs)) $ (
                    ttot.val le ttot2.val)  
                    =  v36_deltaProdEs.L(ttot,regi,enty,esty,teEs)
                            +1e-6
                     ;              
      );
v36_deltaProdEs.lo(t36_scen(ttot),regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs)) = 1e-9;  

v36_vintageInfes.fx(ttot,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs)) $(
  v36_vintageInfes.L(ttot,regi,enty,esty,teEs)) 
  = v36_vintageInfes.L(ttot,regi,enty,esty,teEs);
  
v36_vintageInfes.fx(ttot,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs)) $(
  NOT v36_vintageInfes.L(ttot,regi,enty,esty,teEs)) 
  = 0;

v36_logitInfes.up(t,regi_dyn36(regi),inViaEs_dyn36(in)) = + INF ;  

*** EOF ./modules/36_buildings/services_with_capital/bounds.gms
