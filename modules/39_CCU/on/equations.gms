*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/equations.gms

*' @equations

*** ---------------------------------------------------------
*' calculate CCU emissions (= CO2 demand of CCU technologies)
*** ---------------------------------------------------------

q39_emiCCU(t,regi,te)$(te_ccu39(te) OR teCUPrc(te))..
  sum(teCCU2rlf(te,rlf),
    vm_co2CCUshort(t,regi,"cco2","ccuco2short",te,rlf)
  )
  =e=
  sum(se2se_ccu39(enty,enty2,te),
    p39_co2_dem(t,regi,enty,enty2,te)
  * vm_prodSe(t,regi,enty,enty2,te)
  )
  +
  sum(tePrc2matIn(tePrc,opmoPrc,mat)$(sameAs(mat,"co2f")),
    p37_specMatDem(mat,tePrc,opmoPrc)
  * vm_outflowPrc(t,regi,tePrc,opmoPrc)
  )

;

*' calculate v39_shSynLiq, share of synthetic (hydrogen-based) liquids in all SE liquids if cm_shSynLiq switch used
q39_shSynLiq(t,regi)$(cm_shSynLiq gt 0)..
    (
    sum(pe2se(entyPe,entySe,te)$seAgg2se("all_seliq",entySe), vm_prodSe(t,regi,entyPe,entySe,te))
    + sum(se2se(entySe,entySe2,te)$seAgg2se("all_seliq",entySe2), vm_prodSe(t,regi,entySe,entySe2,te))
    ) * v39_shSynLiq(t,regi)
    =e=
  sum(se2se(entySe,entySe2,te)$(sameAs(entySe, "seh2") AND
                                sameAs(entySe2, "seliqsyn") AND
                                te_ccu39(te)),
    vm_prodSe(t,regi,entySe,entySe2,te))
;

*' calculate v39_shSynGas, share of synthetic (hydrogen-based) gas in all SE gases if cm_shSynGas switch used
q39_shSynGas(t,regi)$(cm_shSynGas gt 0)..
    (
    sum(pe2se(entyPe,entySe,te)$seAgg2se("all_sega",entySe), vm_prodSe(t,regi,entyPe,entySe,te))
    + sum(se2se(entySe,entySe2,te)$seAgg2se("all_sega",entySe2), vm_prodSe(t,regi,entySe,entySe2,te))
    ) * v39_shSynGas(t,regi)
    =e=
  sum(se2se(entySe,entySe2,te)$(sameAs(entySe, "seh2") AND
                                sameAs(entySe2, "segasyn") AND
                                te_ccu39(te)),
    vm_prodSe(t,regi,entySe,entySe2,te))
;

*' @stop
*** EOF ./modules/39_CCU/on/equations.gms
