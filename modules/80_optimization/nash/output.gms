*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/output.gms
*LB* save prices and trade for Nash solution.
*AJS* May  be used for updating start prices and trade volumes for Nash runs. (move to 80_optimization/nash/input folder)

file prices_NASH;
put prices_NASH;
put '*AJS* file was written by nash module, containing price paths. Nash runs dont depend on it. Copy to 80_optimization/nash/input/prices_NASH.inc in case you experience convergence problems though.';
put /;
loop(trade$(NOT tradeSe(trade)),
    loop(ttot$(ttot.val ge 2005),
         put 'p80_pvpFallback("'ttot.te(ttot):0:0'","'trade.tl:0:0'")=' pm_pvp(ttot,trade):12:8, ';'; put /;
    );
);
putclose prices_NASH;


*AJS* Write out debug info on price paths and surpluses for all iterations.
*** The file is formated in columns as follows: | Experiment title | Region | Year | Iteration | Market | surplus | price |  ..
file nash_info_convergence / "nash_info_convergence.csv" / ;
put nash_info_convergence;
put 'Scenario',',','Region',',','Year',',','Iteration',',',"Market",",","surplus",",","pvp_nash_itr",",","p80_surplusMax",",","p80_surplusMaxRel",",":0 ;
put /;
loop(ttot$(ttot.val ge 2005),
    loop(iteration$(iteration.val le cm_iteration_max),
	loop(trade$(NOT tradeSe(trade)),
	    put '%c_expname%',",";
	    put "glob",",";
	    put ttot.val:0:0,',';
	    put iteration.val:0:0,',';
	    put trade.tl,",";
	    put p80_surplus(ttot,trade,iteration):12:8,",";
	    put p80_pvp_itr(ttot,trade,iteration):12:8,"," ;
	    put p80_surplusMax(trade,iteration,ttot):12:8,",";
	    put p80_surplusMaxRel(trade,iteration,ttot):12:8,",";
	    put /;
	);
    );
  );
putclose nash_info_convergence;

*** EOF ./modules/80_optimization/nash/output.gms
