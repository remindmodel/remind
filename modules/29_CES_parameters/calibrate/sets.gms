*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/sets.gms

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
ces_29(all_in,all_in)   "calibration CES tree structure"
ces2_29(all_in,all_in)   "calibration CES tree structure"
ces_29_load(all_in,all_in) "ces from input.gdx"
regi_29_load(all_regi)    "regional resolution from input.gdx"
ipf_29(all_in)   "calibration intermediate production factors"
ppf_29(all_in)   "primary production factors to calibrate for"
in_29(all_in)    "calibration production factors"
ue_29(all_in) "useful energy variables"
ue_fe_kap_29(all_in) "useful energy items which are the direct output of one FE and one Kap, and which is calibrated to. The CES efficiencies need specific treatment"
putty_compute_in(all_in)  "factors inside putty which should be computed from non-putty values"
in_beyond_calib_29(all_in)  "all factors which are outside of the calibration, including the ones which are ppf_29"
in_beyond_calib_29_excludeRoot(all_in) "all factors which are outside of the calibration, excluding the ones which are ppf_29"
root_beyond_calib_29(all_in) "all factors which operate the junction between the calibrated CES and the CES which is not calibrated"
ppf_beyondcalib_29(all_in)    "all factors which are not part of in_29"
ces_beyondcalib_29(all_in, all_in) "production relationships for the non calibrated CES"
ces2_beyondcalib_29(all_in, all_in) "production relationships for the non calibrated CES"
ipf_beyond_last(all_in) "intermediary factors which are just above the ppf_beyondcalib_29 level"
ipf_beyond_29(all_in)  "all ces intermediary levels whose inputs are in beyond_calib" 
ipf_beyond_29_excludeRoot(all_in)  "all ces intermediary levels whose inputs are in beyond_calib, excluding the roots" 

te_29_report(all_te)  "set of technologies to report on"
/
  hydro
  ngcc
  ngt
  pc
  apCarDit
  dot
  apCarPet
  apCarElt
  gaschp
  wind
  tnrs
  gastr
  refliq
  biotr
  coaltr
/

*created in order to avoid xi negative in the latest periods. Should not be necessary with post-2100 reasonable FE pathways
t_29(ttot)     "time steps considered in the calibration"
  t_29hist(ttot) "historical periods from 2005 on. Used for setting the efficiencies of FE if calibrated at the UE level"
  t_29hist_last(ttot) "last historical period"
  t_29scen(ttot) "non historical periods in t_29"
  t_29_last(ttot) "last period of the calibration"

pf_eff_target_dyn29(all_in)    "production factors with efficiency target"    / /
pf_quan_target_dyn29(all_in)   "production factors with quantity target"      / /
  
capUnitType  "Type of technological data: for investments or for the standing capital"
/
  cap   "estimate for the standing capital (with some depreciation)"
  inv   "estimate for new investments (without depreciation)" 
/ 
  
index_Nr "index to differentiate data points with identical characteristics"
/
  0 * 62
/

eff_scale_par   "parameters for scaling certain efficiencies during calibration"
/
  level
  midperiod
  width
/
;

alias(cesOut2cesIn_below,cesOut2cesIn_below2);

t_29(ttot) = NO;
t_29(t) = YES;
t_29("2110") = NO;
t_29("2130") = NO;
t_29("2150") = NO;

alias(t_29, t2_29);

t_29hist(ttot) = NO;
t_29hist(t)$(sameAs(t,"2005") OR sameAs(t,"2010") OR sameAs(t,"2015")) = YES;
alias(t_29hist,t_29hist2);

t_29scen(ttot) = NO;
t_29scen(ttot)$t_29(ttot) = YES;
t_29scen(ttot)$t_29hist(ttot) = NO;

$offOrder
 t_29hist_last(ttot) = NO;
 t_29hist_last(t_29hist)$(ord(t_29hist) eq card(t_29hist)) = YES;
 t_29_last(ttot) = NO;
 t_29_last(t_29)$(ord(t_29) eq card(t_29)) = YES;
$onOrder
*** EOF ./modules/29_CES_parameters/calibrate/sets.gms

