*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/globallyOptimal/presolve.gms
***update values for next iteration. For non-optimal regions, keep last iterations value

p22_deltacap0(ttot,regi,teLearn,rlf)$( (ttot.val ge 2005) and (pm_SolNonInfes(regi) eq 1)) = vm_deltaCap.l(ttot,regi,teLearn,rlf);

loop((ttot,regi,teLearn),
pm_capCumForeign(ttot,regi,teLearn)$(ttot.val ge 2005) = sum(regi2$(not sameas(regi2,regi)), pm_capCum0(ttot,regi2,teLearn) );  
);

display pm_capCumForeign;

* calculate marginal benefit of spillovers in each region. This expression for the subsidy can be derived analytically.
loop(regi$(pm_SolNonInfes(regi) eq 1),
    p22_marginalCapcumBenefit(ttot,regi,teLearn)  =  
	pm_ts(ttot)/2 * (abs(qm_deltaCapCumNet.m(ttot,regi,teLearn)) / max(abs(qm_budget.m(ttot,regi)),1E-9)) 
      + pm_ts(ttot)/2 * (abs(qm_deltaCapCumNet.m(ttot -1,regi,teLearn)) / max(abs(qm_budget.m(ttot,regi)),1E-9)) 

);                                              



*by default, update all techs in each iteration
m22_learnteUpdateSub(teLearn) = YES;
if(iteration.val gt 10,
*update spv and csp alternatingly to avoid oscillations (as they are very good substitutes)
if( m22_learnteUpdateSub("spv") and m22_learnteUpdateSub("csp"),
    m22_learnteUpdateSub("spv") = YES;
    m22_learnteUpdateSub("csp") = YES;
    if(mod(iteration.val,2) eq 1,  !!mod(iteration.val,2) eq 1
	m22_learnteUpdateSub("spv") = NO;
    else
	m22_learnteUpdateSub("csp") = NO;

    );
);
);



p22_subsidy_LI(ttot,regi,teLearn)$(ttot.val ge max(2010,cm_startyear)) = p22_subsidy(ttot,regi,teLearn);  !!save value from last iteration. 
p22_subsidyForeign_LI(ttot,regi,teLearn)$(ttot.val ge max(2010,cm_startyear)) = p22_subsidyForeign(ttot,regi,teLearn);  !!save value from last iteration. this is zero in first itr


*calculate the updated subsidy for all regions
loop(ttot$(ttot.val ge max(2020,cm_startyear) ),
    loop(regi,  !! This loop contains all regions 
	loop(m22_learnteUpdateSub,

	    p22_subsidyForeign(ttot,regi,m22_learnteUpdateSub) =
		sum(regi2$(NOT sameas(regi2,regi)), !!  each region regi internalizes the marginal value in all other regions
		    p22_marginalCapcumBenefit(ttot,regi2,m22_learnteUpdateSub)
		);
*Limit the change in the subsidy to prevent problems in convergence
	    if(p22_subsidyForeign_LI(ttot,regi,m22_learnteUpdateSub) eq 0, !! if in first iteration
		p22_subsidyForeign_LI(ttot,regi,m22_learnteUpdateSub) = 1E-2; !! give a starting value to get away from zero
	    );
	    if(iteration.val ge 1,
		p22_subsidyForeign(ttot,regi,m22_learnteUpdateSub) = min(0.95 * vm_costTeCapital.l(ttot,regi,m22_learnteUpdateSub),
		    min(max(-0.8 * sm_fadeoutPriceAnticip + 0.97,
			(p22_subsidyForeign(ttot,regi,m22_learnteUpdateSub)/max(p22_subsidyForeign_LI(ttot,regi,m22_learnteUpdateSub),1E-9))**(1/2)
		    ), 0.8 * sm_fadeoutPriceAnticip + 1.03)
		    * p22_subsidyForeign_LI(ttot,regi,m22_learnteUpdateSub)
		);  
		
	    );
*limit subsidy to not more than the difference from investcost to floor 		    
*		p22_subsidy(ttot,regi,teLearn) = min(p22_subsidy(ttot,regi,teLearn), vm_costTeCapital.L(ttot,regi,teLearn) - pm_data(regi,"floorcost",teLearn));
*		);

	);
    );
);


p22_subsidy(ttot,regi,teLearn) =  p22_subsidyForeign(ttot,regi,teLearn);


p22_subsidy("2015",regi,"storcsp") = 0;
p22_subsidy("2015",regi,"storspv") = 0;

display p22_subsidy;

*** EOF ./modules/22_subsidizeLearning/globallyOptimal/presolve.gms
