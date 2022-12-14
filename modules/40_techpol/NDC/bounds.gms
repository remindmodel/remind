*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NDC/bounds.gms

*AM the lowbound of solar and pv for 2030 to be taken from the NDCs (in GW), therefore multiplying by 0.001 for TW*
*** FS: activate capacity tarets only from 2025 on to be better in line with current trends
vm_cap.lo(t,regi,"spv","1")$(t.val ge 2025) = p40_TechBound(t,regi,"spv")*0.001;
vm_cap.lo(t,regi,"tnrs","1")$(t.val ge 2025) = p40_TechBound(t,regi,"tnrs")*0.001;
vm_cap.lo(t,regi_nucscen,"tnrs",rlf)$((t.val ge 2025) and (cm_nucscen eq 5)) = 0; !! we assume: Nucscen (limiting nuclear deployment) overrides NDC targets -> resetting lower bound to value defined at cm_nucscen switch
vm_cap.lo(t,regi,"hydro","1")$(t.val ge 2025) = p40_TechBound(t,regi,"hydro")*0.001;


*** FS: if cm_H2Targets on: include capacity targets for electrolysis following national Hydrogen Strategies
*** multiply by conversion efficiency as targets are given in GW(electricity) but GW(H2) needed
*** EU Hydrogen Strategy (2020): https://ec.europa.eu/energy/sites/ener/files/hydrogen_strategy.pdf
*** German Hydrogen Strategy (2020): https://www.bmwi.de/Redaktion/DE/Publikationen/Energie/die-nationale-wasserstoffstrategie.html
if(cm_H2targets eq 1,
  vm_cap.lo(t,regi,"elh2","1")$(t.val ge cm_startyear) = p40_TechBound(t,regi,"elh2")*0.001*pm_eta_conv(t,regi,"elh2");
);

$ifthen.complex_transport "%transport%" == "complex"

vm_cap.lo(t,regi,"apCarElT","1")$(t.val ge cm_startyear) = p40_TechBound(t,regi,"apCarElT");

*** additional target for electro mobility, overwriting the general bounds in 35_transport/complex/bounds.gms
*** requiring higher EV and FC vehicle shares, to mirror efficiency mandates and EV legislation in many countries
 loop(regi,
   loop(t$((t.val>2030) and (t.val ge cm_startyear)),
        vm_shUePeT.lo(t,regi,"apCarElT") = 10;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 3;

     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
        vm_shUePeT.lo(t,regi,"apCarElT") = 15;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 5;
     );
     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
        vm_shUePeT.lo(t,regi,"apCarElT") = 20;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 7;
     );
   );
   loop(t$(t.val>2050),
     vm_shUePeT.lo(t,regi,"apCarElT") = 20;
     vm_shUePeT.lo(t,regi,"apCarH2T") = 5;

     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
        vm_shUePeT.lo(t,regi,"apCarElT") = 20;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 8;
     );
     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
        vm_shUePeT.lo(t,regi,"apCarElT") = 25;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 10;
     );
   );
 );
$endif.complex_transport

display vm_cap.lo;

*** EOF ./modules/40_techpol/NDC/bounds.gms
