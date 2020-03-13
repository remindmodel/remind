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
* BS 2020-03-12 eta = 1 equation to account for inequality
* TO DO: also include analytic result for eta != 1
* first test with parameter -> expect no effect
*                       + (log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi)) - pm_ineqTheil(ttot,regi))$(pm_ies(regi) eq 1)
* now with coupling to mitigation costs
                        + ( log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi))
                              - 0.5*v02_distrNew_sigma2(ttot,regi)**2 )$(pm_ies(regi) eq 1)
                    )
                )
$if %cm_INCONV_PENALTY% == "on"  - v02_inconvPen(ttot,regi) - v02_inconvPenCoalSolids(ttot,regi)
            )
        )
;


*BS 2020-03-12: internalization of income distribution effects
* here I distribute the consumption loss according to my lognormal approach

* per capita consumption [$]
q02_consPcap(t,regi)..
    v02_consPcap(t,regi)
  =e=
    vm_cons(t,regi) / pm_pop(t,regi) * 1e3
;

* relative consumption loss
q02_relConsLoss(t,regi)..
    v02_relConsLoss(t,regi)
  =e=
    (p02_cons_ref(t,regi)-vm_cons(t,regi))/p02_cons_ref(t,regi)
;

* normalization of cost distribution
q02_distrNormalization(t,regi)..
    v02_distrNormalization(t,regi)
  =e=
    v02_relConsLoss(t,regi) * p02_consPcap_ref(t,regi)**p02_distrAlpha(t,regi)
      * exp( - p02_distrAlpha(t,regi)*p02_distrMu(t,regi) - p02_distrAlpha(t,regi)**2 * p02_ineqTheil(t,regi))
;

* second moment of distribution after subtraction of costs
q02_distrNew_SecondMom(t,regi)..
    v02_distrNew_SecondMom(t,regi)
  =e=
    exp(2*p02_distrMu(t,regi) + 4*p02_ineqTheil(t,regi))
    - 2*v02_distrNormalization(t,regi)/(p02_consPcap_ref(t,regi)**(p02_distrAlpha(t,regi)-1))
      * exp((p02_distrAlpha(t,regi)+1)*p02_distrMu(t,regi) + (p02_distrAlpha(t,regi)+1)**2 * p02_ineqTheil(t,regi))
    + v02_distrNormalization(t,regi)**2/(p02_consPcap_ref(t,regi)**(2*(p02_distrAlpha(t,regi)-1)))
      * exp(2*p02_distrAlpha(t,regi)*p02_distrMu(t,regi) + 4*p02_distrAlpha(t,regi)**2 * p02_ineqTheil(t,regi))
;

* moment matching: approximating distribution with new lognormal with changed mu and sigma
* mu
q02_distrNew_mu(t,regi)..
    v02_distrNew_SecondMom(t,regi)
  =e=
    2*log(vm_cons(t,regi)) - 0.5*log(v02_distrNew_SecondMom(t,regi))
;
* sigma^2: this finally enters the welfare function to account for the change in the income distribution
q02_distrNew_sigma2(t,regi)..
    v02_distrNew_sigma2(t,regi)
  =e=
    log(v02_distrNew_SecondMom(t,regi)) - 2*log(vm_cons(t,regi))
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
