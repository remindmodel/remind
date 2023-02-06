*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NDCplus/bounds.gms

*AM the lowbound of solar and pv for 2025 and 2030 to be taken from the NDCs (in GW), therefore multiplying by 0.001 for TW*
vm_cap.lo(t,regi,"spv","1")$(t.val lt 2031 AND t.val gt 2024) = p40_TechBound(t,regi,"spv")*0.001; 
vm_cap.lo(t,regi,"tnrs","1")$(t.val ge 2025) = p40_TechBound(t,regi,"tnrs")*0.001;
vm_cap.lo(t,regi_nucscen,"tnrs",rlf)$((t.val ge 2025) and (cm_nucscen eq 5)) = 0; !! we assume: Nucscen (limiting nuclear deployment) overrides NDC targets -> resetting lower bound to value defined at cm_nucscen switch
vm_cap.lo(t,regi,"hydro","1")$(t.val lt 2031 AND t.val gt 2024) = p40_TechBound(t,regi,"hydro")*0.001;


$ifthen.complex_transport "%transport%" == "complex"

vm_cap.lo(t,regi,"apCarElT","1")$(t.val lt 2041 AND t.val gt 2024) = p40_TechBound(t,regi,"apCarElT");

*** additional target for electro mobility, overwriting the general bounds in 35_transport/complex/bounds.gms
*** requiring higher EV and FC vehicle shares, to mirror efficiency mandates and EV legislation in many countries
***NDCplus variant with even higher mandates, roughly mirroring the EVmandates techpol realization
 loop(regi,
   loop(t$(t.val ge 2020),
        vm_shUePeT.lo(t,regi,"apCarElT") = 2;

     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
        vm_shUePeT.lo(t,regi,"apCarElT") = 5;
     );
     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
        vm_shUePeT.lo(t,regi,"apCarElT") = 8;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 0.4;
     );
   );
   loop(t$(t.val ge 2030),
        vm_shUePeT.lo(t,regi,"apCarElT") = 17;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 3;

     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
        vm_shUePeT.lo(t,regi,"apCarElT") = 25;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 7;
     );
     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
        vm_shUePeT.lo(t,regi,"apCarElT") = 28;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 10;
     );
   );
   loop(t$(t.val ge 2050),
     vm_shUePeT.lo(t,regi,"apCarElT") = 25;
     vm_shUePeT.lo(t,regi,"apCarH2T") = 20;

     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
        vm_shUePeT.lo(t,regi,"apCarElT") = 40;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 25;
     );
     if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
        vm_shUePeT.lo(t,regi,"apCarElT") = 45;
        vm_shUePeT.lo(t,regi,"apCarH2T") = 25;
     );
   );
 );
$endif.complex_transport

 display vm_cap.lo;
***NDCplus variant: additional bounds on nuclear policies:  no nuclear renaissance - no further ramping up of the industry, and focus on countries currently investing (mostly CHA, IND, RUS)
***nuclear yearly additions per year are max. 10% of total currently under construction and 2.5% of combined planned and proposed plants 
vm_deltaCap.up(t,regi,"tnrs","1")$(t.val gt 2030) = 0.1 * pm_NuclearConstraint("2020",regi,"tnrs") + 0.025 * (pm_NuclearConstraint("2025",regi,"tnrs")+pm_NuclearConstraint("2030",regi,"tnrs"));

***SR/BS/CB 2020-09-09
*** -----------------------------------------------------------------------------------------------------------------
*** Stringency of coal phase-out depends on GDP per capita, at least 80 and 90% for CHA and more rich, 80 and 50% for poorer countries
*** -----------------------------------------------------------------------------------------------------------------

loop(regi,
       if( ( pm_gdp("2010",regi)/pm_pop("2010",regi) ) > 3,
             vm_capEarlyReti.lo("2030",regi,te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")) = min(vm_capEarlyReti.l("2020",regi,te)+ 5 * pm_regiEarlyRetiRate("2020",regi,te) + 5 * pm_regiEarlyRetiRate("2025",regi,te) - 0.001, 0.9);
             vm_capEarlyReti.lo("2020",regi,te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")) = min(vm_capEarlyReti.l("2010",regi,te)+ 5 * pm_regiEarlyRetiRate("2010",regi,te) + 5 * pm_regiEarlyRetiRate("2015",regi,te) - 0.001, 0.8);
        else
             vm_capEarlyReti.lo("2030",regi,te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")) = min(vm_capEarlyReti.l("2020",regi,te)+ 5 * pm_regiEarlyRetiRate("2020",regi,te) + 5 * pm_regiEarlyRetiRate("2025",regi,te) - 0.001, 0.5);
             vm_capEarlyReti.lo("2020",regi,te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")) = min(vm_capEarlyReti.l("2010",regi,te)+ 5 * pm_regiEarlyRetiRate("2010",regi,te) + 5 * pm_regiEarlyRetiRate("2015",regi,te) - 0.001, 0.8);
          );
     );


*** EOF ./modules/40_techpol/NDCplus/bounds.gms
