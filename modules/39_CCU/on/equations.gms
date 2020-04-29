*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/equations.gms


***---------------------------------------------------------------------------
*' Managing the C/H ratio in CCU-Technologies
*' amount of C temporary used in CCU-products in relation to the amount of hydrogen necessary [GtC/y]
***---------------------------------------------------------------------------

q39_emiCCU(t,regi) .. 
  sum(teCCU2rlf(te,rlf),
    vm_co2CCUshort(t,regi,"cco2","ccuco2short",te,rlf)
  )
  =e=
  sum(se2se_ccu39(enty,enty2,te), 
    p39_ratioCtoH(t,regi,enty,enty2,te,"CtoH") 
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
    vm_prodSe(t,regi,"seh2","seliqfos","MeOH")
;


*** EOF ./modules/39_CCU/on/equations.gms
