*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de


*** SOF ./modules/47_regipol/none/bounds.gms


*** region-specific bounds (with hard-coded regions)

*** further bounds for Germany
*** upper bound on capacity additions for 2025 based on near-term trends
*** for now only REMIND-EU/Germany, upper bound is double the historic maximum capacity addition in 2011-2020
loop(regi$(sameAs(regi,"DEU")),
  vm_deltaCap.up("2025",regi,"windon","1")=2*smax(tall$(tall.val ge 2011 and tall.val le 2020), pm_delta_histCap(tall,regi,"windon"));
  vm_deltaCap.up("2025",regi,"spv","1")=2*smax(tall$(tall.val ge 2011 and tall.val le 2020), pm_delta_histCap(tall,regi,"spv"));
);


*** only small amount of co2 injection ccs until 2030 in Germany
vm_co2CCS.up(t,regi,"cco2","ico2",te,rlf)$((t.val le 2030) AND (sameas(regi,"DEU"))) = 1e-3;
*** no Pe2Se fossil CCS in Germany, if c_noPeFosCCDeu = 1 chosen 
vm_emiTeDetail.up(t,regi,peFos,entySe,teFosCCS,"cco2")$((sameas(regi,"DEU")) AND (cm_noPeFosCCDeu = 1)) = 1e-4;
*** limit German CDR amount (Energy system BECCS, DACCS, EW and negative Landuse Change emissions), conversion from MtCO2 to GtC
vm_emiCdrAll.up(t,regi)$((cm_deuCDRmax ge 0) AND (sameas(regi,"DEU"))) = cm_deuCDRmax / 1000 / sm_c_2_co2;



*** adaptation of power system for Germany in early years  to prevent coal to gas switch in Germany due to coal-phase out policies
loop(regi$(sameAs(regi,"DEU")),
vm_deltaCap.up("2015",regi,"ngcc","1") = 0.002;
vm_deltaCap.up("2020",regi,"ngcc","1") = 0.0015;
vm_deltaCap.up("2025",regi,"ngcc","1") = 0.0015;
*** limit early retirement of coal power in Germany in 2020s to avoid extremly fast phase-out
vm_capEarlyReti.up('2025',regi,'pc') = 0.65; 
);

*' This bound avoids hydrogen production from gas in the European region (unlikely to happen after recent gas trade changes)
vm_deltaCap.up(t,regi,"gasftrec",rlf)$((t.val gt 2005) and (regi_group("EUR_regi",regi))) = 0;
vm_deltaCap.up(t,regi,"gasftcrec",rlf)$((t.val gt 2005) and (regi_group("EUR_regi",regi))) = 0;

*' TODO: Historical fixings should be done in the core the via input data from mrremind, this still needs to be moved
*** China-specific brownfield planning pipeline
*** This adjustment of coal capacity and vm_capFac is meant to give the PYPSA-coupled REMIND version a better starting point. Before turning this switch on in normal REMIND runs, double-check the electricity sector results that come out for China
$ifthen.chaCoalBounds not "%cm_chaCoalBounds%" == "off"
loop(regi$(sameAs(regi,"CHA")),
*** 2020 to 2025 bounds on annual addition and early retirement, splitting bounds for pc and coalchp with 78:22 ratio
*** 2024 capacity: 1175GW, added capactiy 30.5GW (https://globalenergymonitor.org/report/boom-and-bust-coal-2025/)
*** deltacap is annual added capacity between year x-1 and x; 78:22 ratio is based on pypsa data; deltacap is annual so divide by 5
*** expect 2025 capacity to be 1200GW, given 2020 capacity is 1100GW, deltacap in 2025 is derived to be 20GW/yr
vm_deltaCap.lo("2025",regi,"pc","1") = 20 * 0.78 / 1e3;
vm_deltaCap.lo("2025",regi,"coalchp","1") = 20 * 0.22 / 1e3;

*** 2025 to 2030 bounds on addition and early retirement, splitting bounds for pc and coalchp with 78:22 ratio amonng 20GW/yr (2030 1300GW: expert guess, GEM above source shows under construction is 200GW, preconstruction is also 200GW, so together this implementation presumes all under construction will be built, but non approved will be built by 2030)
vm_deltaCap.lo("2030",regi,"pc","1") = 20 * 0.78 / 1e3;
vm_deltaCap.lo("2030",regi,"coalchp","1") = 20 * 0.22 / 1e3;

*** lower capacity factor of coal power plants in China, to accomodate peaking with added capacities
*** current utilization rate is likely  3840hrs/yrs https://cgs.umd.edu/research-impact/publications/implications-continued-coal-builds-14th-five-year-plan-china-eng, correspond to 43.8%
*** by 2030 we expect the capacity factor to be 35% (expert guess)
vm_capFac.fx("2020",regi,"pc") = 0.54;
vm_capFac.fx("2025",regi,"pc") = 0.438;
vm_capFac.fx("2030",regi,"pc") = 0.35;

vm_capFac.fx("2020",regi,"coalchp") = 0.54;
vm_capFac.fx("2025",regi,"coalchp") = 0.438;
vm_capFac.fx("2030",regi,"coalchp") = 0.35;

);
$endif.chaCoalBounds

*** EOF ./modules/47_regipol/none/bounds.gms
