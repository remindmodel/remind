*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/linadjust/declarations.gms
***-------------------------------------------------------------------------------
*** *IM* 20140402 declaration of parameters
***-------------------------------------------------------------------------------

parameters
p45_tauCO2_ref(ttot, all_regi)              "CO2 tax path of reference policy (e.g. exogMod2)"
p45_tauCO2_opt(ttot, all_regi)              "CO2 tax path of first best policy (e.g. SPA0)"
p45_pvpRegi_ref(ttot,all_regi,all_enty)     "prices of traded commodities from reference gdx - regional"
p45_pvpRegi_opt(ttot,all_regi,all_enty)     "prices of traded commodities from first best gdx - regional"
;
scalars
s45_stagestart                              "first time-step of staged accession period"
s45_stageend                                "first time-step of comprehensive cooperation period (first time-step after the end of the staged accession period)"
;
*** EOF ./modules/45_carbonprice/linadjust/declarations.gms
