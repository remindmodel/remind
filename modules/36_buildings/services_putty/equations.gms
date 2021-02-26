*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_putty/equations.gms

*** Can you please structure which equations belongs to which model?

***  Buildings Final Energy Balance
q36_demFeBuild(ttot,regi,entyFe,emiMkt)$((ttot.val ge cm_startyear) AND (entyFe2Sector(entyFe,"build"))) .. 
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(ttot,regi,entySe,entyFe,"build",emiMkt)) 
  =e=
  (
    sum(fe2ppfEn36(entyFe,in),
      vm_cesIO(ttot,regi,in)
      + pm_cesdata(ttot,regi,in,"offset_quantity")
    )
    +
    sum(fe2es_dyn36(entyFe,esty,teEs), vm_demFeForEs(ttot,regi,entyFe,esty,teEs) ) 
  )$(sameas(emiMkt,"ES"))
;

*** Couldn't we also formulate an ES to ppfen handover function instead of pushing this to the postsolve.gms? It would be easier to follow.

*AL* Start of Model solved in preloop for determining the floorspace delta projections
q36_pathConstraint (ttot,regi) $((s36_switch_floor eq 1) AND (ord(ttot) lt card(ttot)) AND (ttot.val ge cm_startyear)) ..
p36_floorspace(ttot + 1,regi) =e=
  (1- pm_delta_kap(regi,"esswb"))**pm_dt(ttot+1) * p36_floorspace(ttot,regi)
                                 + (pm_cumDeprecFactor_old(ttot+1,regi,"esswb") *  v36_floorspace_delta(ttot,regi))                                  
                                 + (pm_cumDeprecFactor_new(ttot+1,regi,"esswb") *  v36_floorspace_delta(ttot+1,regi))
                                 ;


                         
q36_putty_obj$(s36_switch_floor eq 1)..                                 
v36_putty_obj =e= sum((ttot,regi,in)$((ord(ttot) lt card(ttot)))
                                      , power( v36_floorspace_delta(ttot+1,regi)
                                                - v36_floorspace_delta(ttot,regi)
                                                
                                       ,2)
                                       
                   );
*AL* End of Model solved in preloop 

q36_enerSerAdj(ttot,regi,in)$(sameas (in, "esswb") AND ttot.val ge max(2010, cm_startyear)).. 
         vm_enerSerAdj(ttot,regi,in) 
         =e=
         p36_adjFactor(ttot,regi)
         * sqr( 
               (vm_cesIOdelta(ttot,regi,in) / p36_floorspace_delta(ttot,regi)
                - vm_cesIOdelta(ttot-1,regi,in) / p36_floorspace_delta(ttot-1,regi)) 
              / (pm_ttot_val(ttot)-pm_ttot_val(ttot-1)) 
               / (vm_cesIOdelta(ttot,regi,in)  / p36_floorspace_delta(ttot,regi) +0.0001)
            )
         * vm_cesIOdelta(ttot,regi,in) / 11
         ;


q36_enerCoolAdj(ttot,regi,in)$(sameas (in, "fescelb") 
                               AND ttot.val ge max(2015, cm_startyear)
                               AND regi_dyn36_cooling(regi) ).. 
         vm_enerSerAdj(ttot,regi,in) 
         =e=
         p36_adjFactor(ttot,regi)
         * sum (cesOut2cesIn(out,in),
                sqr ( 
                     (vm_cesIO(ttot,regi,out) / vm_cesIO(ttot,regi,in)  !! Efficiency in ttot
                      - vm_cesIO(ttot - 1,regi,out) / vm_cesIO(ttot - 1,regi,in)  !! Efficiency in ttot -1
                      ) / (pm_ttot_val(ttot) - pm_ttot_val(ttot - 1)) 
                      -
                      (vm_cesIO(ttot - 1,regi,out) / vm_cesIO(ttot - 1,regi,in)  !! Efficiency in ttot -1
                      - vm_cesIO(ttot - 2,regi,out) / vm_cesIO(ttot - 2,regi,in)  !! Efficiency in ttot -2
                      ) / (pm_ttot_val(ttot - 1) - pm_ttot_val(ttot - 2))
                )
           )        
;         

*******************************************
*** Equations of the logit model **********
*******************************************



*** total UE buildings demand, based on the sum of demand by technology
q36_ueTech2Total(ttot,regi_dyn36(regi),inViaEs_dyn36(in)) $
                                  ( (s36_vintage_calib eq 1 AND t36_hist(ttot) )
                                    OR ((s36_logit eq 1) AND (ttot.val ge cm_startyear)) ) ..
      p36_demUEtotal(ttot,regi,in)
      + v36_logitInfes(ttot,regi,in)
      =e= 
      sum (fe2ces_dyn36(enty,esty,teEs,in),
        v36_prodEs(ttot,regi,enty,esty,teEs) 
      );
      
*** In what sense is this calculating capacities? Are you referring to useful energy as capacities? That should be in energy units. 
*** What is the difference between v36_prodEs and v36_deltaProdEs? 

q36_cap(ttot,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs)) $
                            ( ((s36_vintage_calib eq 1) AND (t36_hist(ttot) ))
                                    OR ((s36_logit eq 1) AND (ttot.val ge cm_startyear)) ) ..
   
    v36_prodEs(ttot,regi,enty,esty,teEs)
   =e=
   sum(opTimeYr2teEs(teEs,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
                  pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1)) 
                * p36_omegEs(regi,opTimeYr+1,teEs)
                * (v36_deltaProdEs(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,enty,esty,teEs)
                   - v36_vintageInfes(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,enty,esty,teEs)
                   )
            )
 !! half of the last time step ttot
        +  pm_dt(ttot)/2 
         * p36_omegEs(regi,"2",teEs)
         * (v36_deltaProdEs(ttot,regi,enty,esty,teEs)
            - v36_vintageInfes(ttot,regi,enty,esty,teEs)
         )
   ; 
   
q36_budget(t36_scen(ttot),regi_dyn36(regi))..
   v36_costs(ttot,regi)    
   =e=
   sum ( fe2ces_dyn36(enty,esty,teEs,in),
        p36_techCosts(ttot,regi,enty,esty,teEs)
        * v36_deltaProdEs(ttot,regi,enty,esty,teEs)
        )
    ;    

*** What is the purpose of the objetve function of the vintage model?   
q36_vintage_obj $  (s36_vintage_calib eq 1  ) ..
   v36_vintage_obj
   =e=
   sum((ttot,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs))$(
                                t36_hist(ttot)
                                ),
                                
                 sum(opTimeYr2teEs(teEs,opTimeYr)$(
                                          tsu2opTimeYr(ttot,opTimeYr)
                                          ),
                     power ( 
                     v36_deltaProdEs(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)),regi,enty,esty,teEs)
                     - v36_deltaProdEs(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,enty,esty,teEs)
                     ,2
                     )
                     
                     +
                     1000
                     * v36_vintageInfes(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)),regi,enty,esty,teEs)
                 )
                 +   1000
                     * v36_vintageInfes(ttot,regi,enty,esty,teEs)               
       )
      
   ;

*** Can you explain what this objective function is? 
*** Why does its maximization give the output of the logit function
*** which should (I guess) be the UE shares based on the cost of the fe2ue technology output.  
*** Also I do not recognize the logit formulation from before. 
q36_shares_obj $ (s36_logit eq 1)..
   v36_shares_obj
   =e=
   sum ((t36_scen(ttot),regi_dyn36(regi),inViaEs_dyn36(in)),
        sum ( fe2ces_dyn36(enty,esty,teEs,in),
             - p36_logitCalibration(ttot,regi,enty,esty,teEs)
             * v36_deltaProdEs(ttot,regi,enty,esty,teEs)
             )
        + 1 / p36_logitLambda(regi,in)
          * sum ( fe2ces_dyn36(enty,esty,teEs,in),
                  v36_deltaProdEs(ttot,regi,enty,esty,teEs)
                  * log ( v36_deltaProdEs(ttot,regi,enty,esty,teEs)
                         / sum (fe2ces_dyn36_2(enty2,esty2,teEs2,in),
                                v36_deltaProdEs(ttot,regi,enty2,esty2,teEs2))
                         )
                 )        
        )
        
      - sum ( (t36_scen(ttot),regi_dyn36(regi)),
              v36_costs(ttot,regi)
              ) 
              
      - sum ((ttot,regi_dyn36(regi),fe2es_dyn36(enty,esty,teEs)),
             1000
             * v36_vintageInfes(ttot,regi,enty,esty,teEs)
            )
      - sum ((ttot,regi_dyn36(regi),inViaEs_dyn36(in)),
            1000
            *  v36_logitInfes(ttot,regi,in)
            )
    ;  


*** EOF ./modules/36_buildings/services_putty/equations.gms
