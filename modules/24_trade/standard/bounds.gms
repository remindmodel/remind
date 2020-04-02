*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/standard/bounds.gms

*** set Mport and Xport positive
vm_Mport.lo(ttot,regi,tradePe)$(ttot.val ge 2005) = 0;
vm_Xport.lo(ttot,regi,tradePe)$(ttot.val ge 2005) = 0;



*** -----------------------------------------------------------
*** no permit trade allowed in BAU and tax scenarios:
*** -----------------------------------------------------------
if (cm_emiscen = 1 or cm_emiscen = 9,
   vm_Xport.fx(t,regi,"perm") = 0;
   vm_Mport.fx(t,regi,"perm") = 0;
else
   vm_Xport.fx("2005",regi,"perm") = 0;
   vm_Mport.fx("2005",regi,"perm") = 0;
   vm_Xport.fx("2010",regi,"perm") = 0;
   vm_Mport.fx("2010",regi,"perm") = 0;
);




*NB*110625 fix 2005 trade values to historic values
*RR*Added correction factor to match fossil supply and internal region energy demand in the initial year if necessary
*SB*190514 Made the correction factor for insufficient imports conditional on the fossil module realization

*** Mports fixing for fossils in the initial year 
loop( regi,
    loop (enty$peFos(enty),
*** if imports minus exports is higher than initial year demand there is a surplus of pe in the region. Correction -> set imports to 80% of the region pe demand plus Xports in the initial year
        if ( (pm_EN_demand_from_initialcap2(regi,enty) < (1-pm_costsPEtradeMp(regi,enty))*pm_IO_trade("2005",regi,enty,"Mport") -  pm_IO_trade("2005",regi,enty,"Xport")),     !!region has more available pe through trade than it needs
            p24_Mport2005correct(regi,enty) = (pm_EN_demand_from_initialcap2(regi,enty) + pm_IO_trade("2005",regi,enty,"Xport")) - pm_IO_trade("2005",regi,enty,"Mport");
        );
*** if internal region production (plus trade) is not enough to provide the energy demand. Correction ->  set imports to the difference between region energy demand (pm_EN_demand_from_initialcap2) and the internal production (pm_ffPolyCumEx(regi,enty,"max")) plus the trade balance (Mports-Xports) 
$iftheni.fossil_realization %cfg$gms$fossil% == "timeDepGrades"
        if ( pm_prodIni(regi,enty) + (1-pm_costsPEtradeMp(regi,enty))*(pm_IO_trade("2005",regi,enty,"Mport")+ p24_Mport2005correct(regi,enty)) -  pm_IO_trade("2005",regi,enty,"Xport") < pm_EN_demand_from_initialcap2(regi,enty),     !!region has a unbalance
            p24_Mport2005correct(regi,enty) = pm_EN_demand_from_initialcap2(regi,enty)  - ((1-pm_costsPEtradeMp(regi,enty))*pm_IO_trade("2005",regi,enty,"Mport") -  pm_IO_trade("2005",regi,enty,"Xport")) - pm_prodIni(regi,enty) ;  !! SB: use pm_prodIni as an analog for pm_ffPolyCumEx(regi,enty,"max"), which does not exist in timeDepGrades
        );
$elseifi.fossil_realization %cfg$gms$fossil% == "grades2poly"
        if ( (pm_ffPolyCumEx(regi,enty,"max") / (5*4)) + (1-pm_costsPEtradeMp(regi,enty))*(pm_IO_trade("2005",regi,enty,"Mport")+ p24_Mport2005correct(regi,enty)) -  pm_IO_trade("2005",regi,enty,"Xport") < pm_EN_demand_from_initialcap2(regi,enty),     !!region has a unbalance
            p24_Mport2005correct(regi,enty) = pm_EN_demand_from_initialcap2(regi,enty)  - ((1-pm_costsPEtradeMp(regi,enty))*pm_IO_trade("2005",regi,enty,"Mport") -  pm_IO_trade("2005",regi,enty,"Xport")) - pm_ffPolyCumEx(regi,enty,"max") / (5*4) ;  !!pm_ffPolyCumEx(regi,enty,"max") is a 5 years value, so we dived by 5 to get the annual value and additionally we assume that if all the extraction is made in the first years, this would take a t least 4 time steps to completely exhaust the resources 
        );
$endif.fossil_realization
    );
);
vm_Mport.fx(t0(tall),regi,peFos(enty)) = pm_IO_trade(t0,regi,enty,"Mport") + p24_Mport2005correct(regi,enty);

*** Xports fixing for fossils in the initial year (with added exports to compensate for the Mports corrections above)
loop( regi,
    loop (enty$peFos(enty),
        if ( (p24_Mport2005correct(regi,enty) = 0),
            vm_Xport.fx(t0(tall),regi,peFos(enty)) = pm_IO_trade(t0,regi,enty,"Xport") +
                   ( pm_IO_trade(t0,regi,enty,"Xport") / sum((regi2)$(NOT (p24_Mport2005correct(regi,enty))),pm_IO_trade(t0,regi2,enty,"Xport")) ) !! share of region Xports between regions with no balance problems
                   * sum((regi2),p24_Mport2005correct(regi2,enty)) !! total unbalance problem
            ;
        else
            vm_Xport.fx(t0(tall),regi,peFos(enty)) = pm_IO_trade(t0,regi,enty,"Xport") ;
        );
    );
); 

*** if region has no internal resources, demand must be entirely provided by trade (Switzerland problem). Correction ->  set imports free, exports zero. Warning: if the region is big enough this could cause a trade unbalance. The first best solution would be to calculate the exact imports amount needed and add extra exports to other countries to compensate for this exact amount.
loop( regi,
    loop (enty$peFos(enty),
$iftheni.timeDepGrades %cfg$gms$fossil% == "timeDepGrades"
        if ( (pm_fuelex_cum("2005",regi,enty,1) = 0),
            vm_Xport.fx(t0(tall),regi,peFos(enty)) = 0;
            vm_Mport.up(t0(tall),regi,peFos(enty)) = 1e10;
            vm_Mport.lo(t0(tall),regi,peFos(enty)) = 1e-6;
        );
$elseifi.timeDepGrades %cfg$gms$fossil% == "grades2poly"
        if ( (pm_ffPolyCumEx(regi,enty,"max") = 0),
            vm_Xport.fx(t0(tall),regi,peFos(enty)) = 0;
            vm_Mport.up(t0(tall),regi,peFos(enty)) = 1e10;
            vm_Mport.lo(t0(tall),regi,peFos(enty)) = 1e-6;
        );
$endif.timeDepGrades
    );
);

*** bounds on oil exports in 2010 and 2015
vm_Xport.lo("2010",regi,"peoil") = 0.95 * pm_IO_trade("2010",regi,"peoil","Xport");
vm_Xport.up("2010",regi,"peoil") = 1.05 * pm_IO_trade("2010",regi,"peoil","Xport");
vm_Xport.lo("2015",regi,"peoil") = 0.95 * pm_IO_trade("2015",regi,"peoil","Xport");
vm_Xport.up("2015",regi,"peoil") = 1.05 * pm_IO_trade("2015",regi,"peoil","Xport");

*** upper bounds ( 1% yearly growth rate) on all big oil exporters (more than 15EJ in 2010) in 2020, 2025 and 2030
loop(regi,
      if( (pm_IO_trade("2010",regi,"peoil","Xport") ge (15*sm_EJ_2_TWa)),
        vm_Xport.up("2020",regi,"peoil") = ((1 + 0.02) **  10) * pm_IO_trade("2010",regi,"peoil","Xport");
        vm_Xport.up("2025",regi,"peoil") = ((1 + 0.02) **  15) * pm_IO_trade("2010",regi,"peoil","Xport");
        vm_Xport.up("2030",regi,"peoil") = ((1 + 0.02) **  20) * pm_IO_trade("2010",regi,"peoil","Xport");
      );
);


*** EOF ./modules/24_trade/standard/bounds.gms