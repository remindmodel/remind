*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_putty/postsolve.gms
***Update final energy prices. (if marginal of budget is greater than eps, which happens in case of 4-7)
p36_fePrice(t,regi_dyn36(regi),entyFe)$(abs (qm_budget.m(t,regi)) gt sm_eps) = abs ( qm_balFeForCesAndEs.m(t,regi,entyFe)) / abs (qm_budget.m(t,regi));

p36_fePrice_iter(iteration,t,regi_dyn36(regi),entyFe) $ p36_fePrice(t,regi,entyFe) = p36_fePrice(t,regi,entyFe);

*** To compute the capital price, take the CES derivative and substract the depreciation rate
loop(cesOut2cesIn(out,in) $ (sameAs(out,"inco")
                              AND sameAs(in,"kap")),
p36_kapPrice(t,regi_dyn36(regi)) =   
    pm_cesdata(t,regi,in,"xi")
  * pm_cesdata(t,regi,in,"eff")
  * vm_effGr.l(t,regi,in)
  
  * (vm_cesIO.l(t,regi,out)
       + vm_cesIOdelta.l(t,regi,out)$( ipf_putty(out))
     )
 ** (1 - pm_cesdata(t,regi,out,"rho"))

  * ( pm_cesdata(t,regi,in,"eff")
    * vm_effGr.l(t,regi,in)
    * (vm_cesIO.l(t,regi,in)$( NOT ipf_putty(out))
       + vm_cesIOdelta.l(t,regi,in)$( ipf_putty(out))
       )
    )
 ** (pm_cesdata(t,regi,out,"rho") - 1)
                        
    - pm_delta_kap(regi,"kap");
);    


p36_demUEtotal(t,regi_dyn36(regi),in)$(p36_demUEtotal(t,regi,in) AND ( NOT t36_hist(t))) = vm_cesIO.L(t,regi,in) + pm_cesdata(t,regi,in,"offset_quantity") ;


*** EOF ./modules/36_buildings/services_putty/postsolve.gms
