*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/bounds.gms
*** -----------------------------------------------------------
*** setting bounds
*** -----------------------------------------------------------

*RP 20160126 set vm_costTeCapital to pm_inco0_t for all technologies that are non-learning
vm_costTeCapital.fx(ttot,regi,teNoLearn)  = pm_inco0_t("2005",regi,teNoLearn);  !! use 2005 value for the past
vm_costTeCapital.fx(t,regi,teNoLearn)     = pm_inco0_t(t,regi,teNoLearn);

*** ----------------------------------------------------------------------------------------------------------------------------------------
*** CB 20120402 Set lower bounds on variables to prevent the problem that the conopt solver often doesn't see a benefit from changing variable value away from 0
*** These lower bounds are set so low that they do not restrict the results
*** ----------------------------------------------------------------------------------------------------------------------------------------

*** CB 20120402 Lower limit on all P2SE technologies capacities to 100 kW of all technologies and all time steps
loop(pe2se(enty,enty2,te)$((not sameas(te,"biotr"))  AND (not sameas(te,"biodiesel")) AND (not sameas(te,"bioeths")) AND (not sameas(te,"gasftcrec")) AND (not sameas(te,"gasftrec"))
AND (not sameas(te,"tnrs"))),
  vm_cap.lo(t,regi,te,"1")$(t.val gt 2021 AND t.val lt 2100) = 1e-7;
);


*** RP 20160405 make sure that the model also sees the se2se technologies (seel <--> seh2)
loop(se2se(enty,enty2,te),
  vm_cap.lo(t,regi,te,"1")$(t.val gt 2025) = 1e-7;
);

*RP* Lower bound of 10 kW on each of the different grades for renewables with multiple resource grades
loop(regi,
  loop(teRe2rlfDetail(te,rlf),
    if( (pm_dataren(regi,"maxprod",rlf,te) gt 0),
        vm_capDistr.lo(t,regi,te,rlf)$(t.val gt 2011) = 1e-8;
*cb* make sure that grade distribution in early time steps with capacity fixing is close to optimal one assumed for vm_capFac calibration, divide by p_aux_capacityFactorHistOverREMIND to correct for deviation of REMIND capacity factors from historic capacity factors
      vm_capDistr.lo("2015",regi,te,rlf) = 0.90 / max(1, p_aux_capacityFactorHistOverREMIND(regi,te)) * p_aux_capThisGrade(regi,te,rlf);
      vm_capDistr.lo("2020",regi,te,rlf) = 0.90 / max(1, p_aux_capacityFactorHistOverREMIND(regi,te)) * p_aux_capThisGrade(regi,te,rlf);
    );
  );
);

*cb* make sure no grades > 9 are used. Only cosmetic to avoid entries in lst file
vm_capDistr.fx(t,regi,te,rlf)$(rlf.val gt 9) = 0;



*RP* no battery storage in 2010:
vm_cap.up("2010",regi,teStor,"1") = 0;

*** --------------------------------------------------------------------------------------------------------------------------------
*** completely switching off technologies that are not used in the current version of REMIND, although their parameters are declared:
*** --------------------------------------------------------------------------------------------------------------------------------
vm_cap.fx(t,regi,"solhe",rlf)     = 0;
vm_deltaCap.up(t,regi,"solhe",rlf) = 0;

vm_cap.fx(t,regi,"fnrs",rlf)     = 0;
vm_deltaCap.up(t,regi,"fnrs",rlf) = 0;

*** -----------------------------------------------------------------------------------------------------------------
*** Traditional biomass use is phased out on an exogeneous time path
*** -----------------------------------------------------------------------------------------------------------------
*** Note: make sure that this matches with the settings for residues in modules/05_initialCap/on/preloop.gms

*BS/DK* Developed regions phase out quickly (no new capacities)
vm_deltaCap.fx(t,regi,"biotr",rlf)$(t.val gt 2005) = 0;
*BS/DK* Developing regions (defined by GDP PPP threshold) phase out more slowly ( + varied by SSP)
loop(regi,
  if ( (pm_gdp("2005",regi)/pm_pop("2005",regi) / pm_shPPPMER(regi)) lt 4,
    vm_deltaCap.fx("2010",regi,"biotr","1") = 1.3  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2015",regi,"biotr","1") = 0.9  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2020",regi,"biotr","1") = 0.7  * vm_deltaCap.lo("2005",regi,"biotr","1");
$ifthen NOT %cm_tradbio_phaseout% == "fast"   !! cm_tradbio_phaseout
    vm_deltaCap.fx("2025",regi,"biotr","1") = 0.5  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2030",regi,"biotr","1") = 0.4  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2035",regi,"biotr","1") = 0.3  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2040",regi,"biotr","1") = 0.2  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2045",regi,"biotr","1") = 0.15 * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2050",regi,"biotr","1") = 0.1  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2055",regi,"biotr","1") = 0.1  * vm_deltaCap.lo("2005",regi,"biotr","1");
$endif
  );
);

* quickest phaseout in SDP scenarios (no new capacities allowed), quick phaseout in SSP1 und SSP5
$if %cm_GDPscen% == "gdp_SDP" vm_deltaCap.fx(t,regi,"biotr","1")$(t.val gt 2020) = 0;
$if %cm_GDPscen% == "gdp_SDP_EI" vm_deltaCap.fx(t,regi,"biotr","1")$(t.val gt 2020) = 0;
$if %cm_GDPscen% == "gdp_SDP_MC" vm_deltaCap.fx(t,regi,"biotr","1")$(t.val gt 2020) = 0;
$if %cm_GDPscen% == "gdp_SDP_RC" vm_deltaCap.fx(t,regi,"biotr","1")$(t.val gt 2020) = 0;
$if %cm_GDPscen% == "gdp_SSP1" vm_deltaCap.fx(t,regi,"biotr","1")$(t.val gt 2020) = 0.5 * vm_deltaCap.lo(t,regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP5" vm_deltaCap.fx(t,regi,"biotr","1")$(t.val gt 2020) = 0.5 * vm_deltaCap.lo(t,regi,"biotr","1");


*** ------------------------------------------------------------------------------------------
*LP* implement switch for scenarios with or without carbon sequestration:
*** ------------------------------------------------------------------------------------------

if ( c_ccsinjecratescen eq 0, !!no carbon sequestration at all
		vm_co2CCS.fx(t,regi_capturescen,"cco2","ico2","ccsinje","1") =0;
);

*** ------------------------------------------------------------------------------------------
*RP* implement switch for scenarios with different carbon capture assumptions::
*** ------------------------------------------------------------------------------------------
if (cm_ccapturescen eq 2,  !! no carbon capture at all
  vm_cap.fx(t,regi_capturescen,"ngccc",rlf)        = 0;
  vm_cap.fx(t,regi_capturescen,"ccsinje",rlf)      = 0;
***  vm_cap.fx(t,regi_capturescen,"ccscomp",rlf)      = 0; !! technologies disabled in REMIND 1.7
***  vm_cap.fx(t,regi_capturescen,"ccspipe",rlf)      = 0; !! technologies disabled in REMIND 1.7
***  vm_cap.fx(t,regi_capturescen,"ccsmoni",rlf)      = 0; !! technologies disabled in REMIND 1.7
  vm_cap.fx(t,regi_capturescen,"gash2c",rlf)       = 0;
  vm_cap.fx(t,regi_capturescen,"igccc",rlf)        = 0;
  vm_cap.fx(t,regi_capturescen,"coalftcrec",rlf)   = 0;
  vm_cap.fx(t,regi_capturescen,"coalh2c",rlf)      = 0;
  vm_cap.fx(t,regi_capturescen,"biogasc",rlf)      = 0;
  vm_cap.fx(t,regi_capturescen,"bioftcrec",rlf)    = 0;
  vm_cap.fx(t,regi_capturescen,"bioh2c",rlf)       = 0;
  vm_cap.fx(t,regi_capturescen,"bioigccc",rlf)     = 0;
elseif (cm_ccapturescen eq 3),  !! no bio carbon capture:
  vm_cap.fx(t,regi_capturescen,"biogasc",rlf)      = 0;
  vm_cap.fx(t,regi_capturescen,"bioftcrec",rlf)    = 0;
  vm_cap.fx(t,regi_capturescen,"bioh2c",rlf)       = 0;
  vm_cap.fx(t,regi_capturescen,"bioigccc",rlf)     = 0;
elseif (cm_ccapturescen eq 4), !! no carbon capture in the electricity sector
  loop(emi2te(enty,"seel",te,"cco2")$( sum(regi_capturescen,pm_emifac("2020",regi_capturescen,enty,"seel",te,"cco2")) > 0 ),
    loop(te2rlf(te,rlf),
      vm_cap.fx(t,regi_capturescen,te,rlf)        = 0;
    );
  );
);

*DK* switching technologies off that produce liquids from lignocellulosic biomass
if (c_bioliqscen eq 0, !! no bioliquids technologies
  vm_deltaCap.up(t,regi,"bioftrec",rlf)$(t.val gt 2005)    = 1.0e-6;
  vm_deltaCap.up(t,regi,"bioftcrec",rlf)$(t.val gt 2005)   = 1.0e-6;
  vm_deltaCap.up(t,regi,"bioethl",rlf)$(t.val gt 2005)     = 1.0e-6;
*  vm_cap.fx(t,regi,"bioftcrec",rlf)    = 0;
*  vm_cap.fx(t,regi,"bioftrec",rlf)     = 0;
*  vm_cap.fx(t,regi,"bioethl",rlf)      = 0;
);

*DK* switching technologies off that produce hydrogen from lignocellulosic biomass
if (c_bioh2scen eq 0, !! no bioh2 technologies
  vm_deltaCap.up(t,regi,"bioh2",rlf)$(t.val gt 2005)       = 1.0e-6;
  vm_deltaCap.up(t,regi,"bioh2c",rlf)$(t.val gt 2005)      = 1.0e-6;
*  vm_cap.fx(t,regi,"bioh2c",rlf)       = 0;
*  vm_cap.fx(t,regi,"bioh2",rlf)       = 0;
);

***--------------------------------------------------------------------
*RP no CCS should be used in a BAU run, and no CCS at all in 2010
***--------------------------------------------------------------------
vm_cap.fx("2010",regi,teCCS,rlf) = 0;

if(cm_emiscen = 1,
  vm_cap.fx(t,regi,teCCS,rlf) = 0;
);

*** ------------------------------------------------------------------------
*** Fix nuclear to historic values
*** ------------------------------------------------------------------------
if (cm_startyear le 2015,
  loop(regi,
    p_CapFixFromRWfix("2015",regi,"tnrs") = max( pm_aux_capLowerLimit("tnrs",regi,"2015") , pm_NuclearConstraint("2015",regi,"tnrs") );
    p_deltaCapFromRWfix("2015",regi,"tnrs") = ( p_CapFixFromRWfix("2015",regi,"tnrs") - pm_aux_capLowerLimit("tnrs",regi,"2015")  )
                                      / 7.5;  !! this parameter is currently only for display and not further used to fix anything
    p_deltaCapFromRWfix("2010",regi,"tnrs") = ( p_CapFixFromRWfix("2015",regi,"tnrs") - pm_aux_capLowerLimit("tnrs",regi,"2015")  )
                                      / 7.5; !! this parameter is currently only for display and not further used to fix anything
    vm_cap.fx("2015",regi,"tnrs","1") = p_CapFixFromRWfix("2015",regi,"tnrs");
  );
);

if (cm_startyear le 2020,   !! require the realization of at least 70% of the plants that are currently under construction and thus might be finished until 2020 - should be updated with real-world 2020 numbers
   vm_deltaCap.lo("2020",regi,"tnrs","1") = 0.70 * pm_NuclearConstraint("2020",regi,"tnrs") / 5;
   vm_deltaCap.up("2020",regi,"tnrs","1") = pm_NuclearConstraint("2020",regi,"tnrs") / 5;
);
if (cm_startyear le 2025,   !! upper bound calculated in mrremind/R/calcCapacityNuclear.R: 50% of planned and 30% of proposed plants, plus extra for lifetime extension and newcomers
   vm_deltaCap.up("2025",regi,"tnrs","1") = pm_NuclearConstraint("2025",regi,"tnrs") / 5;
);
if (cm_startyear le 2030,   !! upper bound calculated in mrremind/R/calcCapacityNuclear.R: 50% of planned and 70% of proposed plants, plus extra for lifetime extension and newcomers
   vm_deltaCap.up("2030",regi,"tnrs","1") = pm_NuclearConstraint("2030",regi,"tnrs") / 5;
);

display p_CapFixFromRWfix, p_deltaCapFromRWfix;

*** ------------------------------------------------------------------------------------------
*RP* implement switch for scenarios with different nuclear assumptions:
*** ------------------------------------------------------------------------------------------
vm_deltaCap.up(t,regi,"fnrs",rlf)$(t.val ge 2010)= 0;
vm_cap.fx(t,regi,"fnrs",rlf)$(t.val ge 2010) = 0;

*** no new nuclear investments after 2020, until then all currently planned plants are built
if (cm_nucscen eq 5,
  vm_deltaCap.up(t,regi_nucscen,"tnrs",rlf)$(t.val gt 2020)= 1e-6;
  vm_cap.lo(t,regi_nucscen,"tnrs",rlf)$(t.val gt 2015)  = 0;
);

*** -------------------------------------------------------------
*** *DK* Phaseout of 1st generation biofuel technologies
*** -------------------------------------------------------------
if(cm_1stgen_phaseout=1,
   vm_deltaCap.up(t,regi,"bioeths",rlf)$(t.val gt 2030)   = 0;
   vm_deltaCap.up(t,regi,"biodiesel",rlf)$(t.val gt 2030) = 0;
);

*** -----------------------------------------------------------
*mh Implementation of scenarios where capacities are fixed at BAU level:
*** -----------------------------------------------------------

if (cm_emiscen ne 1,
  if (c_solscen eq 3,
    vm_cap.up(t,regi,"spv",rlf)$(t.val ge 2010)  = p_boundtmp(t,regi,"spv",rlf);
  );
);

*** -----------------------------------------------------------
*mh bounds that narrow the solution space to help the conopt solver:
*** -----------------------------------------------------------

*nr* cumulated capacity never falls below initial cumulated capacity:
vm_capCum.lo(ttot,regi,teLearn)$(ttot.val ge cm_startyear) = pm_data(regi,"ccap0",teLearn);
*** exception for tech_stat 4 technologies whose ccap0 refers to 2025 as these technologies don't exist in 2005
vm_capCum.lo(ttot,regi,teLearn)$(pm_data(regi,"tech_stat",teLearn) eq 4 AND ttot.val le 2020) = 0;

*nr: floor costs represent the lower bound of learning technologies investment costs
vm_costTeCapital.lo(t,regi,teLearn) = pm_data(regi,"floorcost",teLearn);

*cb 20120319 avoid negative adjustment costs in 2005 (they would allow the model to artificially save money)
v_adjFactor.fx("2005",regi,te)=0;



vm_emiMacSector.lo(t,regi,enty)    =  0;
vm_emiMacSector.lo(t,regi,"co2luc")= -5.0;  !! afforestation can lead to negative emissions
vm_emiMac.fx(t,regi,"so2") = 0;
vm_emiMac.fx(t,regi,"bc") = 0;
vm_emiMac.fx(t,regi,"oc") = 0;

*** -------------------------------------------------------------------------
*** Exogenous values:
*** -------------------------------------------------------------------------
***----
*RP* fix capacities for wind, spv and csp to real world 2010 and 2015 values:
*CG* adding 2020 values
***----
loop(te$(sameas(te,"csp")),
  vm_cap.lo("2015",regi,te,"1") = 0.95 * pm_histCap("2015",regi,te)$(pm_histCap("2015",regi,te) gt 1e-10);
  vm_cap.up("2015",regi,te,"1") = 1.05 * pm_histCap("2015",regi,te)$(pm_histCap("2015",regi,te) gt 1e-10);
);


$IFTHEN.WindOff %cm_wind_offshore% == "0"
loop(te$(sameas(te,"spv") OR sameas(te,"wind") ),
  vm_cap.lo("2015",regi,te,"1") = 0.95 * pm_histCap("2015",regi,te)$(pm_histCap("2015",regi,te) gt 1e-10);
  vm_cap.up("2015",regi,te,"1") = 1.05 * pm_histCap("2015",regi,te)$(pm_histCap("2015",regi,te) gt 1e-10);
  vm_cap.lo("2020",regi,te,"1") = 0.95 * pm_histCap("2020",regi,te)$(pm_histCap("2020",regi,te) gt 1e-10);
  vm_cap.up("2020",regi,te,"1") = 1.05 * pm_histCap("2020",regi,te)$(pm_histCap("2020",regi,te) gt 1e-10);
  vm_cap.up("2025",regi,te,"1")$(pm_histCap("2025",regi,te) gt 1e-6) = 1.05 * pm_histCap("2025",regi,te)$(pm_histCap("2025",regi,te) gt 1e-6); !! only set a bound if values >1MW are in pm_histCap
);

$ENDIF.WindOff


$IFTHEN.WindOff %cm_wind_offshore% == "1"
loop(te$(sameas(te,"spv") OR sameas(te,"wind") OR sameas(te,"windoff")),
  vm_cap.lo("2015",regi,te,"1") = 0.95 * pm_histCap("2015",regi,te)$(pm_histCap("2015",regi,te) gt 1e-10);
  vm_cap.up("2015",regi,te,"1") = 1.05 * pm_histCap("2015",regi,te)$(pm_histCap("2015",regi,te) gt 1e-10);
  vm_cap.lo("2020",regi,te,"1") = 0.95 * pm_histCap("2020",regi,te)$(pm_histCap("2020",regi,te) gt 1e-10);
  vm_cap.up("2020",regi,te,"1") = 1.05 * pm_histCap("2020",regi,te)$(pm_histCap("2020",regi,te) gt 1e-10);
  vm_cap.up("2025",regi,te,"1")$(pm_histCap("2025",regi,te) gt 1e-6) = 1.05 * pm_histCap("2025",regi,te)$(pm_histCap("2025",regi,te) gt 1e-10); !! only set a bound if values >1MW are in pm_histCap
);

$ENDIF.WindOff

*** lower bound on capacities for ngcc and ngt and gaschp for regions defined at the pm_histCap file
loop(te$(sameas(te,"ngcc") OR sameas(te,"ngt") OR sameas(te,"gaschp")),
  vm_cap.lo("2015",regi,te,"1")$pm_histCap("2015",regi,te) = 0.95 * pm_histCap("2015",regi,te);
  vm_cap.lo("2020",regi,te,"1")$pm_histCap("2020",regi,te) = 0.95 * pm_histCap("2020",regi,te);
);

*** fix emissions to historical emissions in 2010
*** RP: turned off in March 2018, as it produces substantial negative side-effects (requiring strong early retirement in 2010, which influences the future investments even in Reference scenarios)
*** vm_emiTe.up("2010",regi,"co2") = p_boundEmi("2010",regi) ;

*** lower bound on stored CO2
vm_emiTe.lo(ttot,regi,"cco2") = 0;

*** -------------------------------------------------------
*** Advanced technologies shouldn't be built prior to 2015/2020:
*** -------------------------------------------------------
loop(regi,
  loop(teNoLearn(te),
    if( ( pm_data(regi,"tech_stat",te) eq 2 ) ,
      vm_deltaCap.fx("2010",regi,te,rlf) = 0;
      vm_cap.lo("2010",regi,te,rlf)=0;
      vm_cap.lo("2015",regi,te,rlf)=0;
    elseif ( pm_data(regi,"tech_stat",te) eq 3 ),
      vm_deltaCap.fx("2010",regi,te,rlf) = 0;
      vm_deltaCap.fx("2015",regi,te,rlf) = 0;
      vm_cap.lo("2010",regi,te,rlf)=0;
      vm_cap.lo("2015",regi,te,rlf)=0;
      vm_cap.lo("2020",regi,te,rlf)=0;
    );
  );
);

*** no technologies with tech_stat 4 before 2025
vm_cap.fx(t,regi,te,rlf)$(t.val le 2020 AND pm_data(regi,"tech_stat",te) eq 4)=0;
*** initialize cumulative capacity of tech_stat 4 technologies at 0 
*** (not at ccap0 from generisdata_tech.prn which gives the cucmulative capacity
***  at the initial investment cost of the first year in which the technology can be built)
vm_capCum.fx(t0,regi,teLearn)$(pm_data(regi,"tech_stat",teLearn) eq 4) = 0;
*** tech_stat 4 technologies don't learn before 2025, so capital cost should be fixed
vm_costTeCapital.fx(t,regi,teLearn)$(t.val le 2020 AND pm_data(regi,"tech_stat",teLearn) eq 4)=fm_dataglob("inco0",teLearn);

*** no technologies with tech_stat 5 before 2030
vm_deltaCap.fx(t,regi,te,rlf)$(t.val le 2025 AND pm_data(regi,"tech_stat",te) eq 5)=0;


*CB 2012024 -----------------------------------------------------
*CB allow for early retirement at the start of free model time
*CB ------------------------------------------------------------
*** allow non zero early retirement for all technologies to avoid mathematical errors
vm_capEarlyReti.up(ttot,regi,te) = 1e-6;


***generally allow full early retiremnt for all fossil technologies without CCS
vm_capEarlyReti.up(ttot,regi,te)$(teFosNoCCS(te)) = 1;
*** FS: allow nuclear early retirement (for nucscen 7)
vm_capEarlyReti.up(ttot,regi,"tnrs") = 1;

***restrict early retirement to the modeling time frame (to reduce runtime, the early retirement equations are phased out after 2110)
vm_capEarlyReti.up(ttot,regi,te)$(ttot.val lt 2009 or ttot.val gt 2111) = 0;

*cb 20120224 lower bound of 0.01% to help the model to be aware of the early retirement option
vm_capEarlyReti.lo(ttot,regi,te)$(teFosNoCCS(te) AND ttot.val gt 2011 AND ttot.val lt 2111) = 0.0001;
vm_capEarlyReti.lo(ttot,regi,"tnrs")$(ttot.val gt 2011 AND ttot.val lt 2111) = 0.0001;

*cb 20120301 no early retirement for dot, they are used despite their economic non-competitiveness for various reasons.
vm_capEarlyReti.fx(ttot,regi,"dot")=0;
*rp 20210118 no investment into oil turbines in Europe
vm_deltaCap.up(t,regi,"dot","1")$( (t.val gt 2005) AND regi_group("EUR_regi",regi) )  = 1e-6;



*** -----------------------------------------------------------------------------
*DK 20100929 Bound on CCS injection rate
*** -----------------------------------------------------------------------------
*** default value (0.5%) is consistent with Interview Gerling (BGR)
*** http://www.iz-klima.de/aktuelles/archiv/news-2010/mai/news-05052010-2/
*** 12 Gt storage potential in Germany, 50-75 Mt/a injection => 60 Mt/a => 60/12000=0.005
*LP* if c_ccsinjecratescen=0 --> no CCS at all and vm_co2CCS is fixed to 0 before, therefore the upper bound is only set if there should be CCS!
*** -----------------------------------------------------------------------------

if ( c_ccsinjecratescen gt 0,

	loop(regi,
***vm_co2CCS.up(t,regi,"tco2","ico2","ccsinje","1") = pm_dataccs(regi,"quan","1")*pm_ccsinjecrate(regi)
		vm_co2CCS.up(t,regi,"cco2","ico2","ccsinje","1") = pm_dataccs(regi,"quan","1") * pm_ccsinjecrate(regi);
	);

);


*** strong reliance on coal-to-liquids is not consistent with SSP1 storyline, therefore limit their use in the SSP 1 and SSP2 policy scenarios
$ifthen %c_SSP_forcing_adjust% == "forcing_SSP1"
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftrec")$(t.val gt 2050) = 0.00001;
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftcrec")$(t.val gt 2010) = 0.00001;
$endif
$ifthen %c_SSP_forcing_adjust% == "forcing_SSP2"
if(cm_emiscen gt 1,
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftcrec")$(t.val gt 2010) = 0.00001;
);
$endif


*** -------------------------------------------------------------------------------------------------------------
*RP* Upper limit on CCS deployment in 2020-2030
*LP* if c_ccsinjecratescen=0 --> no CCS at all and vm_co2CCS is fixed to 0 before, therefore the upper bound is only set if there should be CCS!
*** -------------------------------------------------------------------------------------------------------------

if ( c_ccsinjecratescen gt 0,
	vm_co2CCS.up("2020",regi,"cco2","ico2","ccsinje","1") = pm_boundCapCCS(regi);
	vm_co2CCS.up("2025",regi,"cco2","ico2","ccsinje","1") = pm_boundCapCCS(regi);
);

loop(regi,
  if( (pm_boundCapCCS(regi) eq 0),
    vm_cap.fx("2020",regi,teCCS,rlf) = 0;
	vm_cap.fx("2025",regi,teCCS,rlf) = 0;
  );
);

loop(regi,
  if( (p_boundCapCCSindicator(regi) eq 0),
    vm_cap.fx("2025",regi,teCCS,rlf) = 0;
	vm_cap.fx("2030",regi,teCCS,rlf) = 0;
  );
);

*AL* fixing prodFE in 2005 to the value contained in pm_cesdata("2005",regi,in,"quantity"). This is done to ensure that the energy system will reproduce the 2005 calibration values.
*** Fixing will produce clearly attributable errors (good for debugging) when using inconsistent data, as the GAMS accuracy when comparing fixed results is very high (< 1e-8).
***vm_prodFE.fx("2005",regi,se2fe(enty,enty2,te)) = sum(fe2ppfEn(enty2,in), pm_cesdata("2005",regi,in,"quantity") );

vm_deltaCap.up(t,regi,"gasftrec",rlf)$(t.val gt 2005)   = 0.0;
vm_deltaCap.up(t,regi,"gasftcrec",rlf)$(t.val gt 2005)  = 0.0;

$ontext
*** -------------------------------------------------------------
*** *RP* Chinese depoyment of coal power plants and coal use in industry was probably not only demand-driven, but also policy-driven (faster than demand). Therefore, we implement lower bounds on coal power plants and solid coal use:
*** -------------------------------------------------------------
if (cm_startyear le 2015,
vm_cap.lo("2015","CHN","pc","1")            = 0.75;  !! WEO says 826GW in 2013, 980 in 2020
vm_cap.lo("2010","CHN","coaltr","1")        = 0.79;  !! IEA says ~27EJ in 2010. In REMIND, a coaltr cap of 0.647 is equivalent to an FE solids coal level of 20.5 EJ, thus 25*0.647/20.5 = 0.79
vm_cap.lo("2015","CHN","coaltr","1")        = 0.88;  !! IEA says ~29.7EJ in 2012. In REMIND, a coaltr cap of 0.647 is equivalent to an FE solids coal level of 20.5 EJ, thus 28*0.647/20.5 = 0.88
);
$offtext

$if  %c_SSP_forcing_adjust% == "forcing_SSP1"    vm_deltaCap.up(t,regi,"coalgas",rlf)$(t.val gt 2010) = 0.00001;

*** -------------------------------------------------------------
*** H2 Curtailment
*** -------------------------------------------------------------
***Fixing h2curt value to zero to avoid the model to generate SE out of nothing.
***Models that have additional se production channels should release this variable (eg. RLDC power module).
loop(prodSeOth2te(enty,te),
  vm_prodSeOth.fx(t,regi,"seh2","h2curt") = 0;
);


***---------------------------------------------------------------------------
***                 Lower bounds on hydro
***---------------------------------------------------------------------------
*** as most of the costs for hydro are for the initial building, it is unlikely that existing hydro plants are not renovated, even if a completely new plant would not be economic
*** accordingly, set lower bound on hydro generation close to 2005 values

vm_prodSe.lo(t,regi,"pehyd","seel","hydro")$(t.val > 2005) = 0.99 * o_INI_DirProdSeTe(regi,"seel","hydro");


***---------------------------------------------------------------------------
***                 make sure the model doesn't use technologies beyond grade 1
***---------------------------------------------------------------------------
*** for pe2se, se2se and se2fe the other grades should not be used


vm_deltaCap.fx(t,regi,te,rlf)$( (NOT rlf.val eq 1)  AND ( teSe2rlf(te,"1") OR teFe2rlf(te,"1") ) ) = 0;
vm_cap.fx(ttot,regi,te,rlf)$((NOT rlf.val eq 1) AND ( teSe2rlf(te,"1") OR teFe2rlf(te,"1") ) )     = 0;


***----------------------------------------------------------------------------
*** fix F-gas emissions to inputdata (IMAGE)
***----------------------------------------------------------------------------

vm_emiFgas.fx(ttot,all_regi,all_enty) = f_emiFgas(ttot,all_regi,"%c_SSP_forcing_adjust%","%cm_rcp_scen%","SPA0",all_enty);
display vm_emiFgas.L;


*AL* Bugfix. For some reason the model cannot reduce the production of district heating to 0
*AL* where it should be 0. Not fixings can account for this
*AL* Fixing vm_prodSe to 0 avoids the problem
loop ((in,in2) $ (sameAs(in,"feheb") and sameAs(in2,"fehei")),
loop ((t, regi) $ ( (sameAs(t,"2010") OR sameAs(t,"2015"))
                     AND
                    ((pm_cesdata(t,regi,in,"quantity") + pm_cesdata(t,regi,in,"offset_quantity")
                    + pm_cesdata(t,regi,in2,"quantity") + pm_cesdata(t,regi,in2,"offset_quantity")
                    ) eq 0)
                    AND
                    (sum(ttot$(ttot.val lt 2005), vm_deltacap.up(ttot,regi,"biochp","1")) eq 0)) ,
      vm_prodSe.up(t,regi,"pegas"  ,"seel","gaschp")  = 0;
      vm_prodSe.up(t,regi,"pecoal" ,"seel","coalchp") = 0;
      vm_prodSe.up(t,regi,"pecoal" ,"sehe","coalhp")  = 0;
      vm_prodSe.up(t,regi,"pegeo"  ,"sehe","geohe")   = 0;
      vm_prodSe.up(t,regi,"pesol"  ,"sehe","solhe")   = 0;
      vm_prodSe.up(t,regi,"pebiolc","seel","biochp")  = 0;
      vm_prodSe.up(t,regi,"pebiolc","sehe","biohp")   = 0;
      vm_prodSe.up(t,regi,"pegas","sehe","gashp")   = 0;
);
);

***----------------------------------------------------------------------------
*** lower bound on share of green hydrogen starting from 2030 (c_greenH2)
***----------------------------------------------------------------------------

v_shGreenH2.lo(t,regi)$(t.val eq 2025) = c_shGreenH2 * 2/3;
v_shGreenH2.lo(t,regi)$(t.val gt 2025) = c_shGreenH2;

***----------------------------------------------------------------------------
*** upper bound on bioliquids as a share of transport liquids
***----------------------------------------------------------------------------

v_shBioTrans.up(t,regi)$(t.val > 2020) = c_shBioTrans;

***----------------------------------------------------------------------------
*** bounds on final energy use (relevant in case some switches are acitvated that make pm_shfe_up and pm_shfe_lo non-zero)
***----------------------------------------------------------------------------

*** upper and lower bounds on FE carrier shares
v_shfe.up(t,regi,entyFe,sector)$pm_shfe_up(t,regi,entyFe,sector) = pm_shfe_up(t,regi,entyFe,sector);
v_shfe.lo(t,regi,entyFe,sector)$pm_shfe_lo(t,regi,entyFe,sector) = pm_shfe_lo(t,regi,entyFe,sector);

*** upper and lower bounds on gases+liquids share in FE
v_shGasLiq_fe.up(t,regi,sector)$pm_shGasLiq_fe_up(t,regi,sector) = pm_shGasLiq_fe_up(t,regi,sector);
v_shGasLiq_fe.lo(t,regi,sector)$pm_shGasLiq_fe_lo(t,regi,sector) = pm_shGasLiq_fe_lo(t,regi,sector);

*** RH: Fix H2 in buildings to zero until given year (always zero by default)
vm_demFeSector.up(t,regi,"seh2","feh2s","build",emiMkt)$(t.val le c_H2InBuildOnlyAfter) = 0;

***----------------------------------------------------------------------------
***  Controlling if active, dampening factor to align edge-t non-energy transportation costs with historical GDP data
***----------------------------------------------------------------------------
$IFTHEN.transpGDPscale not "%cm_transpGDPscale%" == "on" 
  vm_transpGDPscale.fx(t,regi) = 1;
$ENDIF.transpGDPscale

***----------------------------------------------------------------------------
*'  Limit slack variable and uncontrolled variable values for adj costs that limit changes to reference in cm_startyear
***----------------------------------------------------------------------------

v_changeProdStartyearSlack.up(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) ) = + c_SlackMultiplier * p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ;
v_changeProdStartyearSlack.lo(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) ) = - c_SlackMultiplier * p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ;


*** EOF ./core/bounds.gms
