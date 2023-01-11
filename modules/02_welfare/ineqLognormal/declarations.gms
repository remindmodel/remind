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
p02_cons_ref(ttot,all_regi)                        "consumption in reference run"
p02_ineqTheil(ttot,all_regi)		                   "regional Theil-T index = sigma^2/2 for lognormal"
p02_distrMu(ttot,all_regi)                         "mu of lognormal distribution (prior to mitigation costs)"
p02_distrSigma(ttot,all_regi)                      "sigma of lognormal distribution (prior to mitigation costs)"
p02_distrAlpha(ttot,all_regi)                      "income elasticity of mitigation costs"
p02_distrBeta(ttot,all_regi)                       "income elasticity of revenues redistribution"

p02_taxrev_redistr0_ref(ttot,all_regi)             "tax revenue in the reference run"
p02_energyExp_ref(ttot,all_regi)                     "regional energy expenditure in the reference scenario "
p02_prodFe_ref(ttot,all_regi,all_enty,all_enty,all_te) "final energy in ref"

p02_damConsFactor1(ttot,all_regi)		"factor translating output damages to consumption losses"
p02_damConsFactor2(ttot,all_regi)		"factor translating output damages to consumption losses"
pm_sccIneq(tall,all_regi)			"inequality term in SCC calculation"

$ifthen.inconv %cm_INCONV_PENALTY% == "on"
p02_inconvpen_lap(ttot,all_regi,all_te)           "Parameter for inconvenience penalty for local air pollution. [T$/TWa at Consumption of 1000$/cap]"
$endif.inconv

$IFTHEN.INCONV_bioSwitch "%cm_INCONV_PENALTY_FESwitch%" == "on"
p02_inconvPen_Switch_Track(ttot,all_regi)                       "Parameter to track magnitude of inconvenience penalty for bio/synfuel share switching [share of consumption]"
$ENDIF.INCONV_bioSwitch
;

***-------------------------------------------------------------------------------
***                                   VARIABLES
***-------------------------------------------------------------------------------
variables
v02_welfare(all_regi)                             "Regional welfare"
vm_welfareGlob                                    "Global welfare"
v02_taxrev_Add(ttot,all_regi)                     "tax revenue w.r.t. reference run"
v02_energyExp(ttot,all_regi)                      "regional energy expenditure "
v02_energyexpShare(ttot,all_regi)                 "relative additional energy expenditure w.r.t. reference run"
v02_emitaxredistr(ttot,all_regi)                  "emissions that will be taxes and redistributed"
v02_revShare(ttot,all_regi)                       "tax revenues (share of consumption)"
v02_energyExp_Add(ttot,all_regi)                  "additional energy expenditure w.r.t. reference run"
v02_distrAlpha(ttot,all_regi)                     "income elasticity of mitigation costs"
v02_damageConsShare(ttot,all_regi)		  "share of consumption loss from damages in consumption"


$ifthen.inconv %cm_INCONV_PENALTY% == "on"
v02_inconvPen(ttot,all_regi)                      "Inconvenience penalty in the welfare function, e.g. for air pollution. Unit: ?Utils?"
v02_inconvPenCoalSolids(ttot,all_regi)            "Inconvenience penalty in the welfare function, e.g. for air pollution. Unit: ?Utils?"
v02_sesoInconvPenSlack(ttot,all_regi)             "Slack to avoid negative inconvenience penalty for Coal Solids"
$endif.inconv
;

positive variables
v02_distrFinal_sigmaSq(ttot,all_regi)                  "sigma^2 parameter of final lognormal distribution (after redistributional effects of taxes)"
v02_distrFinal_sigmaSq_postDam(ttot,all_regi)                  "sigma^2 parameter of final lognormal distribution (after redistributional effects of taxes and damages)"
v02_distrFinal_sigmaSq_limit(ttot,all_regi)        "Limit past which inequality improvements do not lead to welfare benefits"
v02_distrFinal_sigmaSq_welfare(ttot,all_regi)       "sigma^2 entering welfare"

$IFTHEN.INCONV_bioSwitch "%cm_INCONV_PENALTY_FESwitch%" == "on"
v02_NegInconvPenFeBioSwitch(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "Negative inconvenience penalty in the welfare function for bio/synfuel shares switch between sectors and emissions markets"
v02_PosInconvPenFeBioSwitch(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt) "Positive inconvenience penalty in the welfare function for bio/synfuel shares switch between sectors and emissions markets"
$ENDIF.INCONV_bioSwitch
;

***-------------------------------------------------------------------------------
***                                   EQUATIONS
***-------------------------------------------------------------------------------
equations
q02_welfareGlob                                   "Global welfare"
q02_welfare                                       "Regional welfare"
q02_energyExp(ttot,all_regi)                      "regional energy expenditure "
q02_emitaxredistr(ttot,all_regi)                  "emissions that will be taxes and redistributed"
q02_energyexpShare(ttot,all_regi)                    "additional energy exp w.r.t. reference run as a share of consumption"
q02_relTaxlevels(ttot,all_regi)                    "relative tax revenues "
q02_taxrev_Add(ttot,all_regi)                      "tax revenue w.r.t. reference run"

q02_energyExp_Add(ttot,all_regi)                       "regional additional energy expenditure w.r.t. reference run"

q02_consLossShare(ttot,all_regi)		"share of consumption loss from damages"

q02_distrAlpha(ttot,all_regi)                      "income elasticity of mitigation costs"

q02_energyexpShare_cap(ttot,all_regi)               "cap energy expenditure share"

q02_distrFinal_sigmaSq(ttot,all_regi)             "sigma^2 parameter of lognormal final distribution (after costs and taxes)"
q02_distrFinal_sigmaSq_postDam(ttot,all_regi)             "sigma^2 parameter of lognormal final distribution (after costs, taxes and damages)"
q02_distrFinal_sigmaSq_limit(ttot,all_regi)        "sigma limit"
q02_distrFinal_sigmaSq_welfare(ttot,all_regi)	"sigma^2 entering welfare equation after applying the limit"

q02_budget_first(ttot,all_regi)                 "making sure budget is positive"
q02_budget_second(ttot,all_regi)                 "making sure budget is positive"


$ifthen.inconv %cm_INCONV_PENALTY% == "on"
q02_inconvPen(ttot,all_regi)                      "Calculate the inconvenience penalty v02_inconvPen"
q02_inconvPenCoalSolids(ttot,all_regi)            "Calculate the inconvenience penalty v02_inconvPen"
$endif.inconv

$IFTHEN.INCONV_bioSwitch "%cm_INCONV_PENALTY_FESwitch%" == "on"
q02_inconvPenFeBioSwitch(ttot,all_regi,all_enty,all_enty,all_te,emi_sectors,all_emiMkt)  "Calculate the inconvenience penalty to avoid switching biomass and synfuel shares in hydrocarbons in buildings, transport and industry and emissions markets if costs are relatively close"
$ENDIF.INCONV_bioSwitch

;
*** EOF ./modules/02_welfare/ineqLognormal/declarations.gms
