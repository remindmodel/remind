*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/weathering/declarations.gms
scalars
s33_co2_rem_pot             "specific carbon removal potential [Gt C per Gt ground rock]"
s33_co2_rem_rate            "carbon removal rate [fraction of annual reduction of total carbon removal potential]"
s33_costs_fix               "fixed costs for mining, grinding, spreading [T$/Gt stone]"
s33_step                    "size of bins in v33_EW_onfield [Gt stone]"
;

parameters
p33_transport_costs(all_regi,rlf,rlf)  "transport costs [T$/Gt stone]"
p33_ew_fedem(all_enty)                 "specific final energy demand for grinding and spreading rocks [EJ per Gt of ground rock]"
p33_co2_rem_rate(rlf)                  "carbon removal rate [fraction of annual reduction of total carbon removal potential], multiplied with grade factor"
p33_LimRock(all_regi)                  "regional share of EW limit [fraction], calculated ex ante for a maximal annual amount of 8 Gt rock in D:\projects\CEMICS\paper_technical\supply_curve_transport_remind_regions.m"
;

positive variables
v33_ew_onfield(ttot,all_regi,rlf,rlf)                  "amount of ground rock spread on fields in each timestep [Gt]"
v33_ew_onfield_tot(ttot,all_regi,rlf,rlf)              "total amount of ground rock on fields [Gt]"
v33_FEdemand(ttot,all_regi,all_enty, all_enty, all_te) "cdr FE demand [TWa]"
;

variables
vm_ccs_cdr(ttot,all_regi,all_enty,all_enty,all_te,rlf) "CCS emissions from CDR [GtC / a]"
;

negative variables
v33_emi(ttot,all_regi,all_te)                          "negative CO2 emission from CDR [GtC / a]"
;

equations
q33_cdr_FEdemand(ttot,all_regi,all_enty)               "CDR demand balance for final energy"
q33_ew_FEdemand(ttot, all_regi, all_enty)              "calculates weathering FE demand"
q33_ew_capconst(ttot,all_regi)                         "calculates amount of ground rock spread on fields"
q33_ew_onfield_tot(ttot,all_regi,rlf,rlf)              "calculates total amount of ground rock on fields"
q33_ew_onfield_tot_bound(ttot,all_regi)                "sets boundaries for v33_ew_onfield_tot required in q33_ew_onfield_tot"
q33_ew_omcosts(ttot,all_regi)                          "calculates O&M costs for spreading ground rocks on fields"
q33_emicdrregi(ttot,all_regi)                          "calculates the (negative) emissions due to CDR technologies"
q33_ew_omcosts(ttot,all_regi)                          "calculates O&M costs for spreading ground rocks on fields"
q33_ew_potential(ttot,all_regi,rlf)                    "limits the total potential per region and grade"
q33_ew_emi(ttot,all_regi)                              "calculates amount of carbon captured by EW"
q33_ew_LimEmi(ttot,all_regi)                           "limits EW to a maximal annual amount of ground rock of cm_LimRock"
;

*** EOF ./modules/33_CDR/weathering/declarations.gms
