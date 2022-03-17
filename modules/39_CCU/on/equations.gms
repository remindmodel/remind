*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/equations.gms

*** ---------------------------------------------------------
*** calculate CCU emissions (= CO2 demand of CCU technologies)
*** ---------------------------------------------------------

q39_emiCCU(t,regi,te)$(te_ccu39(te)).. 
  sum(teCCU2rlf(te,rlf),
    vm_co2CCUshort(t,regi,"cco2","ccuco2short",te,rlf)
  )
  =e=
  sum(se2se_ccu39(enty,enty2,te), 
    p39_co2_dem(t,regi,enty,enty2,te) 
  * vm_prodSe(t,regi,enty,enty2,te)
  )
;


*' Adjust the shares of synfuels in transport liquids.
*' This equation is only effective when CCU is switched on.
q39_shSynTrans(t,regi)..
    (
	sum(pe2se(entyPe,entySe,te)$seAgg2se("all_seliq",entySe), vm_prodSe(t,regi,entyPe,entySe,te))
	+ sum(se2se(entySe,entySe2,te)$seAgg2se("all_seliq",entySe2), vm_prodSe(t,regi,entySe,entySe2,te))
    ) * v39_shSynTrans(t,regi)
    =e=
    vm_prodSe(t,regi,"seh2","seliqsyn","MeOH")
;

*** share of synthetic gas in all SE gases
q39_shSynGas(t,regi)..
    (
	sum(pe2se(entyPe,entySe,te)$seAgg2se("all_sega",entySe), vm_prodSe(t,regi,entyPe,entySe,te))
	+ sum(se2se(entySe,entySe2,te)$seAgg2se("all_sega",entySe2), vm_prodSe(t,regi,entySe,entySe2,te))
    ) * v39_shSynGas(t,regi)
    =e=
    vm_prodSe(t,regi,"seh2","segasyn","h22ch4")
;

*** impose same shares of synfuels in total biofuel+synfuel across all transport subsectors
q39_EqualSecShare_BioSyn(t,regi,entyFe,sector,emiMkt)$(enty_BioSyn_39(entyFe,sector,emiMkt))..
  vm_demFeSector(t,regi,"seliqsyn",entyFe,sector,emiMkt)
  * sum(enty_BioSyn_39(entyFe2,sector2,emiMkt2),
      ( vm_demFeSector(t,regi,"seliqsyn",entyFe2,sector2,emiMkt2)
      + vm_demFeSector(t,regi,"seliqbio",entyFe2,sector2,emiMkt2)))
  =e=
  ( vm_demFeSector(t,regi,"seliqsyn",entyFe,sector,emiMkt)
    + vm_demFeSector(t,regi,"seliqbio",entyFe,sector,emiMkt))
  * sum(enty_BioSyn_39(entyFe2,sector2,emiMkt2), 
      vm_demFeSector(t,regi,"seliqsyn",entyFe2,sector2,emiMkt2))
;

*** EOF ./modules/39_CCU/on/equations.gms
