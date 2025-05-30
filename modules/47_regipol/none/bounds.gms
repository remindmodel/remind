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

*** China-specific brownfield planning pipeline 

$ifthen.chaCoalBounds not "%cm_chaCoalBounds%" == "off"
loop(regi$(sameAs(regi,"CHA")),
*** 2020 to 2025 bounds on annual addition and early retirement, splitting bounds for pc and coalchp with 78:22 ratio among 350GW addition over 5 years (2025 Q1 1451GW), deltacap(x) = added capacity between year x-1 and x; 78:22 ratio is based on pypsa data; deltacap is annual so divide by 5
vm_deltaCap.lo("2025",regi,"pc","1") = 70* 0.78 / 1e3;
vm_deltaCap.lo("2025",regi,"coalchp","1") = 70 * 0.22 / 1e3;

*** 2025 to 2030 bounds on addition and early retirement, splitting bounds for pc and coalchp with 78:22 ratio amonng 25GW (2030 1550GW) (expert guess)
vm_deltaCap.lo("2030",regi,"pc","1") = 25 * 0.78 / 1e3;
vm_deltaCap.lo("2030",regi,"coalchp","1") = 25 * 0.22 / 1e3;
);
$endif.chaCoalBounds

*** EOF ./modules/47_regipol/none/bounds.gms
