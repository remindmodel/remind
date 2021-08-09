*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/DAC/declarations.gms
parameters
*AnM* kWh/tCO2 = 1/278 * GJ/tCO2 = 1/278 * EJ/Gt CO2 = 1/278 * 44/12 EJ/Gt C. Numbers from Beutler et al. 2019 (Climeworks)
p33_dac_fedem_el(all_enty)           "specific electricity demand for direct air capture [EJ per Gt of C captured] - ventilation"
p33_dac_fedem_heat(all_enty)         "specific heat demand for direct air capture [EJ per Gt of C captured] - absorption material recovery"
;

variables
vm_ccs_cdr(ttot,all_regi,all_enty,all_enty,all_te,rlf)  "CCS emissions from CDR [GtC / a]"
v33_emiDAC(ttot,all_regi)       "negative CO2 emission from DAC [GtC / a]"
v33_emiEW(ttot,all_regi)        "negative CO2 emission from EW [GtC / a] - fixed to 0, only defined for reporting reasons"
;

positive variables
v33_grindrock_onfield(ttot,all_regi,rlf,rlf)         "amount of ground rock spread on fields in each timestep [Gt]"
v33_grindrock_onfield_tot(ttot,all_regi,rlf,rlf)     "total amount of ground rock on fields [Gt]"
v33_DacFEdemand_el(ttot,all_regi,all_enty)          "DAC FE electricity demand [TWa]"
v33_DacFEdemand_heat(ttot,all_regi,all_enty)        "DAC FE heat demand [TWa]"
;

equations
q33_DacFEdemand_heat(ttot,all_regi,all_enty)        "calculates DAC FE demand for heat"
q33_DacFEdemand_el(ttot,all_regi,all_enty)          "calculates DAC FE demand for electricity"
q33_otherFEdemand(ttot,all_regi,all_enty)           "calculates final energy demand from no transformation technologies (e.g. enhanced weathering)"
q33_capconst_dac(ttot,all_regi)                     "calculates amount of carbon captured"
q33_ccsbal(ttot,all_regi,all_enty,all_enty,all_te)  "calculates CCS emissions from CDR technologies"
q33_H2bio_lim(ttot,all_regi,all_te)                 "limits H2 from bioenergy to FE - otherFEdemand, i.e. no H2 from bioenergy for DAC"
q33_emicdrregi(ttot,all_regi)                       "calculates the (negative) emissions due to CDR technologies"
q33_demFeCDR(ttot,all_regi,all_enty)                "CDR demand balance for final energy"
;

*** EOF ./modules/33_CDR/DAC/declarations.gms
