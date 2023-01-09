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
                        ((((vm_cons(ttot,regi)*exp(-0.5*(1/pm_ies(regi))*v02_distrFinal_sigmaSq_welfare(ttot,regi)))/pm_pop(ttot,regi))**(1-1/pm_ies(regi))-1)/(1-1/pm_ies(regi)) )$(pm_ies(regi) ne 1)
                        


                        + ( log((vm_cons(ttot,regi)) / pm_pop(ttot,regi))
                              - 0.5*v02_distrFinal_sigmaSq_welfare(ttot,regi) )$(pm_ies(regi) eq 1)
                    )
                )
$if %cm_INCONV_PENALTY% == "on"  - v02_inconvPen(ttot,regi) - v02_inconvPenCoalSolids(ttot,regi)
$if "%cm_INCONV_PENALTY_FESwitch%" == "on"  - sum((entySe,entyFe,te,sector,emiMkt)$(se2fe(entySe,entyFe,te) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) AND (entySeBio(entySe) OR entySeSyn(entySe) OR entySeFos(entySe)) ), v02_NegInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt) + v02_PosInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt))/1e3	
            )
        )
;

***---------------------------------------------------------------------------
*' Defining variables which are useful for the inequality module:
*' 1/ Energy Expenditures
*' 2/ Revenues from taxes
***---------------------------------------------------------------------------

*NT* uses max(2015,cm_startyear) because energy expenditure not working before 2015 in the baseline scenario b/c prices not defined before(?)
q02_energyExp(ttot,regi)$(ttot.val ge max(2015,cm_startyear))..
    v02_energyExp(ttot,regi)
    =e=
    sum(se2fe(entySe,entyFe,te),
        sum((sector2emiMkt(sector,emiMkt),entyFE2sector(entyFE,sector)),
        vm_demFeSector(ttot,regi,entySe,entyFe,sector,emiMkt)*pm_FEPrice(ttot,regi,entyFe,sector,emiMkt))
        )
;

*NT* 2/ Emissions which will generate revenues, following the way emissions are summed in q_emiAllMkt while only retaining specific sources (see documentation)
*ML* In the future: try to remove non-energy emissions from FF and industry?
q02_emitaxredistr(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_emitaxredistr(ttot,regi)
    =e=
* Summing on all markets energy emissions as well as CDR emissions.
    sum(emiMkt, 
    vm_emiTeMkt(ttot,regi,"co2",emiMkt)+vm_emiCdr(ttot,regi,"co2")$(sameas(emiMkt,"ETS"))
    + sm_tgn_2_pgc   * (vm_emiTeMkt (ttot,regi,"n2o",emiMkt)+vm_emiCdr(ttot,regi,"n2o")$(sameas(emiMkt,"ETS")))
    + sm_tgch4_2_pgc * (vm_emiTeMkt (ttot,regi,"ch4",emiMkt)+vm_emiCdr(ttot,regi,"ch4")$(sameas(emiMkt,"ETS")))
   )
* Plus all non-energy emissions sources coming from FF and industrial processes:
   	+ vm_emiMacSector(ttot,regi,"co2cement_process")
    + sm_tgch4_2_pgc*(vm_emiMacSector(ttot,regi,"ch4coal")+vm_emiMacSector(ttot,regi,"ch4gas")+vm_emiMacSector(ttot,regi,"ch4oil"))
    + sm_tgn_2_pgc*(vm_emiMacSector(ttot,regi,"n2otrans")+vm_emiMacSector(ttot,regi,"n2oadac")+vm_emiMacSector(ttot,regi,"n2onitac"))
;

***---------------------------------------------------------------------------
*' Variables affecting inequalities:
*' 1/ Additional energy expenditures,
*' 2/ Additional revenues from the carbon tax
***---------------------------------------------------------------------------

* This equation defines additional energy expenditure compared to baseline
* 
q02_energyExp_Add(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_energyExp_Add(ttot,regi)
  =e=
* Preferred expression using energy expenditures (defined in the core)
* It is worth 0 in the baseline (cm_emiscen=1)
    (v02_energyExp(ttot,regi)-p02_energyExp_ref(ttot,regi))$(cm_emiscen ne 1)

* Another expression (if we wanted to use energy system costs)
* In that case adjust also the expression for p02_energyExp_ref in datainput
*    (vm_costEnergySys(ttot,regi)-p02_energyExp_ref(ttot,regi))$(cm_emiscen ne 1)
;

* This equation the ratio of additional energy expenditures over consumption
q02_energyexpShare(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_energyexpShare(ttot,regi)
  =e=
* simply divided by conso
    v02_energyExp_Add(ttot,regi)/(vm_cons(ttot,regi))
* divided by adjusted conso
*    (v02_energyExp_Add(ttot,regi))/(vm_cons(ttot,regi)+v02_energyExp_Add(ttot,regi)-v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0))

;

* Similarly to energy expenditure, we define the additional revenues compared to the baseline
q02_taxrev_Add(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_taxrev_Add(ttot,regi)
  =e=
    ((pm_taxCO2eq(ttot,regi)+ pm_taxCO2eqSCC(ttot,regi)+pm_taxCO2eqHist(ttot,regi))*v02_emitaxredistr(ttot,regi)
    -p02_taxrev_redistr0_ref(ttot,regi))$(cm_emiscen ne 1)
;

* We use the ratio over consumption
* In addition, we suppose that this is worth 0 in case revenues are negative (subsidies to negative emission technologies)
q02_relTaxlevels(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_revShare(ttot,regi)
  =e=
* Simply divided by conso
    v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0)/vm_cons(ttot,regi)

* Divided by adjusted conso
*    (v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0))/(vm_cons(ttot,regi)+v02_energyExp_Add(ttot,regi)-v02_taxrev_Add(ttot,regi)$(v02_taxrev_Add.l(ttot,regi) ge 0))

;

* output damages calculated in the damage module are translated into consumption losses via an exogenous factor
q02_consLossShare(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_damageConsShare(ttot,regi)
  =e=
    1/(p02_damConsFactor1(ttot,regi)+vm_damageFactor(ttot,regi)*p02_damConsFactor2(ttot,regi))-1
;

* Alpha, the elasticity of energy expenditure, depends upon the region's GDP
* We use the functional form and calibration from Soergel et al. 2021    
q02_distrAlpha(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_distrAlpha(ttot,regi)
    =e=
    1+1.618788-2*0.09746092*log(1000*vm_cesIO(ttot,regi,"inco")/pm_pop(ttot,regi))
* Note that the above equation defines alpha as a parameter depending upon GDP, which could potentially bring a complex feedback (rich countries moderating GDP growth to reduce the regressivity of energy expenditures).
* For tests, I also used previously consumption in the baseline instead of actual GDP in the current scenario, so that alpha is a parameter
*    1+1.618788-2*0.09746092*log(1000*p02_cons_ref(ttot,regi)/pm_pop(ttot,regi))
;


***---------------------------------------------------------------------------
*' Defining sigma
***---------------------------------------------------------------------------

* Equation defining sigma:
*q02_distrFinal_sigmaSq(ttot,regi)..
q02_distrFinal_sigmaSq(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_distrFinal_sigmaSq(ttot,regi)
  =e=

* Solution 1: This is the complex equation 
*    log( exp(2*p02_ineqTheil(ttot,regi))
*      - 2* v02_energyexpShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*v02_distrAlpha(ttot,regi))
*      + 2* v02_revShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*p02_distrBeta(ttot,regi))
*      + power(v02_energyexpShare(ttot,regi),2)* exp(2*p02_ineqTheil(ttot,regi)*power(v02_distrAlpha(ttot,regi),2))
*      + power(v02_revShare(ttot,regi),2)*exp(2*p02_ineqTheil(ttot,regi)*power(p02_distrBeta(ttot,regi),2))
*      - 2* v02_energyexpShare(ttot,regi)*v02_revShare(ttot,regi)*exp(2*p02_ineqTheil(ttot,regi)*v02_distrAlpha(ttot,regi)*p02_distrBeta(ttot,regi)))
*    -2*log(1-v02_energyexpShare(ttot,regi)+v02_revShare(ttot,regi))
    
      
* Solution 2: The simple equation
    2*p02_ineqTheil(ttot,regi)*power((1+p02_distrBeta(ttot,regi)*v02_revShare(ttot,regi)-v02_distrAlpha(ttot,regi)*v02_energyexpShare(ttot,regi))/(1+v02_revShare(ttot,regi)-v02_energyexpShare(ttot,regi)),2)

;

***-- including damage effects in sigma ---
q02_distrFinal_sigmaSq_postDam(ttot,regi)$(ttot.val ge cm_startyear)..
   v02_distrFinal_sigmaSq_postDam(ttot,regi)
 =e=
    2*p02_ineqTheil(ttot,regi)*power((1+p02_distrBeta(ttot,regi)*v02_revShare(ttot,regi)-v02_distrAlpha(ttot,regi)*v02_energyexpShare(ttot,regi)-cm_distrAlphaDam*v02_damageConsShare(ttot,regi))/(1+v02_revShare(ttot,regi)-v02_energyexpShare(ttot,regi)-v02_damageConsShare(ttot,regi)),2)
;

***---------------------------------------------------------------------------
*' Defining a boundary to prevent welfare-enhancing effects
***---------------------------------------------------------------------------

* I define sigma_limit as a limit past which increases in inequality do not bring further welfare benefits

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



* I define sigmaSq_welfare as the maximum of sigmaSq and sigmaSq_limit
* To do that I use a smooth approximation of the welfare function
* FP: adjust to use the post damage Sigma
*q02_distrFinal_sigmaSq_welfare(ttot,regi)$(ttot.val ge 2015)..
q02_distrFinal_sigmaSq_welfare(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_distrFinal_sigmaSq_welfare(ttot,regi)
        =e=
    0.5*(v02_distrFinal_sigmaSq_postDam(ttot,regi)+v02_distrFinal_sigmaSq_limit(ttot,regi)+sqrt(power(v02_distrFinal_sigmaSq_postDam(ttot,regi)-v02_distrFinal_sigmaSq_limit(ttot,regi),2)+0.00001))
*    0.5*(v02_distrFinal_sigmaSq(ttot,regi)+v02_distrFinal_sigmaSq_limit(ttot,regi)+sqrt(power(v02_distrFinal_sigmaSq(ttot,regi)-v02_distrFinal_sigmaSq_limit(ttot,regi),2)+0.00001))

* test: sigma welfare equal to the level in the baseline...
*    2*p02_ineqTheil(ttot,regi)

* another test: sigma welfare always equal to sigma (no limit)
*    v02_distrFinal_sigmaSq(ttot,regi)      
;
    


***---------------------------------------------------------------------------
*' Adding other boundaries to prevent model from failing
***---------------------------------------------------------------------------

* For tests (maybe not needed anymore)

* To make sure the energy expenditure share stays within reasonable boundaries, I defined the following inequality:
q02_energyexpShare_cap(ttot,regi)$(ttot.val ge cm_startyear)..
    v02_energyexpShare(ttot,regi)
     =l=
    0.5
;

* To prevent the "complex" equation defining sigma to fail, one can use inequalities to make sure what is within the log is positive

q02_budget_first(ttot,regi)$(ttot.val ge cm_startyear)..
* Note that v02_budget_first is defined as a positive variable
*    v02_budget_first(ttot,regi)
*     =e=
*      exp(2*p02_ineqTheil(ttot,regi))
*      - 2* v02_energyexpShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*v02_distrAlpha(ttot,regi))
*      + 2* v02_revShare(ttot,regi) * exp(2*p02_ineqTheil(ttot,regi)*p02_distrBeta(ttot,regi))
*      + power(v02_energyexpShare(ttot,regi),2)* exp(2*p02_ineqTheil(ttot,regi)*power(v02_distrAlpha(ttot,regi),2))
*      + power(v02_revShare(ttot,regi),2)*exp(2*p02_ineqTheil(ttot,regi)*power(p02_distrBeta(ttot,regi),2))
*      - 2* v02_energyexpShare(ttot,regi)*v02_revShare(ttot,regi)*exp(2*p02_ineqTheil(ttot,regi)*v02_distrAlpha(ttot,regi)*p02_distrBeta(ttot,regi))
* minus a epsilon to make sure
*      -0.0001

* At the moment I removed this so use use instead
    0
    =l=
    1

;

* Similar equation for the other expression within the log
*q02_budget_second(ttot,regi)..
q02_budget_second(ttot,regi)$(ttot.val ge cm_startyear)..
*    v02_budget_second(ttot,regi)
*     =e=
    0
    =l=
    (1+v02_revShare(ttot,regi)-v02_energyexpShare(ttot,regi)-0.05)
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

*** small inconvenience penalty for increasing/decreasing biomass/synfuel use between two time steps in buildings and industry and emissison markets
*** necessary to avoid switching behavior in sectors and emissions markets between time steps as those sectors and markets do not have se2fe capcities
$IFTHEN.INCONV_bioSwitch "%cm_INCONV_PENALTY_FESwitch%" == "on"
q02_inconvPenFeBioSwitch(ttot,regi,entySe,entyFe,te,sector,emiMkt)$((ttot.val ge cm_startyear) 
                                                            AND se2fe(entySe,entyFe,te) 
                                                            AND entyFe2Sector(entyFe,sector) 
                                                            AND sector2emiMkt(sector,emiMkt) 
                                                            AND (entySeBio(entySe) OR entySeSyn(entySe) OR entySeFos(entySe)) )..
                                                              vm_demFeSector(ttot,regi,entySe,entyFe,sector,emiMkt) 
                                                              - vm_demFeSector(ttot-1,regi,entySe,entyFe,sector,emiMkt)
                                                              + v02_NegInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt)
                                                              - v02_PosInconvPenFeBioSwitch(ttot,regi,entySe,entyFe,sector,emiMkt)
                                                            =e=
                                                            0
;
$ENDIF.INCONV_bioSwitch
*** EOF ./modules/02_welfare/ineqLognormal/equations.gms
