*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms

loop ((ttot,steps)$( ttot.val ge 2005 ),

     pm_abatparam_Ind(ttot,regi,emiInd37,steps) = 0;
    
  );

*** EOF ./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms

