*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/IntC/presolve.gms


*** calculation of SE electricity price (useful for internal use and reporting purposes)
pm_SEPrice(t,regi,entySE)$(    abs(qm_budget.m(t,regi)) gt sm_eps
                           AND sameas(entySE,"seel") )
  = q32_balSe.m(t,regi,entySE)
  / qm_budget.m(t,regi);

if (cm_flex_tax eq 1,
  if (smin((t,regi)$( t.val ge 2025 ), pm_SEprice(t,regi,"seel")) lt 0,
    put logfile,
        "Negative seel prices with the potential to crash q32_flexAdj:" /;
    loop ((t,regi)$( pm_SEprice(t,regi,"seel") lt 0 AND t.val ge 2025 ),
      put pm_SEprice.tn(t,regi,"seel"), " = ", pm_SEprice(t,regi,"seel") /;
    );
  
    putclose " ", logfile /;
  
    execute_unload "abort.gdx";
    abort "negative seel prices that could crash q32_flexAdj";
  );
);

*** EOF ./modules/32_power/IntC/presolve.gms
