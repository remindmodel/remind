*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/load/sets.gms

Sets

cesParameter   "parameters of the CES functions and for calibration"
/
  quantity          "quantity of CES function input/output"
  price             "price of CES function input/output"
  eff               "baseyear efficiency of CES function input/output"
  effgr             "multiplicative efficiency growth of CES function input/output"
  rho               "CES function elasticity parameter rho = 1 - (1 / sigma)"
  xi                "baseyear income share of CES function input/output"
  offset_quantity   "quantity offset for the CES tree if the quantity is null"
  compl_coef        "coefficients for the perfectly complementary factors"
/

regi_dyn29(all_regi)   "dynamic region set for compatibility with testOneRegi"

eff_scale_par   "parameters for scaling certain efficiencies during calibration"
/
  level
  midperiod
  width
/
;
*** EOF ./modules/29_CES_parameters/load/sets.gms

