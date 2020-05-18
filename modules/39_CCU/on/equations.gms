*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/equations.gms

*** ---------------------------------------------------------
*** calculate CCU emissions (= CO2 demand of CCU technologies)
*** ---------------------------------------------------------

q39_emiCCU(t,regi) .. 
  sum(teCCU2rlf(te,rlf),
    vm_co2CCUshort(t,regi,"cco2","ccuco2short",te,rlf)
  )
  =e=
  sum(se2se_ccu39(enty,enty2,te), 
    p39_co2_dem(t,regi,enty,enty2,te) 
  * vm_prodSe(t,regi,enty,enty2,te)
  )
;

*** EOF ./modules/39_CCU/on/equations.gms
