*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/globallyOptimal/equations.gms
q22_costSubsidizeLearning(ttot,regi)$(ttot.val ge max(2010,cm_startyear) )..
    vm_costSubsidizeLearning(ttot,regi)
    =e=
     v22_costSubsidizeLearningForeign(ttot,regi)
*       +   v22_costSubsidizeLearningOwn(ttot,regi)
;    


q22_costSubsidizeLearningForeign(ttot,regi)$(ttot.val ge max(2010,cm_startyear) )..
    v22_costSubsidizeLearningForeign(ttot,regi)
    =e=
    sum(teLearn,
	   p22_subsidyForeign(ttot,regi,teLearn) *  (vm_deltaCap(ttot,regi,teLearn,"1") - p22_deltacap0(ttot,regi,teLearn,"1")) !! only the first grade is meaningful
    )
;    
*** EOF ./modules/22_subsidizeLearning/globallyOptimal/equations.gms
