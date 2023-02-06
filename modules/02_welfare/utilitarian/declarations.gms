*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/utilitarian/declarations.gms

***-------------------------------------------------------------------------------
***                                   PARAMETERS
***-------------------------------------------------------------------------------
parameters
pm_welf(tall)                                     "Weight parameter in the welfare function to avoid jumps for years between differnet time step lengths"
pm_w(all_regi)                                    "Negishi weights"
pm_prtp(all_regi)                                 "Pure rate of time preference"

pm_sccIneq(tall,all_regi)			  "inequality term in the SCC calculation"

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

$ifthen.inconv %cm_INCONV_PENALTY% == "on" 
v02_inconvPen(ttot,all_regi)                      "Inconvenience penalty in the welfare function, e.g. for air pollution. Unit: ?Utils?"
v02_inconvPenCoalSolids(ttot,all_regi)            "Inconvenience penalty in the welfare function, e.g. for air pollution. Unit: ?Utils?"
v02_sesoInconvPenSlack(ttot,all_regi)             "Slack to avoid negative inconvenience penalty for Coal Solids" 
$endif.inconv
;

positive variables
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

$ifthen.inconv %cm_INCONV_PENALTY% == "on"
q02_inconvPen(ttot,all_regi)                      "Calculate the inconvenience penalty v02_inconvPen"
q02_inconvPenCoalSolids(ttot,all_regi)            "Calculate the inconvenience penalty v02_inconvPen"
$endif.inconv

$IFTHEN.INCONV_bioSwitch "%cm_INCONV_PENALTY_FESwitch%" == "on"
q02_inconvPenFeBioSwitch(ttot,all_regi,all_enty,all_enty,all_te,emi_sectors,all_emiMkt)  "Calculate the inconvenience penalty to avoid switching biomass and synfuel shares in hydrocarbons in buildings, transport and industry and emissions markets if costs are relatively close"
$ENDIF.INCONV_bioSwitch

;

*** EOF ./modules/02_welfare/utilitarian/declarations.gms
