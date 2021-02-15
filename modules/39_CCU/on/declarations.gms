*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/declarations.gms

parameters
p39_co2_dem(ttot,all_regi,all_enty,all_enty,all_te)					"CO2 demand of CCU technologies, unit: tC/TWa(output)"
;

positive variables
vm_co2CCUshort(ttot,all_regi,all_enty,all_enty,all_te,rlf)           "CO2 captured in CCU te that have a persistence for co2 storage shorter than 5 years. Unit GtC/a"
v39_shSynTrans(ttot,all_regi)                                        "Share of synthetic liquids in all SE liquids. Value between 0 and 1."
v39_shSynGas(ttot,all_regi)                                          "Share of synthetic gas in all SE gases. Value between 0 and 1."
;

equations
q39_emiCCU(ttot,all_regi,all_te)                                        "calculate CCU emissions"
q39_shSynTrans(ttot,all_regi)                                           "Define share of of synthetic liquids in all SE liquids."
q39_shSynGas(ttot,all_regi)                                             "Define share of of synthetic gas in all SE gases."
;

*** EOF ./modules/39_CCU/on/declarations.gms
