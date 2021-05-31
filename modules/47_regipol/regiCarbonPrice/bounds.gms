*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/bounds.gms

** Force historical bounds on nuclear
vm_cap.fx("2015",regi,"tnrs","1")$((cm_startyear le 2015) and (sameas(regi,"DEU"))) = 10.8/1000; 
vm_cap.fx("2020",regi,"tnrs","1")$((cm_startyear le 2020) and (sameas(regi,"DEU"))) = 7.8/1000;

$IFTHEN.NucRegiPol not "%cm_NucRegiPol%" == "off" 

***Germany Nuclear phase-out
    vm_cap.up(t,regi,"tnrs","1")$((t.val ge 2025) and (t.val ge cm_startyear) and (sameas(regi,"DEU"))) = 1E-6;

*** ESC -> no new Nuclear capacity (Italy had a plebiscite for this and Greece should not have any new capacity)
    vm_deltaCap.up(t,regi,"tnrs","1")$((t.val ge 2020) and (t.val ge cm_startyear) and (sameas(regi,"ESC"))) = 0;

$ENDIF.NucRegiPol  

$IFTHEN.proNucRegiPol not "%cm_proNucRegiPol%" == "off" 
***Pro nuclear countries tend to keep nuclear production by political decision
***assuming France would keep at least 80% of its 2015 nuclear capacity in the future
vm_cap.lo(t,regi,"tnrs","1")$((t.val ge cm_startyear) and (sameas(regi,"FRA"))) = 0.8*pm_histCap("2015",regi,"tnrs");
***assuming Czech Republic would keep at least its 2015 nuclear capacity in the future (CZE corresponds to 61.8% of nuclear capacity of ECE in 2015)
vm_cap.lo(t,regi,"tnrs","1")$((t.val ge cm_startyear) and (sameas(regi,"ECE"))) = 0.618*pm_histCap("2015",regi,"tnrs");
***assuming Finland would keep at least its 2015 nuclear capacity in the future (FIN corresponds to 21.6% of nuclear capacity of ENC in 2015)
vm_cap.lo(t,regi,"tnrs","1")$((t.val ge cm_startyear) and (sameas(regi,"ENC"))) = 0.216*pm_histCap("2015",regi,"tnrs");
***assuming Romania would keep at least its 2015 nuclear capacity in the future (ROU corresponds to 22.1% of nuclear capacity of ECS in 2015)
vm_cap.lo(t,regi,"tnrs","1")$((t.val ge cm_startyear) and (sameas(regi,"ECS"))) = 0.221*pm_histCap("2015",regi,"tnrs");
$ENDIF.proNucRegiPol 

$IFTHEN.CCSinvestment not "%cm_CCSRegiPol%" == "off" 

* earliest investment in Europe, with one timestep split between countries currently exploring - Norway (NEN), Netherlands (EWN) and UK (UKI) - and others
vm_deltaCap.up(t,regi,teCCS,rlf)$( (t.val lt %cm_CCSRegiPol%) AND (sameas(regi,"NEN") OR sameas(regi,"EWN") OR sameas(regi,"UKI"))) = 1e-6; 
vm_deltaCap.up(t,regi,teCCS,rlf)$( (t.val le %cm_CCSRegiPol%) AND (regi_group("EUR_regi",regi)) AND (NOT(sameas(regi,"NEN") OR sameas(regi,"EWN") OR sameas(regi,"UKI")))) = 1e-6;

$ENDIF.CCSinvestment


** Force historical bounds on coal
vm_cap.up("2020",regi,"pc","1")$((cm_startyear le 2020) and (sameas(regi,"DEU"))) = 38.028/1000;
*** 2019 capacity = 7TWh, capacity factor = 0.6 ->  ~1.35GW -> Assuming no new capacity -> average 2018-2022 = ~ 1GW
vm_cap.up("2020",regi,"pc","1")$((cm_startyear le 2020) and (sameas(regi,"UKI"))) = 1.3/1000; 

** European regions coal capacity phase-out based on Beyond Coal 2021 (https://beyond-coal.eu/2021/03/03/overview-of-national-phase-out-announcements-march-2021/), whith adjustment for possible delay in Italy
$IFTHEN.CoalRegiPol not "%cm_CoalRegiPol%" == "off" 

    vm_cap.up(t,regi,te,"1")$((t.val ge 2025) and (t.val ge cm_startyear) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"ESW") or sameas(regi,"FRA") )) = 1E-6;
    vm_cap.up(t,regi,te,"1")$((t.val ge 2030) and (t.val ge cm_startyear) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"ENC") or sameas(regi,"ESC") or sameas(regi,"EWN") )) = 1E-6;

*** DEU coal capacity phase-out
    vm_cap.up("2025",regi,te,"1")$((cm_startyear le 2025) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"DEU"))) = 25.125/1000;
    vm_cap.up("2030",regi,te,"1")$((cm_startyear le 2020) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"DEU"))) = 16.7/1000;
    vm_cap.up("2035",regi,te,"1")$((cm_startyear le 2025) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"DEU"))) = 6.375/1000;
    vm_cap.up(t,regi,te,"1")$((t.val ge 2040) and (t.val ge cm_startyear) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"DEU"))) = 1E-6;

*** UK coal capacity phase-out
    vm_cap.up(t,regi,te,"1")$((t.val ge 2025) and (t.val ge cm_startyear) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"UKI"))) = 1E-6;

$ENDIF.CoalRegiPol  


*** EOF ./modules/47_regipol/regiCarbonPrice/bounds.gms
