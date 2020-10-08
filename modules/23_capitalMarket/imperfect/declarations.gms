*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/23_capitalMarket/imperfect/declarations.gms

Parameters
  p23_debtCoeff                  "maximum indebtness as share of GDP"
  p23_debt_growthCoeff(all_regi) "maximum indebtness growth as share of GDP"
;

Equations
  q23_limit_debt(ttot,all_regi)               "debt constraint"
  q23_limit_debt_growth(ttot,all_regi)        "debt growth constraint"
;

*** EOF ./modules/23_capitalMarket/imperfect/declarations.gms
