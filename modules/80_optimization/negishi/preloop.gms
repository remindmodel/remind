*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi/preloop.gms
*AJS* load Negishi weights from gdx
Execute_Loadpoint 'input' pm_w = pm_w;



*AJS if we start from a gdx produced by nash, we dont find useful weights in the gdx(there are all equal one by definition). In that case, load marginal of budget equation and calculate Negishi weights from that
if(smax(regi,pm_w(regi)) eq 1,
display "Could not import Negishi weights pm_w from gdx. Falling back to calculating weights from marginals in the gdx.";
Execute_Loadpoint 'input' q80_budget_helper = qm_budget;
    loop(regi,
         pm_w(regi) = 1/max(abs(q80_budget_helper.m("2050",regi)),1E-9);
    );
***normalize sum to unity	
    pm_w(regi) = pm_w(regi) / sum(regi2, pm_w(regi2) );
);

display "negishi weights extracted from gdx are:"
OPTION decimals =6;
display pm_w;
OPTION decimals =3;

*AJS* Sanity check on Negishi weights: if not larger than 1E-3, smaller than 0.4, do not sum up to one -> abort
if( ( smin(regi,pm_w(regi)) lt 1E-3 ) or ( smax(regi,pm_w(regi)) gt 0.4 ) or (abs(sum(regi,pm_w(regi)) - 1 ) gt 0.01 ) ,
  execute_unload "abort.gdx";
  abort "The Negishi weights look shabby, I won't start a run from those. Please choose a better gdx.";
);


*AJS* The following line is needed to not break the calculation of p80_nw in postsolve.gms.
loop(regi,
    p80_nw("1",regi) = pm_w(regi);
);
*** EOF ./modules/80_optimization/negishi/preloop.gms

