*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/globallyOptimal/postsolve.gms

p22_infoCapcumGlob2050(teLearn) = sum(regi,vm_capCum.l("2050",regi,teLearn));
display p22_infoCapcumGlob2050;




*save debug info per iteration
loop(ttot$(ttot.val gt cm_startyear),   
    loop(regi, 
	loop(teLearn,
	    	        p22_debugInfoMarginalCapcum(ttot,regi,teLearn,iteration) = qm_deltaCapCumNet.m(ttot,regi,teLearn);
	    	        p22_debugInfoMarginalBudget(ttot,regi,teLearn,iteration) = qm_budget.m(ttot,regi);

			p22_debugInfoSubsidy(ttot,regi,teLearn,iteration) = p22_subsidy(ttot,regi,teLearn);
			
			p22_debugInfoSubsidyCost(ttot,regi,teLearn,iteration) = vm_costSubsidizeLearning.l(ttot,regi);

			p22_debugInfoCapcum(ttot,regi,teLearn,iteration) = vm_capCum.L(ttot,regi,teLearn);
			p22_debugInfoCapcumForeign(ttot,regi,teLearn,iteration) = pm_capCumForeign(ttot,regi,teLearn);
			p22_debugInfoInvestcost(ttot,regi,teLearn,iteration)= vm_costTeCapital.l(ttot,regi,teLearn);

	);
    );
);
*** EOF ./modules/22_subsidizeLearning/globallyOptimal/postsolve.gms
