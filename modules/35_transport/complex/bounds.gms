*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/bounds.gms

vm_prodUe.fx("2005",regi,"fepet","uepet","apCarPeT") = pm_cesdata("2005",regi,"ueLDVt","quantity");

*BS* 2019-05-23 (merged from AD SDP-transport gitlab, changed SSP1 -> SDP)
*AD* 2019-04-11 let's be a little more ambitious with respect to electricity shares in SDP
$ifthen.cm_GDPScen %cm_GDPScen% == "gdp_SDP"

loop(regi,
  loop(t$(t.val>2020),
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
       vm_shUePeT.lo(t,regi,"apCarElT") = 0.5;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 0.1;
    );
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
       vm_shUePeT.lo(t,regi,"apCarElT") = 3;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 0.3;
    );
  );
  loop(t$(t.val>2030),
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
       vm_shUePeT.lo(t,regi,"apCarElT") = 2;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 0.3;
    );
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
       vm_shUePeT.lo(t,regi,"apCarElT") = 6;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 1;
    );
  );
  loop(t$(t.val>2050),
    vm_shUePeT.lo(t,regi,"apCarElT") = 3;
    vm_shUePeT.lo(t,regi,"apCarH2T") = 0.3;

    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
       vm_shUePeT.lo(t,regi,"apCarElT") = 6;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 1;
    );
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
       vm_shUePeT.lo(t,regi,"apCarElT") = 10;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 2;
    );
  );
  loop(t$(t.val>2070),
    vm_shUePeT.lo(t,regi,"apCarElT") = 10;
    vm_shUePeT.lo(t,regi,"apCarH2T") = 0.5;

    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
       vm_shUePeT.lo(t,regi,"apCarElT") = 15;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 2;
    );
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
       vm_shUePeT.lo(t,regi,"apCarElT") = 30;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 4;
    );
  );
);

$else.cm_GDPScen

*RP 2012-04-01 lower bounds on the share of electric and hydrogen cars so that the solver does not overlook these technologies.
*** The stated numbers are given in %.
loop(regi,
  loop(t$(t.val>2020),
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
       vm_shUePeT.lo(t,regi,"apCarElT") = 0.3;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 0.1;
    );
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
       vm_shUePeT.lo(t,regi,"apCarElT") = 1;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 0.3;
    );
  );
  loop(t$(t.val>2030),
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
       vm_shUePeT.lo(t,regi,"apCarElT") = 1;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 0.3;
    );
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
       vm_shUePeT.lo(t,regi,"apCarElT") = 3;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 1;
    );
  );
  loop(t$(t.val>2050),
    vm_shUePeT.lo(t,regi,"apCarElT") = 1;
    vm_shUePeT.lo(t,regi,"apCarH2T") = 0.3;

    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 15,
       vm_shUePeT.lo(t,regi,"apCarElT") = 3;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 1;
    );
    if( ( pm_gdp(t,regi)/pm_pop(t,regi) ) > 30,
       vm_shUePeT.lo(t,regi,"apCarElT") = 6;
       vm_shUePeT.lo(t,regi,"apCarH2T") = 2;
    );
  );
);


loop(t$(t.val>2080),
    vm_shUePeT.lo(t,regi,"apCarElT") = 10;
    vm_shUePeT.lo(t,regi,"apCarH2T") = 3;
);

vm_shUePeT.up(t,regi,"apCarElT") = 80;  !! limit electric vehicles to less than 70% market share of LDV (Uepet)
vm_shUePeT.up(t,regi,"apCarH2T") = 90;  !! limit hydrogen vehicles to less than 90% market share of LDV (Uepet)
vm_shUePeT.lo(t,regi,"apCarPeT") =  5;  !! require that ICE vehicles supply at least 10% market share of LDV (Uepet)

*** Limit phase-in of electric vehicles to historic values (1Mio cars = 	1/650 cap = 0.00154)
vm_cap.up("2010",regi,"apCarH2T","1") = 0;
vm_cap.up("2015",regi,"apCarH2T","1") = 0.0002;
vm_cap.up("2010",regi,"apCarElT","1") = pm_boundCapEV("2010",regi);
vm_cap.up("2015",regi,"apCarElT","1") = pm_boundCapEV("2015",regi) * 1.05;
vm_cap.lo("2015",regi,"apCarElT","1") = pm_boundCapEV("2015",regi) * 0.95;

*** prevent too early uptake due to high liquids prices in EUR etc.
vm_cap.up(t,regi,"apCarDiEffT","1")$(t.val < 2030) = 0.001;
vm_cap.up(t,regi,"apCarDiEffH2T","1")$(t.val < 2030) = 0.0001;

vm_cap.lo(t,regi,"apCarDiEffT","1")$(t.val > 2090) = 0.001;
vm_cap.lo(t,regi,"apCarDiEffH2T","1")$(t.val > 2090) = 0.001;

$endif.cm_GDPScen
*** EOF ./modules/35_transport/complex/bounds.gms
