*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/off/bounds.gms

*** Fix industry CCS to zero
loop (emiMac2mac(enty,emiInd37),
  vm_emiIndCCS.lo(ttot,regi,enty)$( ttot.val ge 2005 ) = 0;
);

*** Fix baseline emissions
loop ((secInd37,enty)$( NOT macBaseInd37(enty,secInd37) ),
  vm_macBaseInd.fx(ttot,regi,enty,secInd37)$( ttot.val ge 2005 ) = 0;
);

*** prevent negative CCS costs (loose end)
vm_IndCCSCost.lo(ttot,regi,emiInd37) = 0;

*** EOF ./modules/37_industry/off/bounds.gms

