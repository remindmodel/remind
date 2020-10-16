*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi/postsolve.gms


***   -------------------------------------------------------------------
***                  Negishi procedure
***   -------------------------------------------------------------------

pm_pvp(ttot,trade)$(ttot.val ge cm_startyear) = abs(q80_balTrade.m(ttot,trade))/(pm_ts(ttot) * pm_welf(ttot));

*-----------------------------------------------------------------------------------------------

p80_trade(ttot,regi,trade)$(ttot.val ge 2005) = vm_Xport.l(ttot,regi,trade)- vm_Mport.l(ttot,regi,trade);

*ML*2015-02-04* calculate current account
p80_curracc(ttot, regi) =  SUM(trade, pm_pvp(ttot,trade)/ max(pm_pvp(ttot,"good"),1.e-9) * (vm_Xport.l(ttot,regi,trade)- vm_Mport.l(ttot,regi,trade))  )
						   + pm_pvp(ttot,"good")/ max(pm_pvp(ttot,"good"),1.e-9) * pm_NXagr(ttot,regi);
*CB* for BaU runs, there is no policy cost, so currentaccounts cannot contribute to any consumption loss
if(cm_emiscen eq 1,
p80_currentaccount_bau(ttot,regi) = p80_curracc(ttot,regi);
);

*GL* calculate net foreign assets in current value prices
p80_nfa("2005",regi) = 0;
loop(ttot$(ttot.val gt 2005),
      p80_nfa (ttot,regi) =  p80_nfa(ttot-1,regi) * pm_pvp(ttot-1,"good") / max(pm_pvp(ttot,"good"),1.e-9)
                           + 0.5 * pm_ts(ttot-1) * p80_curracc(ttot-1,regi) * pm_pvp(ttot-1,"good") / max(pm_pvp(ttot,"good"),1.e-9)
                           + 0.5 * pm_ts(ttot) * p80_curracc(ttot,regi)
);

display p80_curracc, p80_nfa;
   
*GL* using old defic formulation to structural model change. In the future versions we should use 
***    defic(iteration,regi) = p80_nfa("2150",regi).  We also need to consider adjusting welfare function accordingly
*LB* what about taxrev?

p80_defic(iteration,regi) = 
          sum((ttot)$(ttot.val ge 2005), 
               pm_ts(ttot) * ( sum(trade, p80_trade(ttot,regi,trade) * pm_pvp(ttot,trade) )
               + (vm_taxrev.l(ttot,regi) * pm_pvp(ttot,"good"))$(ttot.val ge max(2010, cm_startyear))
			   + pm_pvp(ttot,"good") * pm_NXagr(ttot,regi)
		          )
              );

*MLB 11/2009 new negishi weight adjustment based on Gunnars reasoning
*** if you run a scenario with market imperfections you may activate the old adjustment procedure
p80_alpha_nw(ttot,regi)$(ttot.val ge 2005) = max(pm_pvp(ttot,"good"),1E-6)           !! prevent p80_alpha_nw from becoming EPS
                                            * exp((pm_ttot_val(ttot) - 2005) * pm_prtp(regi)) * vm_cons.l(ttot,regi)
                                            /(p80_nw(iteration,regi) * pm_pop(ttot,regi));

s80_alpha_avg =  sum(ttot$(ttot.val ge 2005), sum(regi, p80_alpha_nw(ttot,regi) * pm_ts(ttot) ) ) 
                                             /(card(ttot) - sum(ttot$(ttot.val le 2005),1))   !! number of time steps
                                             /card(regi);

if( ((o_modelstat eq 2) or (o_modelstat eq 7)),
          p80_nw(iteration+1,regi) = 
               max( 1.e-6, !! prevent negishi weights from becoming negative
                     p80_nw(iteration, regi) 
                  + (p80_defic(iteration,regi))
                  / ( s80_alpha_avg * (sum(ttot$(ttot.val ge 2005),exp(-(pm_ttot_val(ttot) - 2005) * pm_prtp(regi)) * (pm_pop(ttot,regi)))) )
                );
else
*GL: non-optimal or intermediately infeasible solution: keep old Negishi-Weight
          p80_nw(iteration+1,regi) = p80_nw(iteration, regi)
);

pm_w(regi) = p80_nw(iteration+1,regi) / sum(regi2, p80_nw(iteration+1,regi2) );
p80_nw(iteration+1,regi) = pm_w(regi);
p80_defic_sum(iteration+1) = sum(regi, abs(p80_defic(iteration,regi)));
p80_defic_sumLast = p80_defic_sum(iteration+1);

display p80_alpha_nw, s80_alpha_avg, pm_pvpRegi, pm_pvp, pm_w, p80_defic, p80_defic_sum, p80_defic_sumLast;
OPTION decimals =5;
display p80_nw;
OPTION decimals =3;

*** EOF ./modules/80_optimization/negishi/postsolve.gms
