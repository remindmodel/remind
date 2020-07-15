*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_putty/equations.gms

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

q36_ueTech2Total(ttot,regi_dyn36(regi),inViaEs_dyn36(in)) $
                                  (t36_hist(ttot) ) ..
      p36_demUEtotal(ttot,regi,in)
      =e= 
      sum (fe2ces_dyn36(enty,esty,teEs,in),
        v36_prodEs(ttot,regi,enty,esty,teEs) 
      );
      
q36_cap(ttot,regi_dyn36(regi),fe2ces_dyn36(enty,esty,teEs,in)) $
                                  (t36_hist(ttot) ) ..
   v36_prodEs(ttot,regi,enty,esty,teEs)
   =e=
   sum(opTimeYr2teEs(teEs,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
                  pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1)) 
                * p36_omegEs(regi,opTimeYr+1,teEs)
                * v36_deltaProdEs(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,enty,esty,teEs)
            )
 !! half of the last time step ttot
        +  pm_dt(ttot)/2 
         * p36_omegEs(regi,"2",teEs)
         * v36_deltaProdEs(ttot,regi,enty,esty,teEs)
   ;
q36_vintage_obj..
   v36_vintage_obj
   =e=
   sum((ttot,regi,fe2ces_dyn36(enty,esty,teEs,in))$(
                                t0(ttot)
                                ),
                 sum(opTimeYr2teEs(teEs,opTimeYr)$(
                                          tsu2opTimeYr(ttot,opTimeYr)
                                          ),
                     power ( 
                     v36_deltaProdEs(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)),regi,enty,esty,teEs)
                     - v36_deltaProdEs(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,enty,esty,teEs)
                     ,2
                     )
                 )
       )          
   ;


*** EOF ./modules/36_buildings/services_putty/equations.gms
