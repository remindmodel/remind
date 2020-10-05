*** SOF ./modules/32_power/IntC/presolve.gms


*** FS: calculate electricity price of last iteration in trUSD2005/TWa
pm_priceSeel(t,regi)=q32_balSe.m(t,regi,"seel")/(qm_budget.m(t,regi)+sm_eps);

Display "electricity price", pm_priceSeel;

*** EOF ./modules/32_power/IntC/presolve.gms