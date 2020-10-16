*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/sets.gms

sets
learnte_dyn80(all_te)   "learnte for nash"
/
        wind        "wind power converters"
        spv         "solar photovoltaic" 
        csp         "concentrating solar power"
        storspv     "storage technology for spv"
        storwind    "storage technology for wind"
        storcsp     "storage technology for csp"
        apCarElT
        apCarH2T
/,

solveinfo80	"Nash solution stats"
/
solvestat, modelstat, resusd, objval
/

convMessage80   "contains possible reasons for failed convergence"
/
infes,surplus,nonopt,taxconv,anticip
/
nash_sol_itr80  "nash iterations"
/
    1*10
/    
;

teLearn(learnte_dyn80)   = YES;


display teLearn;
*** EOF ./modules/80_optimization/nash/sets.gms
