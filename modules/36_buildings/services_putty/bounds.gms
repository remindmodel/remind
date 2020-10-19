*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_putty/bounds.gms
vm_enerSerAdj.fx("2005",regi,in) = 0; 

if ((cm_noReboundEffect eq 1 ), !! Fix the upper bound of vm_cesIO to the level of input_ref if no rebound is allowed
vm_cesIO.up(t,regi,in)$(sameAs(in,"esswb") OR sameAs(in,"uealb") OR sameAs(in,"uecwb")) = (1 + 1e-14) * p36_cesIONoRebound(t,regi,in);
vm_cesIO.lo(t,regi,in)$(sameAs(in,"esswb") OR sameAs(in,"uealb") OR sameAs(in,"uecwb")) = (1 - 1e-14) * p36_cesIONoRebound(t,regi,in);
vm_cesIOdelta.up(t,regi,in)$(sameAs(in,"esswb") OR sameAs(in,"uealb") OR sameAs(in,"uecwb")) = (1 + 1e-14) * p36_cesIONoRebound_putty(t,regi,in);
vm_cesIOdelta.lo(t,regi,in)$(sameAs(in,"esswb") OR sameAs(in,"uealb") OR sameAs(in,"uecwb")) = (1 - 1e-14) * p36_cesIONoRebound_putty(t,regi,in);
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


***-------------------------------------------------------------
*** Additional bounds
***-------------------------------------------------------------
$ifThen.regiPhaseOutFosBuil not "%cm_regiPhaseOutFosBuil%" == "none"
*** Exogenous phase out of oil and gas in buildings according to switch.
*** This sets the capacity additions to zero for all years greater equal
*** the one defined by p36_yearPhaseOutFosBuil for each region
  v36_deltaProdEs.up(t,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs))$(
    sameAs(teEs, "te_ueshgab") AND p36_yearPhaseOutFosBuil(regi) AND t.val ge p36_yearPhaseOutFosBuil(regi)) = 1e-9;
  v36_deltaProdEs.up(t,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs))$(
    sameAs(teEs, "te_ueshhob") AND p36_yearPhaseOutFosBuil(regi) AND t.val ge p36_yearPhaseOutFosBuil(regi)) = 1e-9;
  v36_deltaProdEs.up(t,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs))$(
    sameAs(teEs, "te_uecwgab") AND p36_yearPhaseOutFosBuil(regi) AND t.val ge p36_yearPhaseOutFosBuil(regi)) = 1e-9;
  v36_deltaProdEs.up(t,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs))$(
    sameAs(teEs, "te_uecwhob") AND p36_yearPhaseOutFosBuil(regi) AND t.val ge p36_yearPhaseOutFosBuil(regi)) = 1e-9;
$endIf.regiPhaseOutFosBuil

*** EOF ./modules/36_buildings/services_putty/bounds.gms
