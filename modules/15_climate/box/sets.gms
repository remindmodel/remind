*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/15_climate/box/sets.gms
* ------------ SETS ---------------
sets
ta10(tall)      "points in time for ACC2" /2000*2150/
FOBBOX10        "forcing agents for box-multigas model including aerosols and oghg" /CO2,CH4,N2O,SO2,BC,OC,oghg_kyo,oghg_nokyo,oghg_nokyo_rcp,TTL/
***FOAAER        "aerosol species" /CRBFF, CRBBB, NITAER/

FOB10   "Forcing agents and ozone depleting substances with specified emissions"
/
     CO2,
     CH4, N2O,
     SO2, BC, OC
/
FOBEMI(FOB10)      "REMIND-emissions-related forcings"
   /CO2, SO2, BC, OC, CH4, N2O/
emiaer(all_enty)    "???"
/
       so2
       bc
       oc
/  
***---------------------mappings------------------------------------  
emis2climate10(all_enty,FOB10)   "???"
/
       co2.CO2
       ch4.CH4
       n2o.N2O
$IF %cm_so2_out_of_opt% == "off"       so2.SO2
$IF %cm_so2_out_of_opt% == "off"       bc.BC
$IF %cm_so2_out_of_opt% == "off"       oc.OC
/
emiaer2climate10(emiaer,FOB10)   "???"
/
       so2.SO2
       bc.BC
       oc.OC
/
ttot2ta10(ttot,ta10)    "transformation parameter ttot and ta10",
ta2ttot10(ta10,ttot)    "transformation parameter ta10 and ttot"
;

alias(ta10,tx);   !!  *LB* to be renamed

ttot2ta10(ttot, ta10)$((ttot.val = ta10.val) AND (ttot.val ge 2005)) = Yes;


*** EOF ./modules/15_climate/box/sets.gms
