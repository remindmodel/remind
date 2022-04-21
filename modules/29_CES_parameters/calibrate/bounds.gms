*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/bounds.gms

vm_cesIO.fx(t0,regi_dyn29(regi),in_industry_dyn37(in))$( 
                                              NOT sameas(in,"en_otherInd_hth") )
  = pm_cesdata(t0,regi,in,"quantity");

*' Reduce the lower limit on the CES function to accommodate less utilised
*' production factors in (energetically) small regions.  (Example: gas heating
*' in Sub-Sahara Africa -- SSA/enhgab).
vm_cesIO.lo(t,regi_dyn29(regi),in)
  = min(
      vm_cesIO.lo(t,regi,in),
      ( pm_cesdata(t,regi,in,"quantiy")
      * 0.95
      ));

*** EOF ./modules/29_CES_parameters/calibrate/bounds.gms

