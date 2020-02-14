*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/bounds.gms

*** -------------------------------------------------------------------------------------------------------------
***LP* Narrowing down the solution space for vm_co2capture for CCU
*** -------------------------------------------------------------------------------------------------------------
vm_co2capture.fx(t,regi,"cco2","ico2","ccsinje","1") = 0;
vm_co2capture.up(t,regi,"cco2","ico2","ccsinje","1") = 50;

***Upper bound for ccu capacity increase (not exactly the same as in paper, but similar idea)
***"Assuming an average plant life time of 25 y (39), only 4% of existing production capacities are replaced annually."
***Kätelhön, Arne, Raoul Meys, Sarah Deutz, Sangwon Suh, and André Bardow. “Climate Change Mitigation Potential of Carbon Capture and Utilization in the Chemical Industry.” Proceedings of the National Academy of Sciences, May 13, 2019, 201821029. https://doi.org/10.1073/pnas.1821029116.
 
*** vm_deltaCap.up(t,regi,"h22ch4",rlf) =  0.04*vm_cap.l(t,regi,"h22ch4",rlf);
*** vm_deltaCap.up(t,regi,"MeOH",rlf)   =  0.04*vm_cap.l(t,regi,"MeOH",rlf);

***Upper bound for ccu capacity in the beginning to check for error in q80_costAdjNash
***didn't help....
*** vm_co2CCUshort.up("2005",regi,"cco2","ccuco2short","h22ch4","1")= 0;
*** vm_co2CCUshort.up("2010",regi,"cco2","ccuco2short","h22ch4","1")= 0;
*** vm_co2CCUshort.up("2015",regi,"cco2","ccuco2short","h22ch4","1")= 0;
*** vm_co2CCUshort.up("2020",regi,"cco2","ccuco2short","h22ch4","1")= 0;
*** vm_co2CCUshort.up("2025",regi,"cco2","ccuco2short","h22ch4","1")= 0;

*** vm_co2CCUshort.up("2030",regi,"cco2","ccuco2short","h22ch4","1")= 0.1;
*** vm_co2CCUshort.up("2035",regi,"cco2","ccuco2short","h22ch4","1")= 0.2;
*** vm_co2CCUshort.up("2040",regi,"cco2","ccuco2short","h22ch4","1")= 0.5;

***Lower bound on Secondary Gases production to force usage of Power-to-Gas [TWa]
***
*** vm_prodSe.lo("2060","CAZ",enty,"segafos",te) = 0.2;
*** vm_prodSe.lo("2060","CHA",enty,"segafos",te) = 1;
*** vm_prodSe.lo("2060","EUR",enty,"segafos",te) = 0.5;
*** vm_prodSe.lo("2060","IND",enty,"segafos",te) = 1;
*** vm_prodSe.lo("2060","JPN",enty,"segafos",te) = 0.05;
*** vm_prodSe.lo("2060","LAM",enty,"segafos",te) = 0.5;
*** vm_prodSe.lo("2060","MEA",enty,"segafos",te) = 1;
*** vm_prodSe.lo("2060","NEU",enty,"segafos",te) = 0.05;
*** vm_prodSe.lo("2060","OAS",enty,"segafos",te) = 1;
*** vm_prodSe.lo("2060","REF",enty,"segafos",te) = 0.3;
*** vm_prodSe.lo("2060","SSA",enty,"segafos",te) = 1;
*** vm_prodSe.lo("2060","USA",enty,"segafos",te) = 0.5;


*** EOF ./modules/39_CCU/39_CCU.gms
