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
*p02_consPcap_ref(ttot,all_regi)                    "per capita consumption in reference run"
p02_ineqTheil(ttot,all_regi)		                   "regional Theil-T index = sigma^2/2 for lognormal"
p02_distrMu(ttot,all_regi)                         "mu of lognormal distribution (prior to mitigation costs)"
p02_distrSigma(ttot,all_regi)                      "sigma of lognormal distribution (prior to mitigation costs)"
p02_distrAlpha(ttot,all_regi)                      "income elasticity of mitigation costs"
* TN
p02_distrBeta(ttot,all_regi)                       "income elasticity of revenues redistribution"
* p02_distrEVyAlpha(ttot,all_regi)                   "expectation value of income^alpha (used in several places)"

*p02_relConsLoss(ttot,all_regi)                    "relative consumption loss w.r.t. reference run"
p02_taxrev_redistr0_ref(ttot,all_regi)             "tax revenue in the reference run"
p02_EnergyExp_ref(ttot,all_regi)                     "regional energy expenditure in the reference scenario "
*p02_FEPrice_ref(ttot,all_regi,all_enty,sector,emiMkt)
*p02_demFeSector_ref(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "FE in ref scenario"
p02_prodFe_ref(ttot,all_regi,all_enty,all_enty,all_te) "final energy in ref"
*p02_EnergyExp_Add(ttot,all_regi)                      "energy exp in a parameter"
p02_energyexpShare(ttot,all_regi)                     "energy exp share as a parameter"
p02_revShare(ttot,all_regi)                         "tax revenues (share of consumption)"

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
*v02_energyexpShare(ttot,all_regi)                    "relative additional energy expenditure w.r.t. reference run"
* v02_distrNormalization(ttot,all_regi)             "normalization parameter for lognormal distribution of costs"
*v02_revShare(ttot,all_regi)                         "tax revenues (share of consumption)"
v02_taxrev_Add(ttot,all_regi)                      "tax revenue w.r.t. reference run"
*v02_EnergyExp_Add(ttot,all_regi)                   "additional energy expenditure w.r.t. reference run"
*v02_taxrev(ttot,all_regi)                          "tax revenue"

*v02_taxrev_redistr(ttot,all_regi)             "tax revenue in the reference run"
v02_energyexpShare(ttot,all_regi)                    "relative additional energy expenditure w.r.t. reference run"
* v02_distrNormalization(ttot,all_regi)             "normalization parameter for lognormal distribution of costs"
v02_revShare(ttot,all_regi)                         "tax revenues (share of consumption)"
v02_EnergyExp_Add(ttot,all_regi)                   "additional energy expenditure w.r.t. reference run"
v02_distrAlpha(ttot,all_regi)                      "income elasticity of mitigation costs"



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
*v02_distrNew_sigmaSq(ttot,all_regi)                    "sigma^2 parameter of lognormal distribution after costs (but before tax)"
* TN
v02_distrFinal_sigmaSq(ttot,all_regi)                  "sigma^2 parameter of final lognormal distribution (after redistributional effects of taxes)"
v02_budget_first(ttot,all_regi)
v02_budget_second(ttot,all_regi)
v02_distrFinal_sigmaSq_limit(ttot,all_regi)
v02_distrFinal_sigmaSq_welfare(ttot,all_regi)
v02_distrFinal_sigmaSq_limit2(ttot,all_regi)

;

***-------------------------------------------------------------------------------
***                                   EQUATIONS
***-------------------------------------------------------------------------------
equations
q02_welfareGlob                                   "Global welfare"
q02_welfare                                       "Regional welfare"
* BS 2020-03-13 additions for distributional module
* q02_consPcap(ttot,all_regi)                       "per capita consumption"
q02_energyexpShare(ttot,all_regi)                    "additional energy exp w.r.t. reference run as a share of consumption"
* TN
q02_relTaxlevels(ttot,all_regi)                    "relative tax revenues "
q02_taxrev_Add(ttot,all_regi)                      "tax revenue w.r.t. reference run"
*q02_taxrev(ttot,all_regi)                          "tax revenue"

* TN

q02_EnergyExp_Add(ttot,all_regi)                       "regional additional energy expenditure w.r.t. reference run"

q02_distrAlpha(ttot,all_regi)                      "income elasticity of mitigation costs"

q02_energyexpShare_cap(ttot,all_regi)               "cap energy expenditure share"

*q02_energyexpShare_ineq(ttot,all_regi)                    "additional energy exp w.r.t. reference run as a share of consumption"
*q02_relTaxlevels_ineq(ttot,all_regi)                    "relative tax revenues "



* q02_distrNormalization(ttot,all_regi)             "normalization parameter for distribution of costs"
* q02_distrNew_SecondMom(ttot,all_regi)             "Second moment of distribution after subtracting costs"
* q02_distrNew_mu(ttot,all_regi)                    "mu parameter of lognormal distribution after costs"
* TN
*q02_distrNew_sigmaSq(ttot,all_regi)               "sigma^2 parameter of lognormal distribution after costs"
q02_distrFinal_sigmaSq(ttot,all_regi)             "sigma^2 parameter of lognormal final distribution (after costs and taxes)"
q02_distrFinal_sigmaSq_limit(ttot,all_regi)        "sigma limit"
q02_distrFinal_sigmaSq_welfare(ttot,all_regi)

q02_distrFinal_sigmaSq_limit2(ttot,all_regi)        "sigma limit"


q02_budget_first(ttot,all_regi)                 "making sure budget is positive"
q02_budget_second(ttot,all_regi)                 "making sure budget is positive"


$ifthen.inconv %cm_INCONV_PENALTY% == "on"
q02_inconvPen(ttot,all_regi)                      "Calculate the inconvenience penalty v02_inconvPen"
q02_inconvPenCoalSolids(ttot,all_regi)            "Calculate the inconvenience penalty v02_inconvPen"
$endif.inconv
;

*** EOF ./modules/02_welfare/ineqLognormal/declarations.gms
