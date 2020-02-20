*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2018/bounds.gms 

*AM the lowbound of solar and pv for 2030 to be taken from the NDCs (in GW), therefore multiplying by 0.001 for TW*
vm_cap.lo(t,regi,"spv","1") = p40_TechBound(t,regi,"spv")*0.001; 
vm_cap.lo(t,regi,"wind","1") = p40_TechBound(t,regi,"wind")*0.001; 
vm_cap.lo(t,regi,"tnrs","1") = p40_TechBound(t,regi,"tnrs")*0.001;
vm_cap.lo(t,regi,"hydro","1") = p40_TechBound(t,regi,"hydro")*0.001;
vm_cap.lo(t,regi,"apCarElT","1") = p40_TechBound(t,regi,"apCarElT");

display vm_cap.lo;

$ifthen.complex_transport "%transport%" == "complex"
*** additional target for electro mobility, overwriting the general bounds in 35_transport/complex/bounds.gms
*** requiring higher EV and FC vehicle shares, to mirror efficiency mandates and EV legislation in many countries
 loop(regi,
   loop(t$(t.val>2030),
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

*** EOF ./modules/40_techpol/NPi2018/bounds.gms
