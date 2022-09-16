*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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


*** exogenuous trajectories for Germany for industrial process chemicals and steel emissions in MtCO2/yr, convert to GtC/yr
*** start year from 2015 UNFCCC data
vm_macBase.fx(t,regi,"co2chemicals")$(sameas(regi,"DEU") AND t.val le 2015)= 5.5 / sm_C_2_CO2 / 1000;
vm_macBase.fx(t,regi,"co2steel")$(sameas(regi,"DEU") AND t.val le 2015)= 16.7 / sm_C_2_CO2 / 1000;
*** exponential decrease until 2050 to ~25% of  2015 value
vm_macBase.fx(t,regi,"co2chemicals")$(sameas(regi,"DEU") AND t.val gt 2015) = 5.5 / sm_C_2_CO2 / 1000 * exp( -1/25 * (t.val - 2015));
vm_macBase.fx(t,regi,"co2steel")$(sameas(regi,"DEU") AND t.val gt 2015) = 16.7 / sm_C_2_CO2 / 1000 * exp( -1/25 * (t.val - 2015));


*** EOF ./modules/47_regipol/regiCarbonPrice/presolve.gms

