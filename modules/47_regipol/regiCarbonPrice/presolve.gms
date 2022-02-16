*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/presolve.gms

$ifthen.cm_implicitFE not "%cm_implicitFE%" == "off"

*** saving value for implicit tax revenue recycling
	p47_implFETax0(t,regi) = sum(enty2$entyFE(enty2), p47_implFETax(t,regi,enty2) * sum(se2fe(enty,enty2,te), vm_prodFe.l(t,regi,enty,enty2,te)));

$endIf.cm_implicitFE

$ifthen.cm_implicitEnergyBound not "%cm_implicitEnergyBound%" == "off"

*** saving value for implicit tax revenue recycling
	p47_implEnergyBoundTax0(t,regi,energyCarrierLevel,energyType) = 
		( p47_implEnergyBoundTax(t,regi,"PE",energyType) * sum(energyCarrierANDtype2enty("PE",energyType,entyPe), vm_prodPe.l(t,regi,entyPe)) )$(sameas(energyCarrierLevel,"PE")) 
  		+
  		( p47_implEnergyBoundTax(t,regi,"SE",energyType) * sum(energyCarrierANDtype2enty("SE",energyType,entySe), sum(pe2se(entyPe,entySe,te),  vm_prodSe.l(t,regi,entyPe,entySe,te)) ) )$(sameas(energyCarrierLevel,"SE")) 
  		+
  		( p47_implEnergyBoundTax(t,regi,"FE",energyType) * sum(energyCarrierANDtype2enty("FE",energyType,entySe), sum(se2fe(entySe,entyFe,te),  vm_prodFe.l(t,regi,entySe,entyFe,te)) ) )$(sameas(energyCarrierLevel,"FE")) 
	;

$endIf.cm_implicitEnergyBound

*** EOF ./modules/47_regipol/regiCarbonPrice/presolve.gms

