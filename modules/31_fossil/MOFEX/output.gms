*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/MOFEX/output.gms
*===========================================
* MODULE.....: 31 FOSSIL
* REALISATION: MOFEX
* FILE.......: output.gms
*===========================================
* Decription: This realisation activates time-dependent grade structures for
*   oil, gas and coal. This enables to take into account exogenous technological
*   change for example.
*===========================================
* Authors...: SB
* Wiki......: http://redmine.pik-potsdam.de/projects/remind-r/wiki/31_fossil
* History...:
*   - 2012-09-10 : Creation
*===========================================

*** Set trade, annual and cumulative extraction to MOFEX optimal values 
vm_fuExtr.l(ttot,regi,pe2rlf(peExGrade(enty),rlf))      = p31_MOFEX_fuelex_costMin(ttot,regi,enty,rlf);
v31_fuExtrCum.l(ttot,regi,pe2rlf(peExGrade(enty),rlf)) = p31_MOFEX_cumfex_costMin(ttot,regi,enty,rlf);
vm_Mport.l(ttot,regi,peExGrade(trade))                    = p31_MOFEX_Mport_costMin(ttot,regi,trade);
vm_Xport.l(ttot,regi,peExGrade(trade))                    = p31_MOFEX_Xport_costMin(ttot,regi,trade);

*** cumulated extraction:
pm_fuelex_cum(ttot,regi,peEx(enty),rlf) =
  v31_fuExtrCum.l(ttot-1,regi,enty,rlf)$(ttot.val ge 2015) + pm_ts(ttot)*vm_fuExtr.l(ttot,regi,enty,rlf);


* p31_costfu_detail(ttot,regi,enty) =
*   (p31_costExPoly(regi,"xi1",enty)
*   + (p31_costExPoly(regi,"xi2",enty)*pm_fuelex_cum(ttot,regi,enty,"1"))
*   + (p31_costExPoly(regi,"xi3",enty)*pm_fuelex_cum(ttot,regi,enty,"1")**2)
*   + (p31_costExPoly(regi,"xi4",enty)*pm_fuelex_cum(ttot,regi,enty,"1")**3))$peExPol(enty);


* *mh fuel costs (by region):
* file res_costfu_detail;
* put res_costfu_detail;
* loop(ttot,
*   loop(regi,
*     loop(peEx(enty),
*       put ttot.val:0:0,  @15, regi.tl, @30, enty.tl, @45, p31_costfu_detail(ttot,regi,enty):15:8 /;
* )));
* putclose res_costfu_detail;

* loop(ttot,
*   loop(regi,
*     loop(peExPol(enty),
*       p31_fuel_cost(ttot,regi,enty) =
*         (p31_costExPoly(regi,"xi1",enty)+p31_costExPoly(regi,"xi2",enty)*
*           ((sum(ttot2$(ttot2.val le ttot.val),
*             pm_ts(ttot2)*vm_fuExtr.l(ttot2,regi,enty,"1")+0.0001))/(p31_costExPoly(regi,"xi3",enty)+1.e-5)**
*             p31_costExPoly(regi,"xi4",enty)
*           )
*           *(
*             1$(ttot.val eq 2005) +
*             ((1-p31_fosadjco_xi5xi6(regi,"xi5",enty))
*              +
*              p31_fosadjco_xi5xi6(regi,"xi5",enty)
*              * ((vm_fuExtr.l(ttot,regi,enty,"1")+1.e-5)/(vm_fuExtr.l(ttot-1,regi,enty,"1")+1.e-5)))**p31_fosadjco_xi5xi6(regi,"xi6",enty)
*           )$(ttot.val ge 2010)
*         );

*         p31_fuel_cost_marg(ttot,regi,enty)  =         99; !! don't know how to calculate this at the moment '

*         p31_fuel_cost_noadj(ttot,regi,enty) =
*           (p31_costExPoly(regi,"xi1",enty)+p31_costExPoly(regi,"xi2",enty)*
*             ((sum(ttot2$(ttot2.val le ttot.val),pm_ts(ttot2)*vm_fuExtr.l(ttot2,regi,enty,"1")+0.0001))
*               /(p31_costExPoly(regi,"xi3",enty)+1.e-5)
*             ) ** p31_costExPoly(regi,"xi4",enty)
*           );
* )));

*LB save data for exogenous realization of the fossil module:
* file p31_fix_costfu_ex;
* put p31_fix_costfu_ex;
* loop(ttot$(ttot.val ge 2005),
*   loop(regi,
*     loop(peEx(enty),
*        put 'p31_fix_costfu_ex("'ttot.val:0:0'","'regi.tl:0:0'","'enty.tl:0:0'")=',vm_costFuEx.l(ttot,regi,enty):15:12, ';'; put /;
*     );
*   )
* );
* putclose p31_fix_costfu_ex;

* file p31_fix_fuelex;
* put p31_fix_fuelex;
* loop(ttot$(ttot.val ge 2005),
*   loop(regi,
*     loop(peEx(enty),
*       loop(rlf,
*           put 'p31_fix_fuelex("'ttot.val:0:0'","'regi.tl:0:0'","'enty.tl:0:0'","'rlf.tl:0:0'")=',vm_fuExtr.l(ttot,regi,enty,rlf):15:12, ';'; put /;
*       );
*     );
*   )
* );
* putclose p31_fix_fuelex;

*** EOF ./modules/31_fossil/MOFEX/output.gms
