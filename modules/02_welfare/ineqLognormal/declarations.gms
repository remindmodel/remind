*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/ineqLognormal/declarations.gms

***-------------------------------------------------------------------------------
***                                   PARAMETERS
***-------------------------------------------------------------------------------
parameters
pm_welf(tall)                                     "Weight parameter in the welfare function to avoid jumps with cm_less_TS"
pm_w(all_regi)                                    "Negishi weights"
pm_prtp(all_regi)                                 "Pure rate of time preference"
* BS 2020-03-13 additions for distributional module
p02_cons_ref(ttot,all_regi)                        "consumption in reference run"
p02_consPcap_ref(ttot,all_regi)                    "per capita consumption in reference run"
p02_ineqTheil(ttot,all_regi)		                   "regional Theil-T index = sigma^2/2 for lognormal"
p02_distrMu(ttot,all_regi)                         "mu of lognormal distribution (prior to mitigation costs)"
p02_distrSigma(ttot,all_regi)                      "sigma of lognormal distribution (prior to mitigation costs)"
p02_distrAlpha(ttot,all_regi)                      "income elasticity of mitigation costs"
* TN
p02_distrBeta(ttot,all_regi)                       "income elasticity of revenues redistribution"
*p21_taxrevGHG0_ref(ttot,all_regi)                  "revenue levels in the reference run" 

* p02_distrEVyAlpha(ttot,all_regi)                   "expectation value of income^alpha (used in several places)"
p02_cesdata_ref(ttot,all_regi,all_in,cesParameter)   "parameters of the CES function in the ref scenario"
p02_EnergyExp_Add(ttot,all_regi)                    "regional additional energy expenditure w.r.t. reference run"
p02_relConsLoss(ttot,all_regi)                    "relative consumption loss w.r.t. reference run"


$ifthen.inconv %cm_INCONV_PENALTY% == "on"
p02_inconvpen_lap(ttot,all_regi,all_te)           "Parameter for inconvenience penalty for local air pollution. [T$/TWa at Consumption of 1000$/cap]"
$endif.inconv
;

***-------------------------------------------------------------------------------
***                                   VARIABLES
***-------------------------------------------------------------------------------
variables
v02_welfare(all_regi)                             "Regional welfare"
vm_welfareGlob                                    "Global welfare"
* BS 2020-03-13 additions for distributional module
* v02_consPcap(ttot,all_regi)                       "per capita consumption"
*v02_relConsLoss(ttot,all_regi)                    "relative consumption loss w.r.t. reference run"
* v02_distrNormalization(ttot,all_regi)             "normalization parameter for lognormal distribution of costs"
v02_revShare(ttot,all_regi)                            "tax revenues (share of consumption)"

*TN
v02_emiEnergyco2eq(ttot,all_regi)                      "emissions from energy system + DAC"
v02_emiEnergyco2eqMkt(ttot,all_regi,all_emiMkt)        "emissions from all GHG from energy system for each emiMkt"
v02_emiIndus(ttot,all_regi)                            "emissions from fugitive and industrial processes"

*TN
*v02_EnergyExp_enty(ttot,all_regi,all_enty,all_enty,all_te)   "energy expenditure, disaggregated level"

$ifthen.inconv %cm_INCONV_PENALTY% == "on"
v02_inconvPen(ttot,all_regi)                      "Inconvenience penalty in the welfare function, e.g. for air pollution. Unit: ?Utils?"
v02_inconvPenCoalSolids(ttot,all_regi)            "Inconvenience penalty in the welfare function, e.g. for air pollution. Unit: ?Utils?"
v02_sesoInconvPenSlack(ttot,all_regi)             "Slack to avoid negative inconvenience penalty for Coal Solids"
$endif.inconv
;

positive variables
vm_forcOs(ttot)                                   "Forcing overshoot"
* BS 2020-03-13 additions for distributional module
* v02_distrNew_SecondMom(ttot,all_regi)             "Second moment of distribution after subtracting costs"
* v02_distrNew_mu(ttot,all_regi)                        "mu parameter of lognormal distribution after costs"
v02_distrNew_sigmaSq(ttot,all_regi)                    "sigma^2 parameter of lognormal distribution after costs (but before tax)"
* TN
v02_distrFinal_sigmaSq(ttot,all_regi)                  "sigma^2 parameter of final lognormal distribution (after redistributional effects of taxes)"

;

***-------------------------------------------------------------------------------
***                                   EQUATIONS
***-------------------------------------------------------------------------------
equations
q02_welfareGlob                                   "Global welfare"
q02_welfare                                       "Regional welfare"
* BS 2020-03-13 additions for distributional module
* q02_consPcap(ttot,all_regi)                       "per capita consumption"
*q02_relConsLoss(ttot,all_regi)                    "relative consumption loss w.r.t. reference run"
* TN
q02_relTaxlevels(ttot,all_regi)                    "tax revenues w.r.t. consumption"
* TN
q02_emiEnergyco2eq(ttot,all_regi)                          "emissions from energy system + DAC"
q02_emiEnergyco2eqMkt(ttot,all_regi,all_emiMkt)               "emissions from all GHG from energy system for each emiMkt"
q02_emiIndus(ttot,all_regi)                            "emissions from fugitive and industrial processes"

* TN to remove! (since CES data is a parameter, no need for an equation)
*q02_EnergyExp_enty(ttot,all_regi,all_enty,all_enty,all_te)   "energy expenditure, disaggregated level"
*q02_EnergyExp_Add(ttot,all_regi)                     "regional additional energy expenditure w.r.t. reference run"

* q02_distrNormalization(ttot,all_regi)             "normalization parameter for distribution of costs"
* q02_distrNew_SecondMom(ttot,all_regi)             "Second moment of distribution after subtracting costs"
* q02_distrNew_mu(ttot,all_regi)                    "mu parameter of lognormal distribution after costs"
* TN
q02_distrNew_sigmaSq(ttot,all_regi)               "sigma^2 parameter of lognormal distribution after costs"
q02_distrFinal_sigmaSq(ttot,all_regi)             "sigma^2 parameter of lognormal final distribution (after costs and taxes)"

$ifthen.inconv %cm_INCONV_PENALTY% == "on"
q02_inconvPen(ttot,all_regi)                      "Calculate the inconvenience penalty v02_inconvPen"
q02_inconvPenCoalSolids(ttot,all_regi)            "Calculate the inconvenience penalty v02_inconvPen"
$endif.inconv
;

*** EOF ./modules/02_welfare/ineqLognormal/declarations.gms
