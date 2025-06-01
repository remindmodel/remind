*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/bounds.gms

*' @code{extrapage: "00_model_assumptions"}

*' #### Model Bounds in Regipol Module (region-specific bounds with hard-coded regions)

*' These bounds are only active if in 47_regipol module the realization is regiCarbonPrice. They mostly refer 
*' to region-specific fixings of the model in European subregions to better represent historic or near-term values
*' or specific policies of regions (e.g. national coal phase-out plans etc.). 
*'
*' ##### Bounds for Germany
*'
*' ###### Bounds for Historic and Near-term Alignment

*' ####### Power Sector

$ifThen.tech_bounds_2025 "%cm_tech_bounds_2025%" == "on"
*' This limits wind and solar PV capacity additions for 2025 in light of recent slow developments as of 2023.
*' Upper bound is double the historic maximum capacity addition in 2011-2020.
*' In addition: Limit solar PV capacity to 120 GW in 2025 (2023-2027 average) given that we are at only 76 GW PV in 2023
loop(regi$(sameAs(regi,"DEU")),
  vm_deltaCap.up("2025",regi,"windon","1")=2*smax(tall$(tall.val ge 2011 and tall.val le 2020), pm_delta_histCap(tall,regi,"windon"));
  vm_deltaCap.up("2025",regi,"spv","1")=2*smax(tall$(tall.val ge 2011 and tall.val le 2020), pm_delta_histCap(tall,regi,"spv"));
  vm_cap.up("2025",regi,"spv","1")=0.12;
);
$endIf.tech_bounds_2025


*' These bounds account for historic gas power development.
*' TODO: Historical fixings should be done in the core the via input data from mrremind, this still needs to be moved
v47_prodSEtotal.up("2020",regi,"pegas","seel")$(sameAs(regi,"DEU"))= 0.36*sm_EJ_2_TWa;
$ifThen.tech_bounds_2025 "%cm_tech_bounds_2025%" == "on"
v47_prodSEtotal.up("2025",regi,"pegas","seel")$(sameAs(regi,"DEU"))= 0.4*sm_EJ_2_TWa;
$endIf.tech_bounds_2025

*' These bounds account for historic coal power development.
vm_cap.up("2020",regi,"pc","1")$((cm_startyear le 2020) and (sameas(regi,"DEU"))) = 38.028/1000;
*' This limits early retirement of coal power in Germany in 2020s to avoid extremly fast phase-out.
vm_capEarlyReti.up('2025',regi,'pc')$(sameAs(regi,"DEU")) = 0.65;


*' This aligns 2020 chp capcities for Germany with historic data (AGEB)
*' most of district heating is provided by CHP plants.
*' coal share of chp heat output to be between 20-25% of total district heating demand
*' gas share of chp heat output to be between 50-55% of total district heating demand
*' bio share of chp heat output to be between 15-25% of total district heating demand
*' TODO: Historical fixings should be done in the core via input data from mrremind, this still needs to be moved
loop(regi$(sameAs(regi,"DEU")),
    loop(t$(t.val eq 2020),
        vm_cap.lo(t,regi,"coalchp","1")= 0.2
*** total FE heat demand from industry and buildings calibration trajectories
                                            * (pm_cesdata(t,regi,"feheb","quantity")
                                                + pm_cesdata(t,regi,"feheb","quantity"))
*** divide by tdhes efficiency get from FE heat to SE heat, i.e. take into account heat transmission losses
                                            / pm_eta_conv(t,regi,"tdhes")
*** divide by pm_prodCouple to get from heat production to production of seel
                                            /  pm_prodCouple(regi,"pecoal","seel","coalchp","sehe")
*** divide by capacity factor to get from seel production in TWa to capacity in TW
                                            / pm_cf(t,regi,"coalchp");

        vm_cap.up(t,regi,"coalchp","1")= 0.25
*** total FE heat demand from industry and buildings calibration trajectories
                                            * (pm_cesdata(t,regi,"feheb","quantity")
                                                + pm_cesdata(t,regi,"feheb","quantity"))
*** divide by tdhes efficiency get from FE heat to SE heat, i.e. take into account heat transmission losses
                                            / pm_eta_conv(t,regi,"tdhes")
*** divide by pm_prodCouple to get from heat production to production of seel
                                            /  pm_prodCouple(regi,"pecoal","seel","coalchp","sehe")
*** divide by capacity factor to get from seel production in TWa to capacity in TW
                                            / pm_cf(t,regi,"coalchp");
        vm_cap.lo(t,regi,"gaschp","1")= 0.5
*** total FE heat demand from industry and buildings calibration trajectories
                                            * (pm_cesdata(t,regi,"feheb","quantity")
                                                + pm_cesdata(t,regi,"feheb","quantity"))
*** divide by tdhes efficiency get from FE heat to SE heat, i.e. take into account heat transmission losses
                                            / pm_eta_conv(t,regi,"tdhes")
*** divide by pm_prodCouple to get from heat production to production of seel
                                            /  pm_prodCouple(regi,"pegas","seel","gaschp","sehe")
*** divide by capacity factor to get from seel production in TWa to capacity in TW
                                            / pm_cf(t,regi,"gaschp");

        vm_cap.up(t,regi,"gaschp","1")= 0.55
*** total FE heat demand from industry and buildings calibration trajectories
                                            * (pm_cesdata(t,regi,"feheb","quantity")
                                                + pm_cesdata(t,regi,"feheb","quantity"))
*** divide by tdhes efficiency get from FE heat to SE heat, i.e. take into account heat transmission losses
                                            / pm_eta_conv(t,regi,"tdhes")
*** divide by pm_prodCouple to get from heat production to production of seel
                                            /  pm_prodCouple(regi,"pegas","seel","gaschp","sehe")
*** divide by capacity factor to get from seel production in TWa to capacity in TW
                                            / pm_cf(t,regi,"gaschp");

        vm_cap.lo(t,regi,"biochp","1")= 0.15
*** total FE heat demand from industry and buildings calibration trajectories
                                            * (pm_cesdata(t,regi,"feheb","quantity")
                                                + pm_cesdata(t,regi,"feheb","quantity"))
*** divide by tdhes efficiency get from FE heat to SE heat, i.e. take into account heat transmission losses
                                            / pm_eta_conv(t,regi,"tdhes")
*** divide by pm_prodCouple to get from heat production to production of seel
                                            /  pm_prodCouple(regi,"pebiolc","seel","biochp","sehe")
*** divide by capacity factor to get from seel production in TWa to capacity in TW
                                            / pm_cf(t,regi,"biochp");

        vm_cap.up(t,regi,"biochp","1")= 0.25
*** total FE heat demand from industry and buildings calibration trajectories
                                            * (pm_cesdata(t,regi,"feheb","quantity")
                                                + pm_cesdata(t,regi,"feheb","quantity"))
*** divide by tdhes efficiency get from FE heat to SE heat, i.e. take into account heat transmission losses
                                            / pm_eta_conv(t,regi,"tdhes")
*** divide by pm_prodCouple to get from heat production to production of seel
                                            /  pm_prodCouple(regi,"pebiolc","seel","biochp","sehe")
*** divide by capacity factor to get from seel production in TWa to capacity in TW
                                            / pm_cf(t,regi,"biochp");


    );
);

*' ####### Carbon Management

*' only start industry carbon capture in Germany by 2030 as status of projects for 2025 unclear,
*' see IEA CCUS database https://www.iea.org/data-and-statistics/data-tools/ccus-projects-explorer
vm_emiIndCCS.up(t,regi,emiInd37)$(sameAs(regi,"DEU") AND t.val lt 2030)=0;

*' ###### Bounds for Germany-specific Policies (activated by switches)

*' If c_noPeFosCCDeu = 1 chosen, fossil CCS for energy system technologies (pe2se) is forbidden.   
vm_emiTeDetail.up(t,regi,peFos,entySe,teFosCCS,"cco2")$((sameas(regi,"DEU")) AND (cm_noPeFosCCDeu = 1)) = 1e-4;

*' If cm_deuCDRmax >= 0, limit German CDR amount (Energy system BECCS, DACCS, EW and negative Landuse Change emissions) to cm_deuCDRmax.
*' Convert cm_deuCDRmax from MtCO2/yr to model unit of GtC/yr. 
vm_emiCdrAll.up(t,regi)$((cm_deuCDRmax ge 0) AND (sameas(regi,"DEU"))) = cm_deuCDRmax / 1000 / sm_c_2_co2;


*' Bounds for German Energy Security Scenario (activated by switches)

*' Background: The energy security scenario used for the Ariadne Report on energy sovereignity in 2022 assumes that there is a continued gas crisis after 2022/23 in Germany
*' with higher gas prices (see cm_EnSecScen_price) or limits to gas consumption (see cm_EnSecScen_limit switch) in the medium-term.
*' Moreover, this scenario is characterized by a more pronounced role of coal power in the short-term as well as a greater role of
*' industrial relocation and behavioral and energy efficiency transformations in demand sectors. Bounds in this section refer to energy supply technologies only. \ \

*' Policy in energy security scenario for Germany: 5GW(el) electrolysis installed by 2030 in Germany at minimum.
$ifThen.ensec "%cm_Ger_Pol%" == "ensec"
    vm_cap.lo("2030",regi,"elh2","1")$(sameAs(regi,"DEU"))=5*pm_eta_conv("2030",regi,"elh2")/1000;
$endIf.ensec

*' Policy in energy security scenario for Germany: increase coal power capacity factors and decrease gas power capacity factors until 2030
*' to account for short-term gas to coal switch under the assumption of a continued gas crisis.
$ifThen.ensec "%cm_Ger_Pol%" == "ensec"
    vm_capFac.up("2025",regi,"pc")$sameas(regi,"DEU") = 0.6;
    vm_capFac.up("2030",regi,"pc")$sameas(regi,"DEU") = 0.6;
    vm_capFac.fx("2025",regi,"ngcc")$sameas(regi,"DEU") = 0.2;
    vm_capFac.lo("2030",regi,"ngcc")$sameas(regi,"DEU") = 0.2;
$endIf.ensec

*' Policy in energy security scenario for Germany activated by cm_EnSecScen_limit: 
*' Limit PE gas demand from 2025 on to cm_EnSecScen_limit (in EJ/yr) gas imports + domestic gas in Germany.
if (cm_EnSecScen_limit gt 0,
    vm_prodPe.up(t,regi,"pegas")$((t.val ge 2025) AND (sameas(regi,"DEU"))) = cm_EnSecScen_limit/pm_conv_TWa_EJ;
);

*' ##### Bounds for EU subregions

*' ###### Bounds for historic and near-term Alignment

*' This account for historic coal power developments.
*' Bounds for UKI region: 2019 capacity = 7TWh, 
*' capacity factor = 0.6 ->  ~1.35GW -> Assuming no new capacity -> average 2018-2022 = ~ 1GW
vm_cap.up("2020",regi,"pc","1")$((cm_startyear le 2020) and (sameas(regi,"UKI"))) = 1.3/1000; 

*' ###### Bounds for EU-specific policies (activated by switches)

*' This accounts for different nuclear power policies that can be chosen for the EU subregions. 
*' Basic nuclear policies: 
$IFTHEN.NucRegiPol not "%cm_NucRegiPol%" == "off" 
*' Germany Nuclear phase-out
    vm_cap.up(t,regi,"tnrs","1")$((t.val ge 2025) and (t.val ge cm_startyear) and (sameas(regi,"DEU"))) = 1E-6;
*' ESC -> no new Nuclear capacity (Italy had a plebiscite for this and Greece should not have any new capacity)
    vm_deltaCap.up(t,regi,"tnrs","1")$((t.val ge 2020) and (t.val ge cm_startyear) and (sameas(regi,"ESC"))) = 0;
$ENDIF.NucRegiPol  

*' Extended nuclear policies:
$IFTHEN.proNucRegiPol not "%cm_proNucRegiPol%" == "off" 
*' Pro nuclear countries tend to keep nuclear production by political decision
*' assuming France would keep at least 80% of its 2015 nuclear capacity in the future.
vm_cap.lo(t,regi,"tnrs","1")$((t.val ge cm_startyear) and (sameas(regi,"FRA"))) = 0.8*pm_histCap("2015",regi,"tnrs");
*' Assuming Czech Republic would keep at least its 2015 nuclear capacity in the future (CZE corresponds to 61.8% of nuclear capacity of ECE in 2015)
vm_cap.lo(t,regi,"tnrs","1")$((t.val ge cm_startyear) and (sameas(regi,"ECE"))) = 0.618*pm_histCap("2015",regi,"tnrs");
*' Assuming Finland would keep at least its 2015 nuclear capacity in the future (FIN corresponds to 21.6% of nuclear capacity of ENC in 2015)
vm_cap.lo(t,regi,"tnrs","1")$((t.val ge cm_startyear) and (sameas(regi,"ENC"))) = 0.216*pm_histCap("2015",regi,"tnrs");
*' Assuming Romania would keep at least its 2015 nuclear capacity in the future (ROU corresponds to 22.1% of nuclear capacity of ECS in 2015)
vm_cap.lo(t,regi,"tnrs","1")$((t.val ge cm_startyear) and (sameas(regi,"ECS"))) = 0.221*pm_histCap("2015",regi,"tnrs");
$ENDIF.proNucRegiPol 

*' This accounts for different CCS policies that can be chosen for the EU subregions.
$IFTHEN.CCSinvestment not "%cm_CCSRegiPol%" == "off" 
*' earliest investment in Europe, with one timestep split between countries currently exploring - Norway (NEN), Netherlands (EWN) and UK (UKI) - and others
vm_deltaCap.up(t,regi,teCCS,rlf)$( (t.val lt %cm_CCSRegiPol%) AND (sameas(regi,"NEN") OR sameas(regi,"EWN") OR sameas(regi,"UKI"))) = 1e-6; 
vm_deltaCap.up(t,regi,teCCS,rlf)$( (t.val le %cm_CCSRegiPol%) AND (regi_group("EUR_regi",regi)) AND (NOT(sameas(regi,"NEN") OR sameas(regi,"EWN") OR sameas(regi,"UKI")))) = 1e-6;
$ENDIF.CCSinvestment

*' This accounts for different coal power phase-out policies that can be chosen for the EU subregions. 
*' It is based on Beyond Coal 2021 (https://beyond-coal.eu/2021/03/03/overview-of-national-phase-out-announcements-march-2021/), whith adjustment for possible delay in Italy.
$IFTHEN.CoalRegiPol not "%cm_CoalRegiPol%" == "off" 
    vm_cap.up(t,regi,te,"1")$((t.val ge 2025) and (t.val ge cm_startyear) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"ESW") or sameas(regi,"FRA") )) = 1E-6;
    vm_cap.up(t,regi,te,"1")$((t.val ge 2030) and (t.val ge cm_startyear) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"ENC") or sameas(regi,"ESC") or sameas(regi,"EWN") )) = 1E-6;

*' DEU coal-power capacity phase-out, upper bounds following the Kohleausstiegsgesetz from 2020.
*' https://www.bmuv.de/themen/klimaschutz-anpassung/klimaschutz/nationale-klimapolitik/fragen-und-antworten-zum-kohleausstieg-in-deutschland
    vm_capTotal.up("2025",regi,"pecoal","seel")$(sameas(regi,"DEU"))=25/1000;
    vm_capTotal.up("2030",regi,"pecoal","seel")$(sameas(regi,"DEU"))=17/1000;
    vm_capTotal.up("2035",regi,"pecoal","seel")$(sameas(regi,"DEU"))=6/1000;
    vm_capTotal.up("2040",regi,"pecoal","seel")$(sameas(regi,"DEU"))=1E-6;
*' UK coal capacity phase-out
    vm_cap.up(t,regi,te,"1")$((t.val ge 2025) and (t.val ge cm_startyear) and (sameas(te,"igcc") or sameas(te,"pc") or sameas(te,"coalchp")) and (sameas(regi,"UKI"))) = 1E-6;

$ENDIF.CoalRegiPol  


*' Represent region-specific renewable power policies with minimum VRE shares over time. 
$ifthen.cm_VREminShare not "%cm_VREminShare%" == "off"
  loop((ttot,ext_regi)$(p47_VREminShare(ttot,ext_regi)),
    loop(regi$(regi_group(ext_regi,regi)),
      v47_VREshare.lo(t,regi)$(t.val ge ttot.val) = p47_VREminShare(t,ext_regi);
    )
  )
;
$endIf.cm_VREminShare

*' This bounds fixes CES function quantity trajectories to exogenous data if cm_exogDem_scen is activated.
*' It is used, for example, to hit specific, steel and cement production trajectories in policy scenarios
*' for project-specific scenarios. It is not necessarily a policy but a different (exogenuous) assumption 
*' about future production trajectories than what REMIND produces endogenuously. 
$ifthen.exogDemScen NOT "%cm_exogDem_scen%" == "off"
vm_cesIO.fx(t,regi,in)$(pm_exogDemScen(t,regi,"%cm_exogDem_scen%",in))=pm_exogDemScen(t,regi,"%cm_exogDem_scen%",in);
$endif.exogDemScen

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

*** lower capacity factor of coal power plants in China, to accomodate peaking with added capacities
vm_capFac.fx("2020",regi,"pc") = 0.54;
vm_capFac.fx("2025",regi,"pc") = 0.45;
vm_capFac.fx("2030",regi,"pc") = 0.35;

vm_capFac.fx("2020",regi,"coalchp") = 0.54;
vm_capFac.fx("2025",regi,"coalchp") = 0.45;
vm_capFac.fx("2030",regi,"coalchp") = 0.35;

);
$endif.chaCoalBounds

*' @stop

*** EOF ./modules/47_regipol/regiCarbonPrice/bounds.gms
