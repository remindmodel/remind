*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/all/declarations.gms
scalars
s33_co2_rem_pot             "specific carbon removal potential [Gt C per Gt ground rock]"
s33_co2_rem_rate            "carbon removal rate [fraction of annual reduction of total carbon removal potential]"
s33_rockgrind_fedem         "specific energy demand for grinding rocks [EJ per Gt of ground rock]"
s33_rockfield_fedem         "specific energy demand for spreading rocks on field [EJ per Gt of ground rock]"
s33_costs_fix               "fixed costs for mining, grinding, spreading [T$/Gt stone]"
s33_step                    "size of bins in v33_grindrock_onfield [Gt stone]"
*JeS* GJ/tCO2 = EJ/Gt CO2 = 44/12 EJ/Gt C. Numbers from Report from Micah Broehm.
;

parameters
p33_transport_costs(all_regi,rlf,rlf)    "transport costs [T$/Gt stone]"
p33_co2_rem_rate(rlf)                    "carbon removal rate [fraction of annual reduction of total carbon removal potential], multiplied with grade factor"
p33_dac_fedem_el(all_enty)           "specific electricity demand for direct air capture [EJ per Gt of C captured] - ventilation"
p33_dac_fedem_heat(all_enty)         "specific heat demand for direct air capture [EJ per Gt of C captured] - absorption material recovery"
p33_LimRock(all_regi)                    "regional share of EW limit [fraction], calculated ex ante for a maximal annual amount of 8 Gt rock in D:\projects\CEMICS\paper_technical\supply_curve_transport_remind_regions.m"
;

positive variables
v33_grindrock_onfield(ttot,all_regi,rlf,rlf)      "amount of ground rock spread on fields in each timestep [Gt]"
v33_grindrock_onfield_tot(ttot,all_regi,rlf,rlf)  "total amount of ground rock on fields [Gt]"
v33_DacFEdemand_el(ttot,all_regi,all_enty)          "DAC FE electricity demand [TWa]"
v33_DacFEdemand_heat(ttot,all_regi,all_enty)        "DAC FE heat demand [TWa]"
;

variables
vm_ccs_cdr(ttot,all_regi,all_enty,all_enty,all_te,rlf)  "CCS emissions from CDR [GtC per a]"
v33_emiDAC(ttot,all_regi)                               "carbon captured from DAC [GtC by a]"
v33_emiEW(ttot,all_regi)                                "negative CO2 emission from EW [GtC by a]"
;

equations
q33_demFeCDR(ttot,all_regi,all_enty)                "CDR demand balance for final energy"
q33_otherFEdemand(ttot,all_regi,all_enty)           "calculates final energy demand from no transformation technologies (e.g. enhanced weathering)"
q33_DacFEdemand_heat(ttot,all_regi,all_enty)        "calculates DAC FE demand for heat"
q33_DacFEdemand_el(ttot,all_regi,all_enty)          "calculates DAC FE demand for electricity"
q33_capconst_grindrock(ttot,all_regi)               "calculates amount of ground rock spred on fields"
q33_grindrock_onfield_tot(ttot,all_regi,rlf,rlf)    "total amount of ground rock on fields"
q33_omcosts(ttot,all_regi)                          "calculates O&M costs for spreading ground rocks on fields"
q33_potential(ttot,all_regi,rlf)                    "limits the total potential of EW per region and grade"
q33_emiEW(ttot,all_regi)                            "calculates amount of carbon captured by EW"
q33_LimEmiEW(ttot,all_regi)                         "limits EW to a maximal annual amount of ground rock of cm_LimRock"
q33_capconst_dac(ttot,all_regi)                     "calculates amount of carbon captured by DAC"
q33_emicdrregi(ttot,all_regi)                       "calculates the (negative) emissions due to CDR technologies"
q33_ccsbal(ttot,all_regi,all_enty,all_enty,all_te)  "calculates CCS emissions from CDR technologies"
q33_H2bio_lim(ttot,all_regi,all_te)                 "limits H2 from bioenergy to FE - otherFEdemand, i.e. no H2 from bioenergy for DAC"
;

*** EOF ./modules/33_CDR/all/declarations.gms
