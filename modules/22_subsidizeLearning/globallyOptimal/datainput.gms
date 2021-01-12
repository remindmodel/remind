*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/22_subsidizeLearning/globallyOptimal/datainput.gms

p22_subsidy(ttot,regi,teLearn) = 0;
p22_subsidyForeign(ttot,regi,teLearn) = 0;
p22_marginalCapcumBenefit(ttot,regi,teLearn) = 0;
p22_deltacap0(ttot,regi,teLearn,rlf) = 0;


qm_deltaCapCumNet.m(ttot,regi,teLearn)=0;
qm_budget.m(ttot,regi)=0;



*** EOF ./modules/22_subsidizeLearning/globallyOptimal/datainput.gms
