*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi/output.gms
***----------------------------------------------------------------------------
*DK: negishi weights and defics
***----------------------------------------------------------------------------

file res_nwres_coupling /"./nwres_reg.rem.csv" /  ;
res_nwres_coupling.pc=5;
res_nwres_coupling.nd=10;
put res_nwres_coupling;
put "dummy";
loop(regi, put regi.tl);
loop(ttot,
   put / ttot.tl
   loop(regi, put pm_w(regi)));
putclose res_nwres_coupling;

*----------------------------------------------
*** 1) prices of traded commodities - normalized
*----------------------------------------------
file res_tradebal;
put res_tradebal;
loop(ttot,
loop(regi,
loop(trade,
put ttot.tl,@15,regi.tl,@30,trade.tl,@45,(q80_balTrade.m(ttot,trade)/(qm_budget.m(ttot,regi)+1.e-10)):15:8 /;
)));
putclose res_tradebal;

*----------------------------------------------
*** 1) prices of traded commodities
*----------------------------------------------
file res_tradebala;
put res_tradebala;
loop(ttot,
loop(regi,
loop(trade,
put ttot.tl,@15,regi.tl,@30,trade.tl,@45,q80_balTrade.m(ttot,trade):15:8 /;
)));
putclose res_tradebala;


file tau_polA;
put tau_polA;
    loop(ttot$(ttot.val ge cm_startyear),
         put 'pm_taxCO2eq("'ttot.te(ttot):0:0'")='(pm_pvp(ttot,"perm")/pm_pvp(ttot,"good")):12:8, ';'; put /;
    );
putclose tau_polA;

*LB* save prices and trade for Nash solution
file prices_NASH;
put prices_NASH;
loop(trade,
    loop(ttot,
         put 'pm_pvp("'ttot.te(ttot):0:0'","'trade.tl:0:0'")=' pm_pvp(ttot,trade):12:8, ';'; put /;
    );
);
putclose prices_NASH;

*** AG Reporting part
*** define trade = exports - imports
loop(trade,
 p80_tradeVolume(ttot,regi,trade) =
    (vm_Xport.l(ttot,regi,trade)$(ttot.val ge cm_startyear) - vm_Mport.l(ttot,regi,trade)) * abs(pm_pvp(ttot,trade) / (qm_budget.m(ttot,regi)/pm_ts(ttot)));
);

p80_tradeVolumeAll(ttot,regi) = sum(trade,p80_tradeVolume(ttot,regi,trade));
display p80_tradeVolumeAll;

*** EOF ./modules/80_optimization/negishi/output.gms
