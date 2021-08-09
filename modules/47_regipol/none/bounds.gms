*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
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
  vm_deltaCap.up("2025",regi,"wind","1")=2*smax(tall$(tall.val ge 2011 and tall.val le 2020), pm_delta_histCap(tall,regi,"wind"));
  vm_deltaCap.up("2025",regi,"spv","1")=2*smax(tall$(tall.val ge 2011 and tall.val le 2020), pm_delta_histCap(tall,regi,"spv"));
);


*** only small amount of co2 injection ccs until 2030 in Germany
vm_co2CCS.up(t,regi,"cco2","ico2",te,rlf)$((t.val le 2030) AND (sameas(regi,"DEU"))) = 1e-3;
*** no Pe2Se fossil CCS in Germany, if c_noPeFosCCDeu = 1 chosen 
vm_emiTeDetail.up(t,regi,peFos,entySe,teFosCCS,"cco2")$((sameas(regi,"DEU")) AND (cm_noPeFosCCDeu = 1)) = 1e-4;
*** limit German CDR amount (Energy system BECCS, DACCS, EW and negative Landuse Change emissions), conversion from MtCO2 to GtC
vm_emiCdrAll.up(t,regi)$((cm_deuCDRmax ge 0) AND (sameas(regi,"DEU"))) = cm_deuCDRmax / 1000 / sm_c_2_co2;

*** EOF ./modules/47_regipol/none/bounds.gms
