*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/preloop.gms
*MLB/AG* for Nash algorithm read initial price data from gdx
  Execute_Loadpoint 'input' pm_pvp      = pm_pvp;
  Execute_Loadpoint 'input' vm_Xport.l  = vm_Xport.l;
  Execute_Loadpoint 'input' vm_Mport.l  = vm_Mport.l;
  Execute_Loadpoint 'input' vm_cons.l   = vm_cons.l;
  Execute_Loadpoint 'input' vm_taxrev.l = vm_taxrev.l;
  Execute_Loadpoint 'input' vm_fuExtr.l = vm_fuExtr.l;
  Execute_Loadpoint 'input' vm_prodPe.l = vm_prodPe.l;


*AJS* initialize starting points for prices, trade volumes etc. from gdx.
***in order to read parameters like p80_priceXXX from a gdx, instead of only variables , we have to explicitly instruct gams to do so in the execute_loadpoint command in core/preloop.gms.
***the price paths are the trickiest part. Try to find p80_priceXXX prices in the gdx fist, if that fails, fallback to price path read from input/prices_NASH.inc
loop(ttot$(ttot.val ge 2005),
    loop(trade$(NOT tradeSe(trade)),
        if((pm_pvp(ttot,trade) eq NA) OR (pm_pvp(ttot,trade) lt 1E-12) OR (pm_pvp(ttot,trade) gt 0.1) ,
***in case we have not been able to read price paths from the gdx, or these price are zero (or eps),  fall back to price paths in file input/prices_NASH.inc:
            pm_pvp(ttot,trade) = p80_pvpFallback(ttot,trade);
            display 'Nash: Info: Could not load useful initial price from gdx, falling back to the one found in input/prices_NASH.inc. This should not be a problem, the runs can stil converge. ';
         );
***in case pm_pvp is not found in gdx:
        if(pm_pvp(ttot,trade) eq NA,
        pm_pvp(ttot,trade) = 0;
         );
        loop(regi,	    
         pm_Xport0(ttot,regi,trade)  = vm_Xport.l(ttot,regi,trade);
         p80_Mport0(ttot,regi,trade) = vm_Mport.l(ttot,regi,trade);
       
***in case xport/mport is not found in gdx:
        if(pm_Xport0(ttot,regi,trade) eq NA,
        pm_Xport0(ttot,regi,trade) = 0;
        vm_Xport.L(ttot,regi,trade) = 0;
             );
        if(p80_Mport0(ttot,regi,trade) eq NA,
        p80_Mport0(ttot,regi,trade) = 0;
        vm_Mport.L(ttot,regi,trade) = 0;
             );
        p80_normalize0(ttot,regi,"good")   = vm_cons.l(ttot,regi);
***        p80_normalize0(ttot,regi,"perm") = vm_cons.l(ttot,regi);  
                    p80_normalize0(ttot,regi,"perm")$(ttot.val ge 2005) = max(abs(pm_shPerm(ttot,regi) * pm_emicapglob(ttot)) , 1E-6);
        p80_normalize0(ttot,regi,tradePe) = 0.5 * (sum(rlf, vm_fuExtr.l(ttot,regi,tradePe,rlf)) + vm_prodPe.l(ttot,regi,tradePe));

p80_taxrev0(ttot,regi) = vm_taxrev.l(ttot,regi);

	       );
	   );
);


*** interpolation for full_TS
$ifthen.full_TS %cm_less_TS% == "off"
loop(t_interpolate,
  sm_tmp    = t_interpolate.val;
  s80_before = smax(t_input_gdx$( t_input_gdx.val lt sm_tmp ), t_input_gdx.val);
  s80_after  = smin(t_input_gdx$( t_input_gdx.val gt sm_tmp ), t_input_gdx.val);

  p80_t_interpolate(t_interpolate,t)$( t.val eq s80_before )
  = (s80_after - sm_tmp) / (s80_after - s80_before);

  p80_t_interpolate(t_interpolate,t)$( t.val eq s80_after )
  = (sm_tmp - s80_before) / (s80_after - s80_before);
);

Display "interpolate t:", t, t_input_gdx, t_interpolate, p80_t_interpolate;
Display pm_pvp;

pm_pvp(t_interpolate,trade)$(NOT tradeSe(trade))
= sum(t_input_gdx,
    pm_pvp(t_input_gdx,trade)
  * p80_t_interpolate(t_interpolate,t_input_gdx)
  );

pm_Xport0(t_interpolate,regi,trade)$(NOT tradeSe(trade))
= sum(t_input_gdx,
    pm_Xport0(t_input_gdx,regi,trade)
  * p80_t_interpolate(t_interpolate,t_input_gdx)
  );

p80_Mport0(t_interpolate,regi,trade)$(NOT tradeSe(trade))
= sum(t_input_gdx,
    p80_Mport0(t_input_gdx,regi,trade)
  * p80_t_interpolate(t_interpolate,t_input_gdx)
  );

vm_Xport.l(t_interpolate,regi,trade)$(NOT tradeSe(trade))
= sum(t_input_gdx,
    vm_Xport.l(t_input_gdx,regi,trade)
  * p80_t_interpolate(t_interpolate,t_input_gdx)
  );

vm_Mport.l(t_interpolate,regi,trade)$(NOT tradeSe(trade))
= sum(t_input_gdx,
    vm_Mport.l(t_input_gdx,regi,trade)
  * p80_t_interpolate(t_interpolate,t_input_gdx)
  );

p80_normalize0(t_interpolate,regi,trade)$(NOT tradeSe(trade))
= sum(t_input_gdx,
    p80_normalize0(t_input_gdx,regi,trade)
  * p80_t_interpolate(t_interpolate,t_input_gdx)
  );

Display "interpolation done:", pm_pvp, pm_Xport0, p80_Mport0, p80_normalize0;
$endif.full_TS

loop(regi,
    loop(tradePe,
if(p80_Mport0("2005",regi,tradePe) eq NA, p80_Mport0("2005",regi,tradePe) = 0);
););

*AJS* starting policy runs from permit prices that are all zero doesnot work. start from 30$ price path instead
if((cm_emiscen ne 1) and (cm_emiscen ne 9) and (smax(t,pm_pvp(t,"perm"))) eq 0,
 loop(ttot$(ttot.val ge 2005),
***this is a 30$/tCo2eq in 2020 trajectory:     
	pm_pvp(ttot,"perm") = 0.11*1.05**(ttot.val-2020) * pm_pvp(ttot,"good");
 );
 pm_pvp("2005","perm")=0;
);

if((cm_emiscen eq 1) or (cm_emiscen eq 9), !! if there is no period trade, set the price to zero.
    pm_pvp(ttot,"perm")=0;
);


p80_pvp_itr(ttot,trade,"1")$(NOT tradeSe(trade)) = pm_pvp(ttot,trade);

*AJS* Take care of resource prices that were imported as zero (as seen for 2150, peur), as they cause problems in the covergence process. Default to last periods price:
loop(tradePe,
    loop(ttot$(NOT sameas(ttot,'2005')),
	if(p80_pvp_itr(ttot,tradePe,"1") eq 0,
	    p80_pvp_itr(ttot,tradePe,"1") = p80_pvp_itr(ttot-1,tradePe,"1")$(NOT sameas(ttot,'2005'));
	    );
    );
);

***debug display
display pm_pvp,p80_normalize0;
display pm_Xport0,p80_Mport0;
display p80_surplusMaxTolerance;

*EMIOPT
$ifthen.emiopt %emicapregi% == 'none' 
if(cm_emiscen eq 6,
pm_budgetCO2eq(regi) = pm_shPerm("2050",regi) * sm_budgetCO2eqGlob;
display pm_shPerm, sm_budgetCO2eqGlob, pm_budgetCO2eq;
);
$endif.emiopt

*** EOF ./modules/80_optimization/nash/preloop.gms
