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
                        ((( (vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot)))/pm_pop(ttot,regi))**(1-1/pm_ies(regi))-1)/(1-1/pm_ies(regi)) )$(pm_ies(regi) ne 1)
* BS 2020-03-12 eta = 1 equation to account for inequality
* TO DO: also include analytic result for eta != 1
* first test with parameter -> expect no effect
*                       + (log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi)) - pm_ineqTheil(ttot,regi))$(pm_ies(regi) eq 1)
* now with coupling to mitigation costs
*                        + ( log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi))
*                              - 0.5*v02_distrNew_sigmaSq(ttot,regi) )$(pm_ies(regi) eq 1)
* TN: use the final instead of the New distribution
* TN: one zero
                        + ( log((vm_cons(ttot,regi)*(1-cm_damage*vm_forcOs(ttot)*vm_forcOs(ttot))) / pm_pop(ttot,regi))
                              - 0.5*v02_distrFinal_sigmaSq(ttot,regi) )$(pm_ies(regi) eq 1)
                    )
                )
$if %cm_INCONV_PENALTY% == "on"  - v02_inconvPen(ttot,regi) - v02_inconvPenCoalSolids(ttot,regi)
            )
        )
;


*BS 2020-03-12: internalization of income distribution effects
* here I distribute the consumption loss according to my lognormal approach

*BS 2020-03-25 analytical simplification greatly reduces the number of additional equations and variables

* per capita consumption [1000 $]
* not needed any more, simplified equations are completely independent of the per capita values
* q02_consPcap(ttot,regi)$(ttot.val ge 2005)..
*    v02_consPcap(ttot,regi)
*  =e=
*    vm_cons(ttot,regi) / pm_pop(ttot,regi)
*;

* Energy expenditure
* New way of doing it: using the CES data. see datainput.
* I am following the way things are aggregated in the balance of FE equation (qm_balFe)
* Instead of just vm_demFeSector (quantity), I multiply it by the corresponding price to get expenditures
*q02_EnergyExp_enty(t,regi,entySe,entyFe,te)$se2fe(entySe,entyFe,te)..
*     v02_EnergyExp_enty(t,regi,entySe,entyFe,te)
*  =e=
*     sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),
*     vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)*pm_FEPrice(t,regi,entyFe,sector,emiMkt))
*;

* sum over all combinations of enSe entyFe and te to get the regional total. 
*q02_EnergyExp(t,regi)..
*      v02_EnergyExp(t,regi)
*  =e=
*      sum(en2en(entySe,entyFe,te),
*      v02_EnergyExp_enty(t,regi,entySe,entyFe,te))
*;

* other way to compute energy expenditures is to use the CES function
*q02_EnergyExp_Add(ttot,regi)..
*     p02_EnergyExp_Add(ttot,regi)
*  =e=
*     pm_cesdata(ttot,regi,"en","price")*pm_cesdata(ttot,regi,"en","quantity")-p02_cesdata_ref(ttot,regi,"en","price")*p02_cesdata_ref(ttot,regi,"en","quantity")
*;     

* relative consumption loss
q02_energyexpShare(ttot,regi)$(ttot.val ge 2005)..
    v02_energyexpShare(ttot,regi)
  =e=
   (p02_EnergyExp_Add(ttot,regi)/(vm_cons(ttot,regi)+p02_EnergyExp_Add(ttot,regi)-p21_taxrev_redistr0(ttot,regi)))
*    ((p02_cons_ref(ttot,regi)-vm_cons(ttot,regi))/p02_cons_ref(ttot,regi))
* Computing rather additional energy expenditure as a share of consumption:
*    p02_EnergyExp_Add(ttot,regi)/p02_cons_ref(ttot,regi)
;

* TN: Equations to calculate actual tax revenues
* summing on all GHG the energy emissions as well as CDR emissions.
q02_emiEnergyco2eqMkt(ttot,regi,emiMkt)..
    v02_emiEnergyco2eqMkt(ttot,regi,emiMkt)
  =e=
    vm_emiTeMkt(ttot,regi,"co2",emiMkt)+vm_emiCdr(ttot,regi,"co2")$(sameas(emiMkt,"ETS"))
    + sm_tgn_2_pgc   * (vm_emiTeMkt (ttot,regi,"n2o",emiMkt)+vm_emiCdr(ttot,regi,"n2o")$(sameas(emiMkt,"ETS")))
    + sm_tgch4_2_pgc * (vm_emiTeMkt (ttot,regi,"ch4",emiMkt)+vm_emiCdr(ttot,regi,"ch4")$(sameas(emiMkt,"ETS")))
;      

* summing on all Mkt to get the total:
q02_emiEnergyco2eq(ttot,regi)..
    v02_emiEnergyco2eq(ttot,regi)
    =e=
    sum(emiMkt, v02_emiEnergyco2eqMkt(ttot,regi,emiMkt))
;


* Summing all the non-energy emissions sources coming from FF and industrial processes
q02_emiIndus(t,regi)..
    v02_emiIndus(t,regi)
    =e=
    vm_emiMacSector(t,regi,"co2cement_process")
    + sm_tgch4_2_pgc*(vm_emiMacSector(t,regi,"ch4coal")+vm_emiMacSector(t,regi,"ch4gas")+vm_emiMacSector(t,regi,"ch4oil"))
    + sm_tgn_2_pgc*(vm_emiMacSector(t,regi,"n2otrans")+vm_emiMacSector(t,regi,"n2oadac")+vm_emiMacSector(t,regi,"n2onitac"))
;

* TN relative tax revenues 
* expression for the tax levels borrowed from q21_taxrevGHG
* Note that for now, it's 'GHG tax revenues'
* Also make sure that this is a positive value.
* Later think about how to treat negative emissions.

q02_relTaxlevels(ttot,regi)$(ttot.val ge 2005)..
    v02_revShare(ttot,regi)
  =e=
    p21_taxrev_redistr0(ttot,regi)/(vm_cons(ttot,regi)+p02_EnergyExp_Add(ttot,regi)-p21_taxrev_redistr0(ttot,regi))
*    0+(p21_taxrevGHG0(ttot,regi)/vm_cons(ttot,regi))$(p21_taxrevGHG0(ttot,regi) ge 0)
*    0+((v02_emiIndus(ttot,regi)+v02_emiEnergyco2eq(ttot,regi))*(pm_taxCO2eq(ttot,regi)+ pm_taxCO2eqSCC(ttot,regi)+pm_taxCO2eqHist(ttot,regi))/vm_cons(ttot,regi))$((v02_emiIndus.l(ttot,regi)+v02_emiEnergyco2eq.l(ttot,regi)) ge 0)
;


* normalization of cost distribution
* with the simplified equations this can be removed
*q02_distrNormalization(ttot,regi)$(ttot.val ge 2005)..
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
*q02_distrNew_SecondMom(ttot,regi)$(ttot.val ge 2005)..
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
;


* TN: one-step approximation
q02_distrFinal_sigmaSq(ttot,regi)$(ttot.val ge 2005)..
    v02_distrFinal_sigmaSq(ttot,regi)
  =e=
* simplified equation
  log( exp(2*p02_ineqTheil(ttot,regi))
      - 2* v02_energyexpShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*p02_distrAlpha(ttot,regi))
      + 2* v02_revShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*p02_distrBeta(ttot,regi))
      + power(v02_energyexpShare(ttot,regi),2)* exp(2*p02_ineqTheil(ttot,regi)*power(p02_distrAlpha(ttot,regi),2))
      + power(v02_revShare(ttot,regi),2)*exp(2*p02_ineqTheil(ttot,regi)*power(p02_distrBeta(ttot,regi),2))
      - 2* v02_energyexpShare(ttot,regi)*v02_revShare(ttot,regi)*exp(2*p02_ineqTheil(ttot,regi)*p02_distrAlpha(ttot,regi)*p02_distrBeta(ttot,regi)))
      -2*log(1-v02_energyexpShare(ttot,regi)+v02_revShare(ttot,regi))
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
