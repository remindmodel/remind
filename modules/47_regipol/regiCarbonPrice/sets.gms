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

$ifThen.emiMkt not "%cm_emiMktTarget%" == "off" 
  regiEmiMktTarget_47(ext_regi)               "regions with emiMkt targets" / /
  regiANDperiodEmiMktTarget_47(ttot,ext_regi) "regions and periods with emiMkt targets" / /
$ENDIF.emiMkt

ETS_mkt "ETS market"
/
  EU_ETS
/

ETS_regi(ETS_mkt,all_regi) "regions that belong to the same ETS market" / /

$ifthen.cm_implicitFE not "%cm_implicitFE%" == "off"

FEtarget_sector "final energy target sector groups" / stat, trans /

FEtarget_sector2entyFe(FEtarget_sector,all_enty)  "mapping final energy to stationary or transportation sectors"
/
   stat.(fegas,fehos,fesos,feels,fehes,feh2s)
   trans.(fegat,fepet,fedie,feh2t,feelt)
/

$endif.cm_implicitFE

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

energyCarrierANDtype2enty(energyCarrierLevel,energyType,all_enty)
/
*** Primary energy type categories
***  PE.all.(entyPe) !! defined below as a calculated set
  PE.biomass.(pebiolc,pebios,pebioil)
  PE.fossil.(peoil,pegas,pecoal)
  PE.VRE.(pewin,pesol)
  PE.renewables.(pegeo,pehyd,pewin,pesol,pebiolc,pebios,pebioil)
  PE.renewablesNoBio.(pegeo,pehyd,pewin,pesol)  
*** Secondary energy type categories
***  SE.all.(entySe) !! defined below as a calculated set
  SE.biomass.(seliqbio,sesobio,segabio)
  SE.fossil.(seliqfos,sesofos,segafos)
  SE.synthetic.(seliqsyn,segasyn)
  SE.hydrogen.(seh2)
  SE.electricity.(seel)
  SE.heat.(sehe)
*** Final energy type categories
***  FE.all.(entySe) !! defined below as a calculated set
  FE.biomass.(seliqbio,sesobio,segabio)
  FE.fossil.(seliqfos,sesofos,segafos)
  FE.synthetic.(seliqsyn,segasyn)
  FE.hydrogen.(seh2)
  FE.electricity.(seel)
  FE.heat.(sehe)
/
$endIf.cm_implicitEnergyBound
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

*** Defining EU ETS
loop(all_regi$(regi_group("EUR_regi",all_regi) AND (NOT(sameas(all_regi,"UKI")))),
  ETS_regi("EU_ETS",all_regi) = YES;
);
***NEN (to include NEN I need to disable only partially the pm_taxCO2eq tax (because if not the ESD emissions would be without tax).   


*** EOF ./modules/47_regipol/regiCarbonPrice/sets.gms

