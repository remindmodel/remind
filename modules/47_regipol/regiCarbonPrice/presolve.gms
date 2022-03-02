*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/presolve.gms


*** Removing economy wide co2 tax parameters for regions within the ETS
$IFTHEN.emiMktETS not "%cm_emiMktETS%" == "off" 

loop(ETS_mkt,
	pm_taxCO2eqSum(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
	pm_taxCO2eq(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
	pm_taxCO2eqRegi(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
	pm_taxCO2eqHist(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
	pm_taxCO2eqSCC(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;

	p21_taxrevGHG0(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
	p21_taxrevCO2Sector0(ttot,regi,emi_sectors)$(ETS_regi(ETS_mkt,regi)) = 0;
	p21_taxrevCO2LUC0(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
	p21_taxrevNetNegEmi0(ttot,regi)$(ETS_regi(ETS_mkt,regi)) = 0;
);

$ENDIF.emiMktETS	

*** Removing economy wide co2 tax parameters for regions within the ES
$ifThen.emiMktES not "%cm_emiMktES%" == "off" 

loop((regi)$pm_emiTargetESR("2030",regi),
	pm_taxCO2eqSum(ttot,regi) = 0;
	pm_taxCO2eq(ttot,regi) = 0;
	pm_taxCO2eqRegi(ttot,regi) = 0;
	pm_taxCO2eqHist(ttot,regi) = 0;
	pm_taxCO2eqSCC(ttot,regi) = 0;

	p21_taxrevGHG0(ttot,regi) = 0;
	p21_taxrevCO2Sector0(ttot,regi,emi_sectors) = 0;
	p21_taxrevCO2LUC0(ttot,regi) = 0;
	p21_taxrevNetNegEmi0(ttot,regi) = 0;
);

$endIf.emiMktES

*** removing co2 taxes for regions controlled by the regipol module   
$ifThen.regicarbonprice not "%cm_regiCO2target%" == "off" 

loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) AND (NOT(all_regi(ext_regi)))), !!for region groups
	loop(regi$regi_group(ext_regi,regi),
		pm_taxCO2eqSum(t,regi) = 0;
		pm_taxCO2eq(t,regi) = 0;
		pm_taxCO2eqRegi(t,regi) = 0;
		pm_taxCO2eqHist(t,regi) = 0;
		pm_taxCO2eqSCC(t,regi) = 0;

		p21_taxrevGHG0(t,regi) = 0;
		p21_taxrevCO2Sector0(t,regi,emi_sectors) = 0;
		p21_taxrevCO2LUC0(t,regi) = 0;
		p21_taxrevNetNegEmi0(t,regi) = 0;
	);
);

loop((ttot,ttot2,ext_regi,target_type,emi_type)$(pm_regiCO2target(ttot,ttot2,ext_regi,target_type,emi_type) AND (all_regi(ext_regi))), !!for single regions
	loop(regi$(sameas(ext_regi,regi)),
		pm_taxCO2eqSum(t,regi) = 0;
		pm_taxCO2eq(t,regi) = 0;
		pm_taxCO2eqRegi(t,regi) = 0;
		pm_taxCO2eqHist(t,regi) = 0;
		pm_taxCO2eqSCC(t,regi) = 0;

		p21_taxrevGHG0(t,regi) = 0;
		p21_taxrevCO2Sector0(t,regi,emi_sectors) = 0;
		p21_taxrevCO2LUC0(t,regi) = 0;
		p21_taxrevNetNegEmi0(t,regi) = 0;
	);
);

$endIf.regicarbonprice


$ifthen.cm_implicitFE not "%cm_implicitFE%" == "off"

*** saving value for implicit tax revenue recycling
	p47_implFETax0(t,regi) = sum(enty2$entyFE(enty2), p47_implFETax(t,regi,enty2) * sum(se2fe(enty,enty2,te), vm_prodFe.l(t,regi,enty,enty2,te)));

$endIf.cm_implicitFE

$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"

*** saving value for implicit tax revenue recycling
  p47_implEnergyBoundTax0(t,regi) = 
    sum((energyCarrierLevel,energyType)$p47_implEnergyBoundTax(t,regi,energyCarrierLevel,energyType),
	  ( p47_implEnergyBoundTax(t,regi,"PE",energyType) * sum(entyPe$energyCarrierANDtype2enty("PE",energyType,entyPe), sum(pe2se(entyPe,entySe,te), vm_demPe.l(t,regi,entyPe,entySe,te))) )$(sameas(energyCarrierLevel,"PE")) 
	  +
	  ( p47_implEnergyBoundTax(t,regi,"SE",energyType) * sum(entySe$energyCarrierANDtype2enty("SE",energyType,entySe), sum(se2fe(entySe,entyFe,te), vm_demSe.l(t,regi,entySe,entyFe,te))) )$(sameas(energyCarrierLevel,"SE")) 
	  +
	  ( p47_implEnergyBoundTax(t,regi,"FE",energyType) * sum(entySe$energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te), sum((sector,emiMkt)$(entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))) )$(sameas(energyCarrierLevel,"FE")) 
	)
  ;

$endIf.cm_implicitEnergyBound

*** EOF ./modules/47_regipol/regiCarbonPrice/presolve.gms

