*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/sets.gms
*LB*AJS*testOneRegi: restriction to one region    

sets
regi_dyn80(all_regi)  "region for testOneRegi"
;

regi_dyn80(all_regi) = NO;
regi_dyn80("%c_testOneRegi_region%") =YES;


*** EOF ./modules/80_optimization/testOneRegi/sets.gms
