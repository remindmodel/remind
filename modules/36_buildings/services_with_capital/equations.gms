*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/equations.gms

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
q36_ueTech2Total(ttot,regi_dyn36(regi),inViaEs_dyn36(in)) $
                                  ( (s36_vintage_calib eq 1 AND t36_hist(ttot) )
                                    OR ((s36_logit eq 1) AND (ttot.val ge cm_startyear)) ) ..
      p36_demUEtotal(ttot,regi,in)
      + v36_logitInfes(ttot,regi,in)
      =e= 
      sum (fe2ces_dyn36(enty,esty,teEs,in),
        v36_prodEs(ttot,regi,enty,esty,teEs) 
      );
      
      
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


*** EOF ./modules/36_buildings/services_with_capital/equations.gms
