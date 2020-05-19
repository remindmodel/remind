*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_putty/equations.gms

***  Buildings Final Energy Balance
q36_demFeBuild(ttot,regi,entyFe,emiMkt)$((ttot.val ge cm_startyear) AND (entyFe2Sector(entyFe,"build")) AND (sameas(emiMkt,"ES"))) .. 
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(ttot,regi,entySe,entyFe,"build",emiMkt)) 
  =e=
  sum(fe2ppfEn36(entyFe,in),
    vm_cesIO(ttot,regi,in)
    + pm_cesdata(ttot,regi,in,"offset_quantity")
  )
  +
  sum(fe2es_dyn36(entyFe,esty,teEs), vm_demFeForEs(ttot,regi,entyFe,esty,teEs) ) 
;


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


q36_enerCoolAdj(ttot,regi,in)$(sameas (in, "fescelb") AND ttot.val ge max(2015, cm_startyear)).. 
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

*** EOF ./modules/36_buildings/services_putty/equations.gms
