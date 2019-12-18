*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/utilitarian/equations.gms

***---------------------------------------------------------------------------
*' The objective of the optimization is to maximize the total discounted intertemporal utility.
*' It is summed over all regions. 
***---------------------------------------------------------------------------
q02_welfareGlob..
    vm_welfareGlob
  =e=
    sum(regi, pm_w(regi)*v02_welfare(regi) )
;

***---------------------------------------------------------------------------
*' Total discounted intertemporal regional welfare calculated from per capita consumption 
*' summing over all time steps taking into account the pure time preference rate.
*' Assuming an intertemporal elasticity of substitution of 1, it holds:
***---------------------------------------------------------------------------
q02_welfare(regi)..
    v02_welfare(regi) 
  =e=
    sum(ttot $(ttot.val ge 2005),
        pm_welf(ttot) * pm_ts(ttot) * (1 / ( (1 + pm_prtp(regi))**(pm_ttot_val(ttot)-2005) ) )
        *   (  (pm_pop(ttot,regi) 
                *   (
                        ((( (vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot)))/pm_pop(ttot,regi))**(1-1/pm_ies(regi))-1)/(1-1/pm_ies(regi)) )$(pm_ies(regi) ne 1)
                       + (log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi)))$(pm_ies(regi) eq 1)
                    )
                )
$if %cm_INCONV_PENALTY% == "on"  - v02_inconvPen(ttot,regi) - v02_inconvPenCoalSolids(ttot,regi)
            )
        )
;

***---------------------------------------------------------------------------
*' Calculation of the inconvenience penalty:
***---------------------------------------------------------------------------
$IFTHEN.INCONV %cm_INCONV_PENALTY% == "on"
q02_inconvPen(t,regi)$(t.val > 2005)..
    v02_inconvPen(t,regi)
  =g=
*' local air pollution for all entySe production except for coal solids (=sesofos), which is treated separately (see below)
    SUM(pe2se(enty,entySe,te)$(NOT sameas(entySe,"sesofos")),
        p02_inconvpen_lap(t,regi,te) * (vm_prodSe(t,regi,enty,entySe,te))
    )
;

q02_inconvPenCoalSolids(t,regi)$(t.val > 2005)..
    v02_inconvPenCoalSolids(t,regi)
  =g=
*' local air pollution for coal: inconvinienve penalty applies only for buildings use; slack variable ensures that v02_inconvPen can stay > 0 
    p02_inconvpen_lap(t,regi,"coaltr") * (vm_prodSe(t,regi,"pecoal","sesofos","coaltr") 
  - vm_cesIO(t,regi,"fesoi"))
  + v02_sesoInconvPenSlack(t,regi)
;
$ENDIF.INCONV

*** EOF ./modules/02_welfare/utilitarian/equations.gms