*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/10_emissions/SectorAggregates/equations.gms

***-----------------------------------------------------------------------------
q10_emiTeDetail(t,regi,enty,enty2,te,enty3)$(emi2te(enty,enty2,te,enty3) OR (pe2se(enty,enty2,te) AND sameas(enty3,"cco2")) ) ..
  vm_emiTeDetail(t,regi,enty,enty2,te,enty3)
  =e=
  sum(emiMkt, vm_emiTeDetailMkt(t,regi,enty,enty2,te,enty3,emiMkt))
;

***--------------------------------------------------
*' Total energy-emissions:
***--------------------------------------------------
*** calculate total energy system emissions for each region and timestep:
q10_emiTe(t,regi,emiTe(enty))..
  vm_emiTe(t,regi,enty)
  =e=
  sum(emiMkt, vm_emiTeMkt(t,regi,enty,emiMkt))
;

***-----------------------------------------------------------------------------
*' Emissions per market
*' from primary to secondary energy transformation,
*' from secondary to final energy transformation (some air pollutants), or
*' transformations within the chain of CCS steps (Leakage).
***-----------------------------------------------------------------------------
q10_emiTeDetailMkt(t,regi,enty,enty2,te,enty3,emiMkt)$(
                           emi2te(enty,enty2,te,enty3)  !! emi2te = cco2.ico2.ccsinje.co2
                        OR (pe2se(enty,enty2,te) AND sameas(enty3,"cco2")) ) ..
  vm_emiTeDetailMkt(t,regi,enty,enty2,te,enty3,emiMkt)
  =e=
  sum(emi2te(enty,enty2,te,enty3),
    ( sum(pe2se(enty,enty2,te),
        pm_emifac(t,regi,enty,enty2,te,enty3)
      * vm_demPe(t,regi,enty,enty2,te)
      )
    + sum((ccs2Leak(enty,enty2,te,enty3),teCCS2rlf(te,rlf)), !! ccs2Leak = cco2.ico2.ccsinje.co2
        pm_emifac(t,regi,enty,enty2,te,enty3)
      * vm_co2CCS(t,regi,enty,enty2,te,rlf)
      )
    )$( sameas(emiMkt,"ETS") )
  + sum(se2fe(enty,enty2,te),
      pm_emifac(t,regi,enty,enty2,te,enty3)
    * sum(sector$(    entyFe2Sector(enty2,sector)
                  AND sector2emiMkt(sector,emiMkt) ),
        vm_demFeSector(t,regi,enty,enty2,sector,emiMkt)
        !! substract FE used for non-energy purposes (as feedstocks) so it does
        !! not create energy-related emissions
      - sum(entyFE2sector2emiMkt_NonEn(enty2,sector,emiMkt),
          vm_demFeNonEnergySector(t,regi,enty,enty2,sector,emiMkt))
      )
    )
  )
;

***--------------------------------------------------
*' energy emissions from fuel extraction
***--------------------------------------------------

q10_emiEnFuelEx(t,regi,emiTe(enty))..
  v10_emiEnFuelEx(t,regi,enty)
  =e=
***   emissions from non-conventional fuel extraction
	sum(emi2fuelMine(enty,enty2,rlf),
		  p10_cint(regi,enty,enty2,rlf)
		* vm_fuExtr(t,regi,enty2,rlf)
		)$( cm_cint_scen eq 1 )
***   emissions from conventional fuel extraction
	+ (sum(pe2rlf(enty3,rlf2),
      sum(enty2$(peFos(enty2)),
		    (pm_cintraw(enty2)
		     * pm_fuExtrOwnCons(regi, enty2, enty3)
		     * vm_fuExtr(t,regi,enty3,rlf2))$(pm_fuExtrOwnCons(regi, enty2, enty3) gt 0))))$(sameas("co2",enty))
;



***--------------------------------------------------
*' Total energy-emissions per emission market, region and timestep
***--------------------------------------------------
q10_emiTeMkt(t,regi,emiTe(enty),emiMkt) ..
  vm_emiTeMkt(t,regi,enty,emiMkt)
  =e=
    !! emissions from fuel combustion
    sum(emi2te(enty2,enty3,te,enty),
      vm_emiTeDetailMkt(t,regi,enty2,enty3,te,enty,emiMkt)
    )
    !! energy emissions fuel extraction
  + v10_emiEnFuelEx(t,regi,enty)$( sameas(emiMkt,"ETS") )
    !! CO2 captured from Industry sector energy consumption
    !! Needs to be subtracted as vm_emiTeDetailMkt assumes all fuel 
    !! is burned without capture (same for CDR sector, plastics, feedstocks)
  - sum(emiInd37_fuel,
      vm_emiIndCCS(t,regi,emiInd37_fuel)
    )$( sameas(enty,"co2") AND sameas(emiMkt,"ETS") )
    !! CO2 captured from CDR sector energy consumption (OAE and DAC)
  - sm_capture_rate_cdrmodule
  * sum(te_ccs33,
      vm_co2emi_cdrFE_beforeCapture(t, regi, te_ccs33)
  )$( sameas(enty,"co2") AND sameas(emiMkt,"ETS") )
    !! plastic waste incineration; net from positive (fossil non-ccs) and negative (bio/syn w/ CCS)
  + vm_wasteIncinerationEmiBalance(t,regi,enty,emiMkt)
    !! Valve from cco2 capture step, to mangage if capture capacity and CCU/CCS
    !! capacity don't have the same lifetime
  + vm_co2capturevalve(t,regi)$( sameas(enty,"co2") AND sameas(emiMkt,"ETS") )
    !! CO2 from short-term CCU (short term CCU co2 is emitted again in a time
    !! period shorter than 5 years)
  + sum(teCCU2rlf(te2,rlf),
      vm_co2CCUshort(t,regi,"cco2","ccuco2short",te2,rlf)
    )$( sameas(enty,"co2") AND sameas(emiMkt,"ETS") )
;

***--------------------------------------------------
*' Total emissions
***--------------------------------------------------
q10_emiAllMkt(t,regi,emi,emiMkt) ..
  vm_emiAllMkt(t,regi,emi,emiMkt)
  =e=
    vm_emiTeMkt(t,regi,emi,emiMkt)
    !! Non-energy sector emissions. Note: These are emissions from all MAC
    !! curves.  So, this includes fugitive emissions, which are sometimes also
    !! subsumed under the term energy emissions.
  + sum((emiMacSector2emiMac(emiMacSector,emiMac(emi)),
         macSector2emiMkt(emiMacSector,emiMkt)),
      vm_emiMacSector(t,regi,emiMacSector)
    )
    !! negative emissions from CDR module before re-release from CCU
  + vm_emiCdr(t,regi,emi)$( sameas(emi,"co2") AND sameas(emiMkt,"ETS") )
    !! emissions of carbon feedstocks contained in chemicals that are not energy-related,
    !! can be positive (fossil, emitted) or negative (non-fossil, stored in products)
  + vm_emiFeedstockNoEnergy(t,regi,emi,emiMkt)
;


***--------------------------------------------------
*' Sectoral energy-emissions used for taxation markup with cm_CO2TaxSectorMarkup
***--------------------------------------------------

*** CO2 emissions from (fossil) fuel combustion in buildings and transport (excl. bunker fuels)
q10_emiCO2Sector(t,regi,sector) $ (   sameAs(sector, "build")
                                 OR sameAs(sector, "trans"))..
  vm_emiCO2Sector(t,regi,sector)
  =e=
*** calculate direct CO2 emissions per end-use sector
    sum(se2fe(entySe,entyFe,te),
      sum(emiMkt$(sector2emiMkt(sector,emiMkt)),
        pm_emifac(t,regi,entySe,entyFe,te,"co2")
        * vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)
    )
  )
*** substract emissions of bunker fuels for transport sector
  - sum(se2fe(entySe,entyFe,te),
        pm_emifac(t,regi,entySe,entyFe,te,"co2")
        * vm_demFeSector(t,regi,entySe,entyFe,sector,"other")
  )$(sameAs(sector, "trans"))
;

***------------------------------------------------------
*' Mitigation options that are independent of energy consumption are represented
*' using marginal abatement cost (MAC) curves, which describe the
*' percentage of abated emissions as a function of the costs.
*' Baseline emissions are obtained by three different methods: by source (via emission factors),
*' by econometric estimate, and exogenous. Emissions are calculated as
*' baseline emissions times (1 - relative emission reduction).
*' If coupled to MAgPIE pm_macBaseMagpie contains all N2O landuse emissions including n2o from biomass production
*' and pm_PeProdEmifac(regi,"pebiolc","n2obio") is zero then. If running standalone
*' pm_macBaseMagpie does not include n2o from biomass but it is added here.
*' In case of CO2 from landuse (co2luc), emissions can be negative.
*' To treat these emissions in the same framework, we subtract the minimal emission level from
*' baseline emissions. This shift factor is then added again when calculating total emissions.
*' The endogenous baselines of non-energy emissions are calculated in the following equation:
***------------------------------------------------------
q10_macBase(t,regi,enty)$( emiFuEx(enty) OR sameas(enty,"n2ofertin") ) ..
  vm_macBase(t,regi,enty)
  =e=
    sum(emi2fuel(enty2,enty),
      pm_PeProdEmifac(regi,enty2,enty)
    * sum(pe2rlf(enty2,rlf), vm_fuExtr(t,regi,enty2,rlf))
    )$( emiFuEx(enty) )
  + ( pm_macBaseMagpie(t,regi,enty)
    + pm_PeProdEmifac(regi,"pebiolc","n2obio")
    * vm_fuExtr(t,regi,"pebiolc","1")
    )$( sameas(enty,"n2ofertin") )
;

***------------------------------------------------------
*' Total non-energy emissions:
***------------------------------------------------------
q10_emiMacSector(t,regi,emiMacSector(enty))..
  vm_emiMacSector(t,regi,enty)
  =e=

    ( vm_macBase(t,regi,enty)
    * sum(emiMac2mac(enty,enty2),
        1 - (pm_macSwitch(t,regi,enty) * pm_macAbatLev(t,regi,enty2))
      )
    )$( NOT sameas(enty,"co2cement_process") )
***   cement process emissions are accounted for in the industry module
  + ( vm_emiIndBase(t,regi,enty,"cement")
    - vm_emiIndCCS(t,regi,enty)
    )$( sameas(enty,"co2cement_process") )

   + pm_macPolCO2luc(t,regi)$( sameas(enty,"co2luc") )
;

q10_emiMac(t,regi,emiMac) ..
  vm_emiMac(t,regi,emiMac)
  =e=
  sum(emiMacSector2emiMac(emiMacSector,emiMac),
    vm_emiMacSector(t,regi,emiMacSector)
  )
;

***--------------------------------------------------
*' All CDR emissions summed up
***--------------------------------------------------
q10_emiCdrNovel(t,regi)..
  vm_emiCdrNovel(t,regi) !! positive value
  =e=  
  !! ---- gross non-industry CDR
  !! 1. directly geologically stored gross atmospheric removal from pe2se-BECCS + DACCS
  + ( !! pe2se-BECC 
      sum(emiBECCS2te(enty,enty2,te,enty3),vm_emiTeDetail(t,regi,enty,enty2,te,enty3)) !! positive value
        !! + gross DACC 
      - vm_emiCdrTeDetail(t, regi, "dac")) !! negative value
      !! scaled by the fraction that gets stored geologically
     *  v10_ccsShare(t,regi) 
  !! 2. gross CDR from Enhanced Weathering
  - vm_emiCdrTeDetail(t, regi, "weathering") !! negative value
  !! 3. gross ocean uptake from OAE (also excluding non-avoidable emi from calcination)
  - vm_emiCdrTeDetail(t, regi, "oae_ng")  !! negative value
  - vm_emiCdrTeDetail(t, regi, "oae_el")  !! negative value
  !! 4. energy-related CDR from CDR sector (from burning biogenic or synfuel + capture + storage)
  +  pm_emifac(t,regi,"segafos","fegas","tdfosgas","co2") * sm_capture_rate_cdrmodule
      * (vm_demFeSector_afterTax(t,regi,"segabio","fegas","cdr","ETS") !! FE biogas
          + vm_demFeSector_afterTax(t,regi,"segasyn","fegas","cdr","ETS")) !! FE syngas
      !! multiply with ccs share 
      * v10_ccsShare(t,regi) 
  !! 5. biochar CDR 
  -  sum(emiBiochar2te(enty,enty2,te,enty3),vm_emiTeDetail(t,regi,enty,enty2,te,enty3)) !! negative value

  !! ---- gross industry CDR
  !! 1. gross industry CCS-CDR  (from burning biogenic or synfuel + capturing + storing the co2)
  + sum(emiInd37$(not sameas(emiInd37,"co2cement_process")), 
      vm_emiIndCCS(t,regi,emiInd37) !! positive value
    !! multiply with bio/syn share from previous iteration (computationally too expensive to incl. in optimization)
    * pm_NonFos_IndCC_fraction0(t,regi, emiInd37))
    !! multiply with ccs share 
    * v10_ccsShare(t,regi) 
  !! 2. Feedstocks
  !! 2a) plastics CDR -- incinerated  waste that is captured + stored from  non-fossil feedstocks
  + sum(emiMkt, 
      vm_nonFosPlastic_incinCC(t,regi,emiMkt)  * v10_ccsShare(t,regi)) !! positive value
;

q10_emiCdrAll(t,regi)..
  vm_emiCdrAll(t,regi) 
  =e=
  vm_emiCdrNovel(t,regi)   
  !! ---- net LUC CDR
  !! 0.  net negative emissions from co2luc
  - p10_macBaseMagpieNegCo2(t,regi) !! negative value
  !! 2. Feedstocks
   !! 2b) plastics CDR -- landfilled waste from non-fossil feedstocks
  - sum((emi,emiMkt), 
      vm_emiNonFosNonIncineratedPlastics(t,regi,emi,emiMkt)) !! negative value
  !! 2c) non-plastics materials CDR -- bound carbon from non-fossil feedstocks 
  + vm_nonFosNonPlasticNonEmitted(t,regi) !! positive value
;

***------------------------------------------------------
*' Total regional emissions are computed as the sum of total emissions over all emission markets.
***------------------------------------------------------
q10_emiAll(t,regi,emi)..
  vm_emiAll(t,regi,emi)
  =e=
  sum(emiMkt, vm_emiAllMkt(t,regi,emi,emiMkt))
;

***------------------------------------------------------
*' Total regional emissions in CO2 equivalents that are part of the climate policy  are computed based on regional GHG
*' emissions from different sectors(energy system, non-energy system, exogenous, CDR technologies).
***------------------------------------------------------
*mlb 8/2010* extension for multigas accounting/trading
*cb only "static" equation to be active before cm_startyear, as multigasscen could be different from a scenario to another that is fixed on the first
  qm_co2eq(ttot,regi)$(ttot.val ge cm_startyear)..
         vm_co2eq(ttot,regi)
         =e=
         sum(emiMkt, vm_co2eqMkt(ttot,regi,emiMkt));

  q10_co2eqMkt(ttot,regi,emiMkt)$(ttot.val ge cm_startyear)..
  vm_co2eqMkt(ttot,regi,emiMkt)
  =e=
  vm_emiAllMkt(ttot,regi,"co2",emiMkt)
  + (sm_tgn_2_pgc   * vm_emiAllMkt(ttot,regi,"n2o",emiMkt) +
     sm_tgch4_2_pgc * vm_emiAllMkt(ttot,regi,"ch4",emiMkt)) $(cm_multigasscen eq 2 or cm_multigasscen eq 3)
  - vm_emiMacSector(ttot,regi,"co2luc") $((cm_multigasscen eq 3) AND (sameas(emiMkt,"other")));

***------------------------------------------------------
*' Total global emissions in CO2 equivalents that are part of the climate policy also take into account foreign emissions.
***------------------------------------------------------
*mlb 20140108* computation of global emissions (related to cap)
  q10_co2eqGlob(t) $(t.val > 2010)..
        vm_co2eqGlob(t) =e= sum(regi, vm_co2eq(t,regi) + pm_co2eqForeign(t,regi));

***------------------------------------
*' Linking GHG emissions to tradable emission permits.
***------------------------------------
*mh for each region and time step: emissions + permit trade balance < emission cap
q10_emiCap(t,regi) ..
                vm_co2eq(t,regi) + vm_Xport(t,regi,"perm") - vm_Mport(t,regi,"perm")
                =l= vm_perm(t,regi);


***--------------------------------------------------
*' Total GHG emissions excl. land-use change and excl. bunker emissions  (needed for NDC targets)
***--------------------------------------------------
q10_emiGHG_exclLULUCF_exclBunkers(t,regi)..
  vm_emiGHG_exclLULUCF_exclBunkers(t,regi)
  =e=
*** total GHG emissions excl. F-Gases, incl. bunkers, incl. LULUCF
  sum( emiMkt,
         vm_emiAllMkt(t,regi,"co2",emiMkt)
      +  vm_emiAllMkt(t,regi,"n2o",emiMkt) * sm_tgn_2_pgc
      +  vm_emiAllMkt(t,regi,"ch4",emiMkt) * sm_tgch4_2_pgc
    )
*** add F-Gases, convert from MtCO2eq/yr to GtC/yr
  + vm_emiFgas(t,regi,"emiFgasTotal") / sm_c_2_co2 / 1000
*** subtract bunker emissions
  - sum(se2fe(enty,enty2,te),
      pm_emifac(t,regi,enty,enty2,te,"co2")
      * vm_demFeSector(t,regi,enty,enty2,"trans","other") 
    )
*** substract LULUCF emissions
  - vm_emiMacSector(t,regi,"co2luc");
  

***-----------------------------------------------------------------
*** Budgets on GHG emissions (single or two subsequent time periods)
***-----------------------------------------------------------------

qm_co2eqCum(regi)..
    v10_co2eqCum(regi)
    =e=
    sum(ttot$(ttot.val lt sm_endBudgetCO2eq and ttot.val gt sm_t_start),
      pm_ts(ttot)
    * vm_co2eq(ttot,regi)
    )
    + sum(ttot$(ttot.val eq sm_endBudgetCO2eq or ttot.val eq sm_t_start),
      pm_ts(ttot)
    / 2
    * vm_co2eq(ttot,regi)
    )
;

q10_budgetCO2eqGlob$(cm_emiscen=6)..
   sum(regi, v10_co2eqCum(regi))
   =l=
   sum(regi, pm_budgetCO2eq(regi));


***---------------------------------------------------------------------------
*' Definition of carbon capture :
***---------------------------------------------------------------------------

***q10_balcapture(t,regi, enty,  enty2, te)
***q10_balcapture(t,regi,"cco2","ico2","ccsinjeon")

q10_balcapture(t,regi) ..
  vm_co2capture(t,regi)
  =e=
    !! carbon captured in energy sector
    sum(emi2te(enty3,enty4,te2,"cco2"),
      vm_emiTeDetail(t,regi,enty3,enty4,te2,"cco2")
    )
    !! carbon captured from CDR technologies in CDR module
  + sum(teCCS2rlf(te,rlf), vm_co2capture_cdr(t,regi,"cco2","ico2",te,rlf))
    !! carbon captured from industry
  + sum(emiInd37, vm_emiIndCCS(t,regi,emiInd37))
  + sum((sefe(entySe,entyFe),emiMkt)$(
                            entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ),
      vm_incinerationCCS(t,regi,entySe,entyFe,emiMkt)
    )
;

***---------------------------------------------------------------------------
*' Definition of splitting of captured CO2 to CCS, CCU and a valve (the valve
*' accounts for different lifetimes of capture, CCS and CCU technologies s.t.
*' extra capture capacities of CO2 capture can release CO2  directly to the
*' atmosphere)
***---------------------------------------------------------------------------
q10_balCCUvsCCS(t,regi) ..
  vm_co2capture(t,regi)
  =e=
    sum(teCCS2rlf(te,rlf), vm_co2CCS(t,regi,"cco2","ico2",te,rlf))
  + sum(teCCU2rlf(te,rlf), vm_co2CCUshort(t,regi,"cco2","ccuco2short",te,rlf))
  + vm_co2capturevalve(t,regi)
;

q10_ccsShare(t,regi) ..
  vm_co2capture(t,regi)  * 
  v10_ccsShare(t,regi) 
  =e=
  sum(teCCS2rlf(te, rlf), vm_co2CCS(t, regi, "cco2", "ico2", te, rlf))
;

***---------------------------------------------------------------------------
*' Definition of the CCS transformation chain:
*** EOF ./modules/10_emissions/SectorAggregates/equations.gms
