*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF .modules/53_adaptation/ACCREU/postsolve.gms

pm_protectionLevelNonSLR(ttot,regi)$( (pm_SolNonInfes(regi) eq 1) ) =  v53_protectNonSLR.l(ttot,regi);
pm_protectionLevelSLR(ttot,regi)$( (pm_SolNonInfes(regi) eq 1) ) =  v53_protectSLR.l(ttot,regi);


*interpolate
loop(ttot$(ttot.val ge cm_startyear),
    loop(tall$(pm_tall_2_ttot(tall, ttot)),
        pm_protectionLevelNonSLR(tall,regi) =
       (1- pm_interpolWeight_ttot_tall(tall)) * pm_protectionLevelNonSLR(ttot,regi)
       + pm_interpolWeight_ttot_tall(tall) * pm_protectionLevelNonSLR(ttot+1,regi);
        pm_protectionLevelSLR(tall,regi) =
       (1- pm_interpolWeight_ttot_tall(tall)) * pm_protectionLevelSLR(ttot,regi)
       + pm_interpolWeight_ttot_tall(tall) * pm_protectionLevelSLR(ttot+1,regi);
));

*** assume protection level is constant from 2150 on (only enters damage calculations in the far future)
pm_protectionLevelNonSLR(tall,regi)$(tall.val ge 2150) = pm_protectionLevelNonSLR("2149",regi); 
pm_protectionLevelSLR(tall,regi)$(tall.val ge 2150) = pm_protectionLevelSLR("2149",regi); 


*** EOF .modules/53_adaptation/ACCREU/postsolve.gms
