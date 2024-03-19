*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/declarations.gms
scalars
s33_co2_rem_pot             "specific carbon removal potential [Gt C per Gt ground rock]"
s33_co2_rem_rate            "carbon removal rate [fraction of annual reduction of total carbon removal potential]"
s33_costs_fix               "fixed costs for mining, grinding, spreading [T$/Gt stone]"
s33_step                    "size of bins in v33_weathering_onfield [Gt stone]"
*JeS* GJ/tCO2 = EJ/Gt CO2 = 44/12 EJ/Gt C.
;

parameters
p33_fedem(all_te,all_enty)               "final energy demand of each technology [EJ/GtC] (for EW the unit is [EJ/Gt stone])"
p33_LimRock(all_regi)                    "regional share of EW limit [fraction], calculated ex ante for a maximal annual amount of 8 Gt rock in D:\projects\CEMICS\paper_technical\supply_curve_transport_remind_regions.m"
p33_co2_rem_rate(rlf)                    "carbon removal rate [fraction of annual reduction of total carbon removal potential], multiplied with grade factor"
;

positive variables
v33_EW_onfield(ttot,all_regi,rlf,rlf)  "amount of ground rock spread on fields in each timestep [Gt]"
v33_EW_onfield_tot(ttot,all_regi,rlf,rlf)  "total amount of ground rock on fields, for each climate zone and transportation distance [Gt]"
v33_FEdemand(ttot,all_regi,all_enty,all_enty,all_te)  "FE demand of each technology [TWa]"
vm_ccs_cdr(ttot,all_regi,all_enty,all_enty,all_te,rlf)  "total emissions captured through technologies in the CDR module that enter the CCUS chain + captured emissions from associated FE demand [GtC / a]"
;

negative variables
vm_emiCdrTeDetail(ttot,all_regi,all_te)               "(negative) emissions from CDR technologies in the CDR module by technology. Includes all atmospheric CO2 that enter the CCUS chain (i.e. CO2 stored (CDR) AND used (not CDR)) [GtC / a]"
;

equations
q33_demFeCDR(ttot,all_regi,all_enty)  "CDR demand balance for final energy"
q33_emiCDR(ttot,all_regi)  "aggregates the (negative) emissions captured by the CDR technologies"
q33_H2bio_lim(ttot,all_regi)  "limits H2 from bioenergy to FE - H2 demand from CDR, i.e. no H2 from bioenergy for DAC"
q33_DAC_emi(ttot,all_regi)  "calculates amount of carbon captured by DAC"
q33_DAC_FEdemand(ttot,all_regi,all_enty)  "calculates final energy demand from DAC"
q33_DAC_ccsbal(ttot,all_regi,all_enty,all_enty,all_te)  "calculates CCS emissions from CDR technologies"
q33_EW_capconst(ttot,all_regi)  "calculates amount of ground rock spread on fields"
q33_EW_onfield_tot(ttot,all_regi,rlf,rlf)  "total amount of ground rock on fields"
q33_EW_omcosts(ttot,all_regi)  "calculates O&M costs for spreading ground rocks on fields"
q33_EW_FEdemand(ttot,all_regi,all_enty)  "calculates final energy demand from enhanced weathering"
q33_EW_potential(ttot,all_regi,rlf)  "limits the total potential of EW per region and grade"
q33_EW_emi(ttot,all_regi)  "calculates amount of carbon captured by EW"
q33_EW_LimEmi(ttot,all_regi)  "limits EW to a maximal annual amount of ground rock of cm_LimRock"
;

*** EOF ./modules/33_CDR/portfolio/declarations.gms
