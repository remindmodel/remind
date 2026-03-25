*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/sets.gms

SETS
target_type_47 "CO2 policy target type" / budget , year /

emi_type_47 "emission type used in regional target" 
/ 
  netCO2, netCO2_noBunkers, netCO2_noLULUCF_noBunkers, netCO2_LULUCFGrassi, netCO2_LULUCFGrassi_noBunkers, netCO2_LULUCFGrassi_intraRegBunker,
  netGHG, netGHG_noBunkers, netGHG_noLULUCF_noBunkers, netGHG_LULUCFGrassi, netGHG_LULUCFGrassi_noBunkers, netGHG_LULUCFGrassi_intraRegBunker, netGHG_noLULUCF,
  grossEnCO2_noBunkers 
/

*** Emission markets
$ifThen.emiMkt not "%cm_emiMktTarget%" == "off" 
  regiEmiMktTarget(ext_regi)                   "regions with emiMkt targets" / /
  regiANDperiodEmiMktTarget_47(ttot,ext_regi)  "regions and periods with emiMkt targets" / /
  regiEmiMktTarget2regi_47(ext_regi,all_regi)  "regions controlled by emiMkt market set to ext_regi" / / 
  rescaleType                                  "emi mkt carbon price scaling factor calculation methods" / 
    "squareDev_firstIteration", "squareDev_perfectMatch", "squareDev_smallChange", "squareDev_noChange", 
    "slope_refIteration", "slope_firstIteration", "slope_repeatPrev", "slope_repeatPrev_positiveSlope", 
    "squareDev_noSlope", "squareDev_noNonPositiveSlope"/
  regiEmiMktRescaleType(iteration,ttot,ttot,ext_regi,emiMktExt,rescaleType) "saving scaling type used in iteration" / /
  convergenceType                              "emiMkt target non convergence reason" / "lowerThanTolerance", "smallPrice" / 
  regiEmiMktconvergenceType(iteration,ttot,ttot,ext_regi,emiMktExt,convergenceType) "saving convergence type in iteration" / /
$ENDIF.emiMkt

*** Implicit tax/subsidy necessary to achieve quantity target for primary, secondary, final energy and/or CCS and/or OAE
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"

taxType "PE, SE or FE tax type"
/
  tax
  sub
/

targetType "PE, SE or FE target type"
/
  t  "absolute target (t=total)"
  s  "relative target (s=share)"
/

qttyTarget "quantity target for energy carrier level (primary, secondary, final energy) or CCS or OAE"
/
  PE              "Primary Energy"
  SE              "Secondary Energy"
  FE              "Final Energy"
  FE_wo_b         "Final Energy without bunkers"
  FE_wo_n_e       "Final Energy without non-energy"
  FE_wo_b_wo_n_e  "Final Energy without bunkers and non-energy"
  CCS             "carbon capture and storage"
  oae             "ocean alkalinity enhancement"
/

qttyTargetGroup "quantity target aggregated categories"
/
  all
  biomass
  fossil
  VRE
  wind
  solar
  renewables
  renewablesNoBio
  synthetic
  hydrogen
  electricity
  heat
/

energyQttyTargetANDGroup2enty(qttyTarget,qttyTargetGroup,all_enty) "set combining possible energy level (PE, SE or FE), energy types and energy carriers"
/
*** Primary energy type categories
***  PE.all.(entyPe) !! defined below as calculated set
  PE.biomass.(pebiolc,pebios,pebioil)
  PE.fossil.(peoil,pegas,pecoal)
  PE.VRE.(pewin,pesol)
  PE.wind.pewin
  PE.solar.pesol
  PE.renewables.(pegeo,pehyd,pewin,pesol,pebiolc,pebios,pebioil)
  PE.renewablesNoBio.(pegeo,pehyd,pewin,pesol)  
*** Secondary energy type categories
***  SE.all.(entySe) !! defined below as calculated set
  SE.biomass.(seliqbio,sesobio,segabio)
  SE.fossil.(seliqfos,sesofos,segafos)
  SE.synthetic.(seliqsyn,segasyn)
  SE.hydrogen.(seh2)
  SE.electricity.(seel)
  SE.heat.(sehe)
*** Final energy type categories
***  FE.all.(entySe) !! defined below as calculated set
  FE.biomass.(seliqbio,sesobio,segabio)
  FE.fossil.(seliqfos,sesofos,segafos)
  FE.synthetic.(seliqsyn,segasyn)
  FE.hydrogen.(seh2)
  FE.electricity.(seel)
  FE.heat.(sehe)
/

qttyDelayType_47 "options to define different delay rules for starting the quantity targets algorithm"
/
  iteration    "quantity targets are only active after certain iteration"
  emiConv      "quantity targets are only active after emission targets defined at the carbon price modules and at the regipol modules converged"
  emiRegiConv  "quantity targets are only active after regional emission targets achieved given deviation levels"
/

$ifThen.cm_implicitQttyTargetType "%cm_implicitQttyTargetType%" == "scenario"
qttyTargetScenario  "hard-coded quantity scenarios"
/
  EU27_eedEff  "2018 energy efficiency directive    (846 Mtoe final energy by 2030)"
  EU27_ff55Eff "Fit for 55 energy efficiency target (787 Mtoe final energy by 2030)"
  EU27_RpEUEff "RePowerEU energy efficiency target  (750 Mtoe final energy by 2030)"

  EU27_bio4    "EU-27 primary energy biomass limited to 6 EJ by 2035 and 4 EJ by 2050"
  EU27_bio7    "EU-27 primary energy biomass limited to 7 EJ by 2035 and 2050"
  EU27_bio7p5  "EU-27 primary energy biomass limited to 7.5 EJ by 2035 and 2050"
  EU27_bio12   "EU-27 primary energy biomass limited to 12 EJ by 2035 and 2050"
  GLO_bio100   "Global primary energy biomass limited to 100EJ by 2035 and 2050"

  EU27_limVRE  "wind and solar limited to linear extrapolation of 2021-2022 growth of generation capacity by 2025 and 2050"

  EU28_CCS250Mt "EU27 and UK max CCS (including DACCS and BECCS) limited to 250 Mt CO2/yr."
  GLO_CCS2Gt   "Global max CCS (including DACCS and BECCS) limited to 2 Gt CO2/yr."
/
qttyTargetActiveScenario(qttyTargetScenario) "current run active quantity scenarios" / %cm_implicitQttyTarget% / 
$endif.cm_implicitQttyTargetType

$endIf.cm_implicitQttyTarget

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
fePriceScenario "scenarios for exogenous FE price targets"
/
  elecPrice
  H2Price
  initial
  highPrice
  lowPrice
  highElec
  lowElec
  highGasandLiq
/
$endIf.cm_implicitPriceTarget

$ifthen.cm_implicitPePriceTarget not "%cm_implicitPePriceTarget%" == "off"
pePriceScenario "scenarios for exogenous PE price targets"
/
  highFossilPrice
/
$endIf.cm_implicitPePriceTarget

$ifthen.exogDemScen NOT "%cm_exogDem_scen%" == "off"
exogDemScen       "exogenuous FE and ES demand scenarios that can be activated by cm_exogDem_scen"
/
        ariadne_bal
        ariadne_ensec
        ariadne_highDem
        ariadne_lowDem
/
$endif.exogDemScen

;

*** Defining extra energyQttyTargetANDGroup2enty set elements
$ifthen.cm_implicitQttyTarget not "%cm_implicitQttyTarget%" == "off"
  loop(entyPe,
    energyQttyTargetANDGroup2enty("PE","all",entyPe) = YES;
  );
  loop(entySe,
    energyQttyTargetANDGroup2enty("SE","all",entySe) = YES;
  );
  loop(entyFe,
    energyQttyTargetANDGroup2enty("FE","all",entySe) = YES;
  );
$endIf.cm_implicitQttyTarget

*** EOF ./modules/47_regipol/regiCarbonPrice/sets.gms

