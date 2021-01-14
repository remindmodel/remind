*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/spillover/equations.gms
*MLB* revised version of Innovation and Immitation equations
q20_effGr(ttot+1,regi,inRD20(in))$(pm_ttot_val(ttot+1) ge max(2010, cm_startyear))..
            vm_effGr(ttot+1,regi,inRD20) =e=
        (1 + (p20_coef_H(ttot,regi) * p20_coef_EL(inRD20)
            *(v20_effInno(ttot,regi,inRD20) + v20_effImi(ttot,regi,inRD20))*vm_invMacro(ttot,regi,"kap")/(vm_cesIO(ttot+1,regi,"kap")+0.00001)))**(pm_ts(ttot)/5)
                               *vm_effGr(ttot,regi,inRD20) 
;

q20_effInno(ttot,regi,inRD20) $((ord(ttot) lt card(ttot)) and (ttot.val ge cm_startyear))..
      v20_effInno(ttot,regi,inRD20) =e= 
           p20_coeffInno  * ((vm_invInno(ttot,regi,inRD20)) /(pm_cesdata(t,regi,inRD20,"eff") * vm_effGr(ttot,regi,inRD20) + 0.00001))**p20_exponInno(ttot,regi,inRD20) + p20_constRD;


q20_effImi(ttot,regi,inRD20) $(ttot.val ge cm_startyear)..
      v20_effImi(ttot,regi,inRD20) =e= 
                 p20_coeffImi * ((vm_invImi(ttot,regi,inRD20))/(pm_cesdata(t,regi,inRD20,"eff") * vm_effGr(ttot,regi,inRD20) + 0.00001))**p20_exponImi(ttot,regi,inRD20) *
                  (sum( regi2, (pm_cesdata(t,regi2,inRD20,"eff") * vm_effGr(ttot,regi2,inRD20))) + pm_cumEff(ttot,regi, inRD20))/ (pm_cesdata(t,regi,inRD20,"eff") * vm_effGr(ttot,regi,inRD20) + 0.0001);


*** EOF ./modules/20_growth/spillover/equations.gms
