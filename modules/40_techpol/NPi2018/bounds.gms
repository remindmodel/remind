*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2018/bounds.gms

*** AM the lowbound of solar and pv for 2030 to be taken from the NDCs (in GW), therefore multiplying by 0.001 for TW*
*** NPi bounds are only applied after 2020, as NPi scenarios should always have cm_startyear higher than 2020.
vm_cap.lo(t,regi,"spv","1")$(t.val gt 2020) = p40_TechBound(t,regi,"spv")*0.001; 
vm_cap.lo(t,regi,"tnrs","1")$(t.val ge 2025) = p40_TechBound(t,regi,"tnrs")*0.001;
vm_cap.lo(t,regi_nucscen,"tnrs",rlf)$((t.val ge 2025) and (cm_nucscen eq 5)) = 0; !! we assume: Nucscen (limiting nuclear deployment) overrides NDC targets -> resetting lower bound to value defined at cm_nucscen switch
vm_cap.lo(t,regi,"windon","1")$(t.val gt 2025) = p40_TechBound(t,regi,"windon")*0.001; 
vm_cap.lo(t,regi,"windoff","1")$(t.val gt 2025) = p40_TechBound(t,regi,"windoff")*0.001; 
*** Bound only applies from 2030 onward when technologies have historical values in 2025
vm_cap.lo(t,regi,"hydro","1")$(t.val >= 2030) = p40_TechBound(t,regi,"hydro")*0.001;

display vm_cap.lo;

*** EOF ./modules/40_techpol/NPi2018/bounds.gms
