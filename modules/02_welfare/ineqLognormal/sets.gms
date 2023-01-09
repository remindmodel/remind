*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/02_welfare/ineqLognormal/sets.gms

sets
damscens "scenarios for which the conversion factor from output to consumption loss is available"
/SSP2EU-Base-IMCP-KWdamage,SSP2EU-NDC-IMCP-KWdamage,SSP2EU-PkBudg1150-IMCP-KWdamage_notInternalized,SSP2EU-PkBudg650-IMCP-KWdamage_notInternalized/

dam_factors "damage conversion factors output to consumption"
/f1,f2/
;

*** EOF ./modules/02_welfare/ineqLognormal/sets.gms
