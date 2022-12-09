*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/bounds.gms

***---------------------------------------------------------------------------
*** region-specific bounds (with hard-coded regions)
***---------------------------------------------------------------------------

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

*** DEU coal-power capacity phase-out, upper bounds following the Kohleausstiegsgesetz from 2020
*** https://www.bmuv.de/themen/klimaschutz-anpassung/klimaschutz/nationale-klimapolitik/fragen-und-antworten-zum-kohleausstieg-in-deutschland
    vm_capTotal.up("2025",regi,"pecoal","seel")$(sameas(regi,"DEU"))=25/1000;
    vm_capTotal.up("2030",regi,"pecoal","seel")$(sameas(regi,"DEU"))=17/1000;
    vm_capTotal.up("2035",regi,"pecoal","seel")$(sameas(regi,"DEU"))=6/1000;
    vm_capTotal.up("2040",regi,"pecoal","seel")$(sameas(regi,"DEU"))=1E-6;
*** UK coal capacity phase-out
    vm_cap.up(t,regi,te,"1")$((t.val ge 2025) and (t.val ge cm_startyear) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"UKI"))) = 1E-6;

$ENDIF.CoalRegiPol  

*** further bounds for Germany
*** upper bound on capacity additions for 2025 based on near-term trends
*** for now only REMIND-EU/Germany, upper bound is double the historic maximum capacity addition in 2011-2020
loop(regi$(sameAs(regi,"DEU")),
  vm_deltaCap.up("2025",regi,"wind","1")=2*smax(tall$(tall.val ge 2011 and tall.val le 2020), pm_delta_histCap(tall,regi,"wind"));
  vm_deltaCap.up("2025",regi,"spv","1")=2*smax(tall$(tall.val ge 2011 and tall.val le 2020), pm_delta_histCap(tall,regi,"spv"));
);

*** bounds on historic gas capacities in Germany
vm_capTotal.up("2015",regi,"pegas","seel")$(sameas(regi,"DEU"))=30/1000;
vm_capTotal.up("2020",regi,"pegas","seel")$(sameas(regi,"DEU"))=34/1000;

*** limit coal-power capacity to at least 5 GW in 2030 to account for emissions from fossil waste (~20 MtCO2/yr as of 2020) in 2030 target as waste currently subsumed under coal-power in REMIND
vm_capTotal.lo("2030",regi,"pecoal","seel")$(sameas(regi,"DEU"))=5/1000;


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

*** energy security policy for Germany: 5GW(el) electrolysis installed by 2030 in Germany at minimum
$ifThen.ensec "%cm_Ger_Pol%" == "ensec"
    vm_cap.lo("2030",regi,"elh2","1")$(sameAs(regi,"DEU"))=5*pm_eta_conv("2030",regi,"elh2")/1000;
$endIf.ensec

***---------------------------------------------------------------------------
*** per region minimun variable renewables share in electricity:
***---------------------------------------------------------------------------
$ifthen.cm_VREminShare not "%cm_VREminShare%" == "off"
  loop((ttot,ext_regi)$(p47_VREminShare(ttot,ext_regi)),
    loop(regi$(regi_group(ext_regi,regi)),
      v47_VREshare.lo(t,regi)$(t.val ge ttot.val) = p47_VREminShare(t,ext_regi);
    )
  )
;
$endIf.cm_VREminShare
*** provide range for gas and coal power CF in EnSec scenario in 2025 and 2030 for subsitution
$ifThen.ensec "%cm_Ger_Pol%" == "ensec"
    vm_capFac.up("2025",regi,"pc")$sameas(regi,"DEU") = 0.6;
    vm_capFac.up("2030",regi,"pc")$sameas(regi,"DEU") = 0.6;

*** fix gas power to lower value in 2025 for short-term substitution
    vm_capFac.fx("2025",regi,"ngcc")$sameas(regi,"DEU") = 0.2;
    vm_capFac.lo("2030",regi,"ngcc")$sameas(regi,"DEU") = 0.2;
$endIf.ensec

*** PW: limit PE gas demand from 2025 on to cm_EnSecScen_limit EJ/yr gas imports + domestic gas in Germany
if (cm_EnSecScen_limit gt 0,
    vm_prodPe.up(t,regi,"pegas")$((t.val ge 2025) AND (sameas(regi,"DEU"))) = cm_EnSecScen_limit/pm_conv_TWa_EJ;
);

*** Fix CES function quantity trajectories to exogenous data if cm_exogDem_scen is activated
$ifthen.ExogDemScen NOT "%cm_exogDem_scen%" == "off"
vm_cesIO.fx(t,regi,in)$(pm_exogDemScen(t,regi,"%cm_exogDem_scen%",in))=pm_exogDemScen(t,regi,"%cm_exogDem_scen%",in);
$endif.ExogDemScen


*** EOF ./modules/47_regipol/regiCarbonPrice/bounds.gms
