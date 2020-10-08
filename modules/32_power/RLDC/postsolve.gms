*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*------------------------------------------------------------------------------------
***                        RLDC post solve operations
*------------------------------------------------------------------------------------

***update parameter p32_avCapFac(ttot,all_regi,all_te) - average load factor (Nur) 
$ontext
loop(regi,
  loop(te$(teReNoBio(te)),
	p32_avCapFac(t,regi,te) = vm_capFac.l(t,regi,te) + v32_overProdCF.l(t,regi,te);
  );
);
$offtext

