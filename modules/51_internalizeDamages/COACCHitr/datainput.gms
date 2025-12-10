*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/51_internalizeDamages/COACCHitr/datainput.gms

* satisfy dependencies
$ifi not %damages% == 'COACCH' abort "module internalizeDamages=COACCHitr requires module damages=COACCH";
$ifi not %cm_magicc_temperatureImpulseResponse% == 'on' abort "module internalizeDamages=COACCHitr requires cm_magicc_temperatureImpulseResponse=on";

*init carbon tax for 1st iter
p51_scc("2020") = 20;
p51_scc(tall)$(tall.val ge 2020 and tall.val le 2150) = p51_scc("2020")*(1+0.025*(tall.val-2020));

loop(ttot$(ttot.val ge 2020),
	loop(tall$(pm_ttot_2_tall(ttot,tall)),
	    pm_taxCO2eqSCC(ttot,regi)$(ttot.val ge 2020) = p51_scc(tall)   * sm_c_2_co2/1000;
	));

*** EOF ./modules/51_internalizeDamages/COACCHitr/datainput.gms
