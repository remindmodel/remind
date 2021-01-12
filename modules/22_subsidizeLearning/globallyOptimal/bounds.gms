*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/globallyOptimal/bounds.gms
*AJS without these fixings and lower bounds - which are harmless - the model will show oscillations of SPV installations over iterations. 
vm_deltaCap.fx("2010",regi,"storspv","1") = 0;
vm_deltaCap.fx("2010",regi,"storcsp","1") = 0;
vm_deltaCap.fx("2015",regi,"storspv","1") = 0;
vm_deltaCap.fx("2015",regi,"storcsp","1") = 0;

loop((ttot,regi,teLearn),
    vm_deltaCap.lo(ttot,regi,teLearn,"1")$(ttot.val ge max(2020,cm_startyear)) = 1e-7;  !! was -5
);


*** EOF ./modules/22_subsidizeLearning/globallyOptimal/bounds.gms
