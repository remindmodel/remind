*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/sets.gms

SETS
target_type_47 "CO2 policy target type" / budget , year /

emi_type_47 "emission type used in regional target" / netCO2, netCO2_noBunkers, netCO2_noLULUCF_noBunkers, netGHG, netGHG_noBunkers, netGHG_noLULUCF_noBunkers, grossEnCO2_noBunkers, netGHG_LULUCFGrassi_noBunkers /

*** Emission markets
$ifThen.emiMkt not "%cm_emiMktTarget%" == "off" 
  regiEmiMktTarget(ext_regi)               "regions with emiMkt targets" / /
  regiANDperiodEmiMktTarget_47(ttot,ext_regi) "regions and periods with emiMkt targets" / /
$ENDIF.emiMkt

*** implicit tax/subsidy necessary to achieve primary, secondary and/or final energy targets
$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"

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

energyCarrierLevel "energy carrier Level"
/
  PE              "Primary Energy"
  SE              "Secondary Energy"
  FE              "Final Energy"
  FE_wo_b         "Final Energy without bunkers"
  FE_wo_n_e       "Final Energy without non-energy"
  FE_wo_b_wo_n_e  "Final Energy without bunkers and non-energy"
/

energyType "energy type aggregated categories"
/
  all
  biomass
  fossil
  VRE
  renewables
  renewablesNoBio
  synthetic
  hydrogen
  electricity
  heat
/

energyCarrierANDtype2enty(energyCarrierLevel,energyType,all_enty) "set combining possible energy level (PE, SE or FE), energy types and energy carriers"
/
*** Primary energy type categories
***  PE.all.(entyPe) !! defined below as calculated set
  PE.biomass.(pebiolc,pebios,pebioil)
  PE.fossil.(peoil,pegas,pecoal)
  PE.VRE.(pewin,pesol)
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
$endIf.cm_implicitEnergyBound

$ifthen.cm_implicitPriceTarget not "%cm_implicitPriceTarget%" == "off"
fePriceScenario "scenarios for exogenous FE price targets"
/
  initial
  highPrice
  lowPrice
  highElec
  lowElec
  highGasandLiq
/
$endIf.cm_implicitPriceTarget
;

*** Defining extra energyCarrierANDtype2enty set elements
$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"
  loop(entyPe,
    energyCarrierANDtype2enty("PE","all",entyPe) = YES;
  );
  loop(entySe,
    energyCarrierANDtype2enty("SE","all",entySe) = YES;
  );
  loop(entyFe,
    energyCarrierANDtype2enty("FE","all",entySe) = YES;
  );
$endIf.cm_implicitEnergyBound


*** EOF ./modules/47_regipol/regiCarbonPrice/sets.gms

