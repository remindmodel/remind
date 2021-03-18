*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/preloop.gms
*MLB/AG* for testOneRegi algorithm read initial price data from gdx
  Execute_Loadpoint 'input' pm_pvp      = pm_pvp;
  Execute_Loadpoint 'input' vm_Xport.l  = vm_Xport.l;
  Execute_Loadpoint 'input' vm_Mport.l  = vm_Mport.l;
  Execute_Loadpoint 'input' vm_cons.l   = vm_cons.l;
  Execute_Loadpoint 'input' vm_taxrev.l = vm_taxrev.l;
  Execute_Loadpoint 'input' vm_fuExtr.l = vm_fuExtr.l;
  Execute_Loadpoint 'input' vm_prodPe.l = vm_prodPe.l;
  Execute_Loadpoint 'input' pm_capCumForeign = pm_capCumForeign;


*AJS* initialize starting points for prices, trade volumes etc. from gdx.
***in order to read parameters like p80_priceXXX from a gdx, instead of only variables , we have to explicitly instruct gams to do so in the execute_loadpoint command in core/preloop.gms.
***the price paths are the trickiest part. Try to find p80_priceXXX prices in the gdx fist, if that fails, fallback to price path read from input/prices_NASH.inc
loop(ttot$(ttot.val ge 2005),
    loop(trade$(NOT tradeSe(trade)),
$ontext
        if((pm_pvp(ttot,trade) eq NA) OR (pm_pvp(ttot,trade) lt 1E-12) OR (pm_pvp(ttot,trade) gt 0.1) ,
***in case we have not been able to read price paths from the gdx, or these price are zero (or eps),  fall back to price paths in file input/prices_NASH.inc:
            pm_pvp(ttot,trade) = p80_pvpFallback(ttot,trade);
            display 'Nash: Info: Could not load useful initial price from gdx, falling back to the one found in input/prices_NASH.inc. This should not be a problem, the runs can stil converge. ';
         );
***in case pm_pvp is not found in gdx:
        if(pm_pvp(ttot,trade) eq NA,
        pm_pvp(ttot,trade) = 0;
         );
$offtext
        loop(regi,	    
         pm_Xport0(ttot,regi,trade)$(NOT tradeSe(trade))  = vm_Xport.l(ttot,regi,trade);
         p80_Mport0(ttot,regi,trade)$(NOT tradeSe(trade)) = vm_Mport.l(ttot,regi,trade);
       
***in case xport/mport is not found in gdx:
$ontext
        if(pm_Xport0(ttot,regi,trade) eq NA,
        pm_Xport0(ttot,regi,trade) = 0;
        vm_Xport.L(ttot,regi,trade) = 0;
             );
        if(p80_Mport0(ttot,regi,trade) eq NA,
        p80_Mport0(ttot,regi,trade) = 0;
        vm_Mport.L(ttot,regi,trade) = 0;
             );
$offtext

        p80_normalize0(ttot,regi,"good")   = vm_cons.l(ttot,regi);
***        p80_normalize0(ttot,regi,"perm") = vm_cons.l(ttot,regi);  
                    p80_normalize0(ttot,regi,"perm")$(ttot.val ge 2005) = max(abs(pm_shPerm(ttot,regi) * pm_emicapglob(ttot)) , 1E-6);
        p80_normalize0(ttot,regi,tradePe) =  0.5 * (sum(rlf,vm_fuExtr.l(ttot,regi,tradePe,rlf)) + vm_prodPe.l(ttot,regi,tradePe));

p80_taxrev0(ttot,regi) = vm_taxrev.l(ttot,regi);

	       );
	   );
);

display "info: starting from this price path";
display pm_pvp;


display regi;
*** EOF ./modules/80_optimization/testOneRegi/preloop.gms
