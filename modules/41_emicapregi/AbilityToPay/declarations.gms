*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/AbilityToPay/declarations.gms

parameter
p41_precorrection_reduction(tall,all_regi)      "reduction as calculated from 3rd root calculation, uncorrected "
p41_correct_factor(tall)                        "correction factor so that global pathway matches"
p41_co2eq(ttot,all_regi)                        "emissions from cost-optimal reference run"
p41_co2eq_bau(ttot,all_regi)                    "emissions from no-policy baseline run"
;

*** EOF ./modules/41_emicapregi/AbilityToPay/declarations.gms
