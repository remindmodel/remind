*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/declarations.gms

***-------------------------------------------------------------------------------
***                                   PARAMETERS
***-------------------------------------------------------------------------------
***-------------------------------------------------------------------------------
***---------------------------------------------ESM module------------------------

parameters
p39_ratioCtoH(tall,all_regi,all_enty,all_enty,all_te,all_enty)         "ratio between C and H in CCU-technologies, make sure if you refer to H or H2 in source"
;


***-------------------------------------------------------------------------------
***                                   POSITIVE VARIABLES
***-------------------------------------------------------------------------------
*---------------------------------------------------------------------------------
*-----------------------------------------------ESM module------------------------

positive variables
vm_co2CCUshort(ttot,all_regi,all_enty,all_enty,all_te,rlf)           "CO2 captured in CCU te that have a persistence for co2 storage shorter than 5 years. Unit GtC/a"
v39_shSynTrans(ttot,all_regi)   "Share of synthetic liquids in all fossil liquids. Value between 0 and 1."
;


***-------------------------------------------------------------------------------
***                                   EQUATIONS
***-------------------------------------------------------------------------------
***-------------------------------------------------------------------------------
***---------------------------------------------ESM module------------------------

equations
q39_emiCCU(ttot,all_regi)                                               "Managing the C/H ratio in CCU-Technologies"
q39_shSynTrans(ttot,all_regi)  "Define share of synthetic liquids in all fossil liquids."
;

*** EOF ./modules/39_CCU/on/declarations.gms
