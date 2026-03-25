*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/none/declarations.gms

	
Parameter
  pm_emiMktTarget_dev(ttot,ttot2,ext_regi,emiMktExt)                 "target deviation across iterations in current emissions divided by target emissions (1 is 100%)"
  pm_emiMktTarget_dev_iter(iteration, ttot,ttot2,ext_regi,emiMktExt) "parameter to save pm_emiMktTarget_dev across iterations (1 is 100%)"
  pm_taxemiMkt(ttot,all_regi,all_emiMkt)                             "CO2 tax path per region and emissions market [T$/GtC]"
  pm_taxemiMkt_iteration(iteration,ttot,all_regi,all_emiMkt)         "CO2 tax path per region and emissions market calculated from previous iteration [T$/GtC]"
;


*** EOF ./modules/47_regipol/none/declarations.gms
