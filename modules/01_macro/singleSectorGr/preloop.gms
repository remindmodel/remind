*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr/preloop.gms

*** Calculate cummulative depreciation factors
loop ((t,counter),
if ( pm_dt(t) eq 2 * counter.val,
pm_cumDeprecFactor_old(t,regi,in)$(ppfKap(in) OR in_putty(in)) 
=   ((1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 )
      - (1 - pm_delta_kap(regi,in)) ** (pm_dt(t) ))
     /  pm_delta_kap(regi,in)
    ;

pm_cumDeprecFactor_new(t,regi,in)$(ppfKap(in) OR in_putty(in)) 
=   ( 1 
     - (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2)
      )
     /  pm_delta_kap(regi,in)
    ;

);
if ( pm_dt(t) eq (2 * counter.val -1),
pm_cumDeprecFactor_old(t,regi,in)$(ppfKap(in) OR in_putty(in)) 
=   ((1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 - 0.5)
      - (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)))
     /  pm_delta_kap(regi,in)
    - 1/2 * (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 - 0.5 ) 
    ;

pm_cumDeprecFactor_new(t,regi,in)$(ppfKap(in) OR in_putty(in)) 
=   ( 1 
     - (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 - 0.5 + 1)
      )
     /  pm_delta_kap(regi,in)
    - 1/2 * (1 - pm_delta_kap(regi,in)) ** (pm_dt(t)/2 - 0.5) 
    ;
    
);
); 
display "test Deprec", pm_cumDeprecFactor_new,pm_cumDeprecFactor_old;

*** EOF ./modules/01_macro/singleSectorGr/preloop.gms
