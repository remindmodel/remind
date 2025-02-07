*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/datainput.gms

*** Set dynamic regional set depending on testOneRegi
$ifthen "%optimization%" == "testOneRegi"
regi_dyn29(all_regi) = regi_dyn80(all_regi);
$else
regi_dyn29(all_regi) = regi(all_regi);
$endif


*** Core substitution elasticities
Parameter
  p29_cesdata_sigma(all_in) "substitution elasticities"
  /
    inco        0.5
      en        0.3
  /
;

pm_cesdata_sigma(ttot,in)$p29_cesdata_sigma(in) = p29_cesdata_sigma(in);

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "inco")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "inco")) = 0.15;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "inco")) = 0.20;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "inco")) = 0.30;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "inco")) = 0.40;

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "en")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "en")) = 0.12;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "en")) = 0.15;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "en")) = 0.20;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "en")) = 0.25;



*** Specify the ces structure on which the calibration will run.
ppf_29(all_in)
  = ppfen_dyn35(all_in)
  + cal_ppf_buildings_dyn36(all_in)
  + cal_ppf_industry_dyn37(all_in)
  + industry_ue_calibration_target_dyn37(all_in)
;

ppf_29("kap") = YES;
ppf_29("lab") = YES;

*** Useful energy
ue_29(all_in)
  = ue_dyn36(all_in)                               !! Buildings
  + industry_ue_calibration_target_dyn37(all_in)   !! Industry
;

*** Fill the sets that need special treatment of efficiencies beyond calib
ue_fe_kap_29(in) = NO;

loop (ue_29(ppf_29(out)),
  sm_tmp  = 0;
  sm_tmp2 = 0;

  loop (cesOut2cesIn(out,in),
    if (ppfKap(in), sm_tmp  = sm_tmp  + 1);
    if (ppfEn(in),  sm_tmp2 = sm_tmp2 + 1);
  );

  !! in case one input is ppfEn/FE and the other Kap
  if (sm_tmp eq 1 AND sm_tmp2 eq 1,
    ue_fe_kap_29(out) = YES;
  else
     sm_tmp = 0;
     loop (cesOut2cesIn(out,in),
       sm_tmp = sm_tmp +1;
     );
  );
);

*** Remove sets from ue_fe_kap_29 that receive special treatment
loop (cesOut2cesIn(out,in)$(   pf_eff_target_dyn29(in)
                            OR pf_quan_target_dyn29(in) ),
  ue_fe_kap_29(out) = NO;
);

*** Compute the internal sets for the calibration of the CES

*** First, take the maximum level of ppf_29
sm_tmp = 0
loop(cesLevel2cesIO(counter,ppf_29(in)),
  if (counter.val gt sm_tmp,
    sm_tmp = counter.val;
  );
);

*** Second, all ppf_29 are part of in_29
in_29(ppf_29) = YES

*** Third, include recursively all "out" of ppf_29 in in_29
for (sm_tmp = sm_tmp downto 0,
  loop ((counter,cesOut2cesIn(out,in))$( counter.val eq sm_tmp AND in_29(in)),
    in_29(out) = YES;
  )
);

*** Fourth, calculate intermediate production factors
ipf_29(all_in) = in_29(all_in) - ppf_29(all_in);

ces_29(out,in_29) = cesOut2cesIn(out,in_29);

ppf_beyondcalib_29(all_in) = NO;
ipf_beyond_29(all_in) = NO;

ppf_beyondcalib_29(all_in) = in(all_in) - in_29(all_in);

loop (cesOut2cesIn(out,ppf_beyondcalib_29(in)),
  ipf_beyond_29(out) = YES;
);
ipf_beyond_29_excludeRoot(ipf_beyond_29) = YES;
ipf_beyond_29_excludeRoot(ppf_29) = NO;

in_beyond_calib_29(all_in)
  = ipf_beyond_29(all_in)
  + ppf_beyondcalib_29(all_in);

in_beyond_calib_29_excludeRoot(in_beyond_calib_29) = YES;
in_beyond_calib_29_excludeRoot(ppf_29) = NO;

root_beyond_calib_29(in_beyond_calib_29)$ppf_29(in_beyond_calib_29) = YES;

ces_beyondcalib_29(ipf_beyond_29,in)   = cesOut2cesIn(ipf_beyond_29,in);

ces2_29(out,in) = ces_29(out,in);
ces2_beyondcalib_29(out,in) = ces_beyondcalib_29(out,in);
alias(ipf_29,ipf2_29);

ipf_beyond_last(all_in) = NO;
loop (cesOut2cesIn(out,in)$(in_beyond_calib_29(in) AND ppf(in)),
ipf_beyond_last(out) = YES;
);

*** End of Sets calculation

Parameter
p29_trpdemand       "transport demand"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/f29_trpdemand.cs4r"
$offdelim
/

parameter
f29_capitalQuantity(tall,all_regi,all_demScen,all_in)          "capital quantities"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/f29_capitalQuantity.cs4r"
$offdelim
/
;
p29_capitalQuantity(t,regi,ppfKap) = f29_capitalQuantity(t,regi,"%cm_demScen%",ppfKap);

*** fix industry energy efficiency capital for mrremind rounding
loop ((ttot,regi,ppfKap_industry_dyn37(in))$( t(ttot-1) AND t(ttot+1) ),
  sm_tmp
  = p29_capitalQuantity(ttot-1,regi,in)
  * ( (1 - pm_delta_kap(regi,in))
   ** (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
    );

  if (p29_capitalQuantity(ttot,regi,in) lt sm_tmp,
    p29_capitalQuantity(ttot,regi,in)
    = ( p29_capitalQuantity(ttot-1,regi,in)
      + p29_capitalQuantity(ttot+1,regi,in)
      )
    / 2;
  );
);

display pm_fedemand;

*** Change PPP for MER.
p29_capitalQuantity(tall,all_regi,all_in)
 = p29_capitalQuantity(tall,all_regi,all_in)
 * pm_shPPPMER(all_regi);

*** Subtract "special" capital stocks from gross economy capital stock
p29_capitalQuantity(tall,all_regi,"kap")
  = p29_capitalQuantity(tall,all_regi,"kap")
  - sum(ppfKap(in)$( NOT sameAs(in,"kap")),
      p29_capitalQuantity(tall,all_regi,in)
    );

*** Substract the end-use capital quantities from the aggregate capital

*** Load CES parameters from the last run
Execute_Load 'input'  p29_cesdata_load = pm_cesdata;
$ifthen.testOneRegi "%optimization%" == "testOneRegi"   !! optimization
  !! carry along CES parameters for other regions in testOneRegi runs
  pm_cesdata(t,regi,in,cesParameter)$( NOT regi_dyn29(regi) )
  = p29_cesdata_load(t,regi,in,cesParameter);
$endif.testOneRegi

*** FS: if some elasticities are 0 because they are not part of the input gdx, -> set them to 0.5 to avoid divsion by 0
p29_cesdata_load(t,regi,in,"rho")$( p29_cesdata_load(t,regi,in,"rho") eq 0) = 0.5;

*** Load quantities and efficiency growth from the last run
Execute_Loadpoint 'input'  p29_cesIO_load = vm_cesIO.l, p29_effGr = vm_effGr.l;

Execute_Loadpoint 'input' vm_deltaCap;

*** Load exogenous Labour, GDP
pm_cesdata(t,regi,"inco","quantity") = pm_gdp(t,regi);
pm_cesdata(t,regi,"lab","quantity") = pm_lab(t,regi);
*** Load exogenous FE trajectories
*** Change EJ to TWa

pm_cesdata(t,regi,in,"quantity")$(pm_fedemand(t,regi,in)) =
$ifthen.industry_subsectors "%industry%" == "subsectors"
  pm_fedemand(t,regi,in)$(industry_ue_calibration_target_dyn37(in))
  +
  sm_EJ_2_TWa * pm_fedemand(t,regi,in)$(NOT industry_ue_calibration_target_dyn37(in));
$else.industry_subsectors
  sm_EJ_2_TWa * pm_fedemand(t,regi,in)
$endif.industry_subsectors

*** Load exogenous transport demand - required for the EDGE transport module
$ifthen.edgesm %transport% ==  "edge_esm"
pm_cesdata(t,regi,in,"quantity") $ p29_trpdemand(t,regi,"%cm_GDPpopScen%","%cm_demScen%","%cm_EDGEtr_scen%", in)
           = p29_trpdemand(t,regi,"%cm_GDPpopScen%","%cm_demScen%","%cm_EDGEtr_scen%", in);
$endif.edgesm

*** Load capital quantities
pm_cesdata(t,regi,ppfKap,"quantity") = p29_capitalQuantity(t,regi,ppfKap);

$ifthen.subsectors "%industry%" == "subsectors"
*** Assume fehe_otherInd at 0.1% of fega_otherInd for regions with zero
*** fehe_otherInd in historic periods (IND, LAM, MEA, SSA)
loop ((t_29hist(t),regi_dyn29(regi))$(
                           pm_cesdata(t,regi,"fehe_otherInd","quantity") eq 0 ),
  pm_cesdata(t,regi,"fehe_otherInd","quantity")
  = 1e-4
  * pm_cesdata(t,regi,"fega_otherInd","quantity");

  pm_cesdata(t,regi,"fehe_otherInd","offset_quantity")
  = -pm_cesdata(t,regi,"fehe_otherInd","quantity");
);

*** Use offset quantity for regions with no production/energy use in certain
*** subsectors (e.g. no primary steel production in NEN)
loop ((t,regi_dyn29(regi)),
  loop (ue_industry_dyn37(out)$( pm_cesdata(t,regi,out,"quantity") eq 0 ),
    pm_cesdata(t,regi,out,"quantity") = 1e-6;
    pm_cesdata(t,regi,out,"offset_quantity")
    = -pm_cesdata(t,regi,out,"quantity");

    if (sum(ces_eff_target_dyn37(out,in), pm_cesdata(t,regi,in,"quantity")) eq 0,
      loop (ces_eff_target_dyn37(out,in),
        pm_cesdata(t,regi,in,"quantity") = 1e-6;
	pm_cesdata(t,regi,in,"offset_quantity")
	= -pm_cesdata(t,regi,in,"quantity");
      );
    );
  );
);

*** Use offset quantities for historic industry H2/HTH_el use, since it actually
*** did not happen.
loop (pf_quantity_shares_37(in,in2),
  pm_cesdata(t_29hist(t),regi_dyn29(regi),in,"offset_quantity")$(
                                  pm_cesdata(t,regi,in,"offset_quantity") eq 0 )
  = -pm_cesdata(t,regi,in,"quantity");
);
$endif.subsectors


$ifthen.build_H2_offset "%buildings%" == "simple"
*** Assuming feh2b minimun levels as 5% of fegab to avoid CES numerical calibration issues and allow more aligned efficiencies between gas and h2
*loop ((t,regi)$(pm_cesdata(t,regi,"feh2b","quantity") lt (0.05 *pm_cesdata(t,regi,"fegab","quantity"))),
*	pm_cesdata(t,regi,"feh2b","offset_quantity") = - (0.05 * pm_cesdata(t,regi,"fegab","quantity") - pm_cesdata(t,regi,"feh2b","quantity"));
*	pm_cesdata(t,regi,"feh2b","quantity") = 0.05 * pm_cesdata(t,regi,"fegab","quantity");
*);

*** RK: feh2b offset scaled from 1% in 2025 to 50% in 2050 of fegab quantity
pm_cesdata(t,regi,"feh2b","offset_quantity")$(t.val gt cm_H2InBuildOnlyAfter) =
  - (0.05 + 0.45 * min(1, max(0, (t.val - 2025) / (2050 - 2025))))
    * pm_cesdata(t,regi,"fegab","quantity")
  - pm_cesdata(t,regi,"feh2b","quantity");
pm_cesdata(t,regi,"feh2b","quantity")$(t.val gt cm_H2InBuildOnlyAfter) = 
  (0.05 + 0.45 * min(1, max(0, (t.val - 2025) / (2050 - 2025))))
    * pm_cesdata(t,regi,"fegab","quantity");

*** for the years that H2 buildings is fixed to zero, set offset to the exact value of the calibrated quantity to ignore it after calibration
pm_cesdata(t,regi,"feh2b","quantity")$(t.val le cm_H2InBuildOnlyAfter) = 1e-6;
pm_cesdata(t,regi,"feh2b","offset_quantity")$(t.val le cm_H2InBuildOnlyAfter) = - pm_cesdata(t,regi,"feh2b","quantity");

$endif.build_H2_offset

*** Add an epsilon to the values which are 0 so that they can fit in the CES
*** function. And withdraw this epsilon when going to the ESM side
loop((t,regi,in)$(    (ppf(in) OR ppf_29(in))
                  AND pm_cesdata(t,regi,in,"quantity") lt 1e-5
                  AND NOT ppfen_industry_dyn37(in)
                  AND NOT ppfKap_industry_dyn37(in)
                  AND NOT SAMEAS(in,"feh2b")        ),
  pm_cesdata(t,regi,in,"offset_quantity")  = pm_cesdata(t,regi,in,"quantity")  - 1e-5;
  pm_cesdata(t,regi,in,"quantity") = 1e-5;
);

*** Capital price assumption
p29_capitalPrice(t,regi) = 0.12;

*** Load capital price assumption for the first iteration, otherwise take it from gdx prices
if( sm_CES_calibration_iteration eq 1 AND s29_CES_calibration_new_structure eq 1,  pm_cesdata(t,regi,"kap","price") = p29_capitalPrice(t,regi));

p29_esubGrowth = 0.3;

*** EOF ./modules/29_CES_parameters/calibrate/datainput.gms

