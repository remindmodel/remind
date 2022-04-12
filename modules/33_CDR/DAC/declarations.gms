*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/DAC/declarations.gms
parameters
*AnM* kWh/tCO2 = 1/278 * GJ/tCO2 = 1/278 * EJ/Gt CO2 = 1/278 * 44/12 EJ/Gt C. Numbers from Beutler et al. 2019 (Climeworks)
p33_dac_fedem(all_enty)                  "specific final energy demand for direct air capture [EJ per Gt of C captured]"
;

variables
vm_ccs_cdr(ttot,all_regi,all_enty,all_enty,all_te,rlf)  "CCS emissions from CDR [GtC / a]"
v33_emiDAC(ttot,all_regi)       "negative CO2 emission from DAC [GtC / a]"
;

positive variables
v33_FEdemand(ttot,all_regi,all_enty, all_enty, all_te)    "DAC FE demand [TWa]"
;

equations
q33_DacFEdemand(ttot,all_regi,all_enty)             "calculates DAC FE demand"
q33_capconst_dac(ttot,all_regi)                     "calculates amount of carbon captured"
q33_ccsbal(ttot,all_regi,all_enty,all_enty,all_te)  "calculates CCS emissions from CDR technologies"
q33_H2bio_lim(ttot,all_regi,all_te)                 "limits H2 from bioenergy to FE - DacFEdemand, i.e. no H2 from bioenergy for DAC"
q33_emicdrregi(ttot,all_regi)                       "calculates the (negative) emissions due to CDR technologies"
q33_demFeCDR(ttot,all_regi,all_enty)                "CDR demand balance for final energy"
;

*** EOF ./modules/33_CDR/DAC/declarations.gms
