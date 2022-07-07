*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/ineqLognormal/equations.gms

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
                        ((((vm_cons(ttot,regi)*exp(-0.5*(1/pm_ies(regi))*v02_distrFinal_sigmaSq_welfare(ttot,regi))*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot)))/pm_pop(ttot,regi))**(1-1/pm_ies(regi))-1)/(1-1/pm_ies(regi)) )$(pm_ies(regi) ne 1)



* NT: in the general case welfare = population * u(c_eq)
* with c_eq=c exp(-0.5 eta sigma^2)

* BS2020-03-12 eta = 1 equation to account for inequality
* TO DO: also include analytic result for eta != 1
* first test with parameter -> expect no effect
*                       + (log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi)) - pm_ineqTheil(ttot,regi))$(pm_ies(regi) eq 1)
* now with coupling to mitigation costs
*                        + ( log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi))
*                              - 0.5*v02_distrNew_sigmaSq(ttot,regi) )$(pm_ies(regi) eq 1)
* TN: use the final instead of the New distribution
* TN: one zero
                        + ( log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi))
                              - 0.5*v02_distrFinal_sigmaSq_welfare(ttot,regi) )$(pm_ies(regi) eq 1)
                    )
                )
$if %cm_INCONV_PENALTY% == "on"  - v02_inconvPen(ttot,regi) - v02_inconvPenCoalSolids(ttot,regi)
            )
        )
;

*q02_EnergyExp_Add(ttot,regi)..
q02_EnergyExp_Add(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_EnergyExp_Add(ttot,regi)
  =e=
* Classical difference
    (vm_EnergyExp(ttot,regi)-p02_EnergyExp_ref(ttot,regi))$(cm_emiscen ne 1)

* With the consumption
*    (vm_cons(ttot,regi)-p02_cons_ref(ttot,regi))$(cm_emiscen ne 1)
* Another thing: Q(p-p0) with p the average price of FE.
*    (vm_EnergyExp(ttot,regi)-sum(se2fe(entySe,entyFe,te),vm_prodFe(ttot,regi,entySe,entyFe,te))/sum(se2fe(entySe,entyFe,te),p02_prodFe_ref(ttot,regi,entySe,entyFe,te)) *p02_EnergyExp_ref(ttot,regi))$(cm_emiscen ne 1)

* energy system costs
*    (vm_costEnergySys(ttot,regi)-p02_EnergyExp_ref(ttot,regi))$(cm_emiscen ne 1)
;

* relative consumption loss
*q02_energyexpShare(ttot,regi)..
q02_energyexpShare(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_energyexpShare(ttot,regi)
  =e=
*    v02_EnergyExp_Add(ttot,regi)/(vm_cons(ttot,regi)+vm_EnergyExp(ttot,regi))
* simply divided by conso
    v02_EnergyExp_Add(ttot,regi)/(vm_cons(ttot,regi))
* divided by adjusted conso
*    (v02_EnergyExp_Add(ttot,regi))/(vm_cons(ttot,regi)+v02_EnergyExp_Add(ttot,regi)-v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0))

* Other
*    (p02_EnergyExp_Add(ttot,regi))/(vm_cons(ttot,regi))
*    v02_EnergyExp_Add(ttot,regi)/(p02_cons_ref(ttot,regi)+v02_EnergyExp_Add(ttot,regi)-v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0))
;


* TN relative tax revenues 
* expression for the tax levels borrowed from q21_taxrevGHG
* Note that for now, it's 'GHG tax revenues'
* Also make sure that this is a positive value.
* Later think about how to treat negative emissions.

*q02_relTaxlevels(ttot,regi)..
q02_relTaxlevels(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_revShare(ttot,regi)
  =e=
* Divided by adjusted conso
*    (v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0))/(vm_cons(ttot,regi)+v02_EnergyExp_Add(ttot,regi)-v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0))
* Simply divided by conso
    v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0)/vm_cons(ttot,regi)
;


*q02_taxrev_Add(ttot,regi)..
q02_taxrev_Add(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_taxrev_Add(ttot,regi)
  =e=
    ((pm_taxCO2eq(ttot,regi)+ pm_taxCO2eqSCC(ttot,regi)+pm_taxCO2eqHist(ttot,regi))*vm_emitaxredistr(ttot,regi)
    -p02_taxrev_redistr0_ref(ttot,regi))$(cm_emiscen ne 1)
;

*q02_distrAlpha(ttot,regi)..
q02_distrAlpha(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_distrAlpha(ttot,regi)
    =e=
    1+1.618788-2*0.09746092*log(1000*vm_cesIO(ttot,regi,"inco")/pm_pop(ttot,regi))
*    1+1.618788-2*0.09746092*log(1000*p02_cons_ref(ttot,regi)/pm_pop(ttot,regi))
;

* normalization of cost distribution
* with the simplified equations this can be removed
*q02_distrNormalization(ttot,regi)$(t.val ge 2005)..
*    v02_distrNormalization(ttot,regi)
*  =e=
* simplified equation
*  v02_relConsLoss(ttot,regi) * exp( (p02_distrAlpha(ttot,regi) - p02_distrAlpha(ttot,regi)**2) * p02_ineqTheil(ttot,regi) )
* original equation
*    v02_relConsLoss(ttot,regi) * p02_consPcap_ref(ttot,regi)**p02_distrAlpha(ttot,regi)
*      * exp( - p02_distrAlpha(ttot,regi)*p02_distrMu(ttot,regi) - p02_distrAlpha(ttot,regi)**2 * p02_ineqTheil(ttot,regi))
*;

* second moment of distribution after subtraction of costs
* this is now redundant as well
*q02_distrNew_SecondMom(ttot,regi)$(t.val ge 2005)..
*    v02_distrNew_SecondMom(ttot,regi)
*  =e=
* simplified equations
*    p02_consPcap_ref(ttot,regi)**2 * (
*      exp(2*p02_ineqTheil(ttot,regi))
*      - 2* v02_relConsLoss(ttot,regi) * exp( 2*p02_distrAlpha(ttot,regi)*p02_ineqTheil(ttot,regi) )
*      + v02_relConsLoss(ttot,regi)**2 * exp( 2*p02_distrAlpha(ttot,regi)**2 * p02_ineqTheil(ttot,regi) )
*    )
* orignal equation
*    exp(2*p02_distrMu(ttot,regi) + 4*p02_ineqTheil(ttot,regi))
*    - 2*v02_distrNormalization(ttot,regi)/(p02_consPcap_ref(ttot,regi)**(p02_distrAlpha(ttot,regi)-1))
*      * exp((p02_distrAlpha(ttot,regi)+1)*p02_distrMu(ttot,regi) + (p02_distrAlpha(ttot,regi)+1)**2 * p02_ineqTheil(ttot,regi))
*    + power(v02_distrNormalization(ttot,regi),2)/(p02_consPcap_ref(ttot,regi)**(2*(p02_distrAlpha(ttot,regi)-1)))
*      * exp(2*p02_distrAlpha(ttot,regi)*p02_distrMu(ttot,regi) + 4*p02_distrAlpha(ttot,regi)**2 * p02_ineqTheil(ttot,regi))
*;

* moment matching: approximating distribution with new lognormal with changed mu and sigma
* mu (currently unused, could remove this)
*q02_distrNew_mu(ttot,regi)$(ttot.val ge 2005)..
*    v02_distrNew_mu(ttot,regi)
*  =e=
*    2*log(v02_consPcap(ttot,regi)) - 0.5*log(v02_distrNew_SecondMom(ttot,regi))
*;
* sigma^2: this finally enters the welfare function to account for the change in the income distribution
* with the simplified equation everything enters directly here
*q02_distrNew_sigmaSq(ttot,regi)$(ttot.val ge 2005)..
*    v02_distrNew_sigmaSq(ttot,regi)
*  =e=
* simplified equation
*  log( exp(2*p02_ineqTheil(ttot,regi))
*      - 2* p02_relConsLoss(ttot,regi) * exp( 2*p02_distrAlpha(ttot,regi)*p02_ineqTheil(ttot,regi) )
*      + power(p02_relConsLoss(ttot,regi),2) * exp( 2*power(p02_distrAlpha(ttot,regi),2) * p02_ineqTheil(ttot,regi) ))
*      + p02_relConsLoss(ttot,regi)**2 * exp( 2*p02_distrAlpha(ttot,regi)**2 * p02_ineqTheil(ttot,regi) ))
*  - 2*log((1-p02_relConsLoss(ttot,regi)))
* original equation
*    log(v02_distrNew_SecondMom(ttot,regi)) - 2*log(v02_consPcap(ttot,regi))
*;

* TN: adding the second step: distributional effects of revenues
*q02_distrFinal_sigmaSq(ttot,regi)$(ttot.val ge 2005)..
*    v02_distrFinal_sigmaSq(ttot,regi)
*  =e=
* simplified equation
*  log( exp(v02_distrNew_sigmaSq(ttot,regi))
*      + 2* v02_revShare(ttot,regi) * (exp(p02_distrBeta(ttot,regi)*v02_distrNew_sigmaSq(ttot,regi))
*      -exp(p02_distrAlpha(ttot,regi)*v02_distrNew_sigmaSq(ttot,regi))
*      -exp(p02_distrAlpha(ttot,regi)*p02_distrBeta(ttot,regi)*v02_distrNew_sigmaSq(ttot,regi)))
*      + power(v02_revShare(ttot,regi),2)*(exp(power(p02_distrAlpha(ttot,regi),2)*v02_distrNew_sigmaSq(ttot,regi))
*      +exp(power(p02_distrBeta(ttot,regi),2)*v02_distrNew_sigmaSq(ttot,regi))))
*      + p02_relConsLoss(ttot,regi)**2 * exp( 2*p02_distrAlpha(ttot,regi)**2 * p02_ineqTheil(ttot,regi) ))
*  - 2*log((1-p02_relConsLoss(ttot,regi)))
* original equation
*    log(v02_distrNew_SecondMom(ttot,regi)) - 2*log(v02_consPcap(ttot,regi))



*q02_energyexpShare_cap(ttot,regi)..
q02_energyexpShare_cap(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_energyexpShare(ttot,regi)
     =l=
    0.5
;


*q02_budget_first(ttot,regi)..
q02_budget_first(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_budget_first(ttot,regi)
     =e=
*    (1+p02_distrBeta(ttot,regi)*v02_revShare(ttot,regi)-v02_distrAlpha(ttot,regi)*v02_energyexpShare(ttot,regi)+0.05)

      exp(2*p02_ineqTheil(ttot,regi))

      - 2* v02_energyexpShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*v02_distrAlpha(ttot,regi))
      + 2* v02_revShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*p02_distrBeta(ttot,regi))
      + power(v02_energyexpShare(ttot,regi),2)* exp(2*p02_ineqTheil(ttot,regi)*power(v02_distrAlpha(ttot,regi),2))
      + power(v02_revShare(ttot,regi),2)*exp(2*p02_ineqTheil(ttot,regi)*power(p02_distrBeta(ttot,regi),2))
      - 2* v02_energyexpShare(ttot,regi)*v02_revShare(ttot,regi)*exp(2*p02_ineqTheil(ttot,regi)*v02_distrAlpha(ttot,regi)*p02_distrBeta(ttot,regi))
      
* minus a epsilon to make sure
      -0.001
;

*q02_budget_second(ttot,regi)..
q02_budget_second(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_budget_second(ttot,regi)
     =e=
    (1+v02_revShare(ttot,regi)-v02_energyexpShare(ttot,regi)-0.05)
;


* TN: one-step approxitmation
*q02_distrFinal_sigmaSq(ttot,regi)..
q02_distrFinal_sigmaSq(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_distrFinal_sigmaSq(ttot,regi)
  =e=
  (log( exp(2*p02_ineqTheil(ttot,regi))

* simplified equation
*       - 2* v02_energyexpShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*p02_distrAlpha(ttot,regi))
*       + power(v02_energyexpShare(ttot,regi),2)* exp(2*p02_ineqTheil(ttot,regi)*power(p02_distrAlpha(ttot,regi),2))
*       )
*  -2*log(1-v02_energyexpShare(ttot,regi))
*real equation
      - 2* v02_energyexpShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*v02_distrAlpha(ttot,regi))
      + 2* v02_revShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*p02_distrBeta(ttot,regi))
      + power(v02_energyexpShare(ttot,regi),2)* exp(2*p02_ineqTheil(ttot,regi)*power(v02_distrAlpha(ttot,regi),2))
      + power(v02_revShare(ttot,regi),2)*exp(2*p02_ineqTheil(ttot,regi)*power(p02_distrBeta(ttot,regi),2))
      - 2* v02_energyexpShare(ttot,regi)*v02_revShare(ttot,regi)*exp(2*p02_ineqTheil(ttot,regi)*v02_distrAlpha(ttot,regi)*p02_distrBeta(ttot,regi)))
      -2*log(1-v02_energyexpShare(ttot,regi)+v02_revShare(ttot,regi)))
*      *(v02_distrFinal_sigmaSq(ttot,regi)-2*p02_ineqTheil(ttot,regi)+sqrt(sqr(v02_distrFinal_sigmaSq(ttot,regi)-2*p02_ineqTheil(ttot,regi))+sqr(0.001)))/2
      
*      +
*      2*p02_ineqTheil(ttot,regi)*(-v02_distrFinal_sigmaSq(ttot,regi)+2*p02_ineqTheil(ttot,regi)+sqrt(sqr(-v02_distrFinal_sigmaSq(ttot,regi)+2*p02_ineqTheil(ttot,regi))+sqr(0.001)))/2
      
* another, even more simplified equation

*    2*p02_ineqTheil(ttot,regi)*power((1+p02_distrBeta(ttot,regi)*v02_revShare(ttot,regi)-v02_distrAlpha(ttot,regi)*v02_energyexpShare(ttot,regi))/(1+v02_revShare(ttot,regi)-v02_energyexpShare(ttot,regi)),2)

;


q02_distrFinal_sigmaSq_welfare(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_distrFinal_sigmaSq_welfare(ttot,regi)
        =e=
* if there is a limit
* this should be equal to:
* sigma if sigma<sigma_limit
* sigma_limit otherwise
    (v02_distrFinal_sigmaSq(ttot,regi)+v02_distrFinal_sigmaSq_limit(ttot,regi)+sqrt(sqr(v02_distrFinal_sigmaSq(ttot,regi)-v02_distrFinal_sigmaSq_limit(ttot,regi))+0.00001))/2
;
    
* define the limit sigma

q02_distrFinal_sigmaSq_limit(ttot,regi)$(ttot.val ge cm_startyear)..
* solution one_ the limit is such that the bottom 40% should not have more than in the baseline
*    p02_cons_ref(ttot,regi)*(1+errorf((-0.253347-sqrt(p02_ineqTheil(ttot,regi)))/sqrt(2)))
*    =e=
*    vm_cons(ttot,regi)*(1+errorf((-0.253347-0.5*v02_distrFinal_sigmaSq_limit(ttot,regi))/sqrt(2)))
    
* solution two: the limit is the level of inequality in the baseline
    v02_distrFinal_sigmaSq_limit(ttot,regi)
        =e=
    2*p02_ineqTheil(ttot,regi)
;


q02_distrFinal_sigmaSq_limit2(ttot,regi)$(ttot.val ge cm_startyear)..
* solution one_ the limit is such that the bottom 40% should not have more than in the baseline
*    p02_cons_ref(ttot,regi)*(1+errorf((-0.253347-0.5*sqrt(2*p02_ineqTheil(ttot,regi)))/sqrt(2)))
*    =e=
*    vm_cons(ttot,regi)*(1+errorf((-0.253347-0.5*sqrt(v02_distrFinal_sigmaSq_limit2(ttot,regi)))/sqrt(2)))
    p02_cons_ref(ttot,regi)*errorf(-0.253347-0.5*sqrt(2*p02_ineqTheil(ttot,regi)))
    =e=
    vm_cons(ttot,regi)*errorf(-0.253347-0.5*sqrt(v02_distrFinal_sigmaSq_limit2(ttot,regi)))
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

*** EOF ./modules/02_welfare/ineqLognormal/equations.gms
