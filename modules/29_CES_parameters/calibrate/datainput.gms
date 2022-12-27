*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
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
    if (ppfen(in),  sm_tmp2 = sm_tmp2 + 1);
  );
    
  !! in case one input is ppfen/FE and the other Kap
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

putty_compute_in(in)$((in_29(in) AND ppf_putty(in))
                                         OR (ppf_29(in) and in_putty(in))
                                      )
                                      = YES;

*** End of Sets calculation

Parameter
f29_esdemand(tall,all_regi,all_demScen,all_in)       "energy service demand"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/f29_esdemand.cs4r"
$offdelim
/
;
*** change million m2.C to trillion m2.C
p29_esdemand(t,regi,in) = f29_esdemand(t,regi,"%cm_demScen%",in)/sm_mega_2_non;

Parameter
$ifthen.transpmodule "%transport%" == "edge_esm"
p29_trpdemand       "transport demand"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/pm_trp_demand.cs4r"
$offdelim
/
$endif.transpmodule

f29_efficiency_growth(tall,all_regi,all_demScen,all_in)       "efficency growth for ppf beyond calibration"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/f29_efficiency_growth.cs4r"
$offdelim
/
;
p29_efficiency_growth(t,regi,in) = f29_efficiency_growth(t,regi,"%cm_demScen%",in);

Parameter
f29_capitalUnitProjections "Capital cost per unit of consumed energy and final energy per unit of useful energy (or UE per unit of ES) used to calibrate some elasticities of substitution"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/f29_capitalUnitProjections.cs4r"
$offdelim
/
;

parameter
f29_capitalQuantity(tall,all_regi,all_demScen,all_in)          "capital quantities"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/f29_capitalQuantity.cs4r"
$offdelim
/
;
p29_capitalQuantity(t,regi,ppfKap) = f29_capitalQuantity(t,regi,"%cm_GDPscen%",ppfKap);

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

*** ---- PRELIMINARY ALTERNATIVE FE TRAJECTORIES FOR INDUSTRY ----------------START----------
** Alternative ("handmade") FE trajectory
display pm_fedemand;
Parameter
 p29_fedemand_alt(tall,all_regi,all_GDPscen,all_in)                  "alt final energy demand" 
 ;
Parameter
p29_fedemand_alt       "alt final energy demand"
/
$ondelim
$if "%cm_calibration_FE%" == "medium" $include "./modules/29_CES_parameters/calibrate/input/pm_fe_demand_medium.cs4r"
$offdelim
/
;
$ifthen.cm_calibration_FE NOT "%cm_calibration_FE%" == "off"  !! cm_calibration_FE
$ifthen.industry_subsectors NOT  "%industry%" == "subsectors" !! industry
pm_fedemand(t,regi,ppfen_industry_dyn37) = p29_fedemand_alt(t,regi,"%cm_GDPscen%",ppfen_industry_dyn37);
$endif.industry_subsectors
$endif.cm_calibration_FE
*** ---- PRELIMINARY ALTERNATIVE FE TRAJECTORIES FOR INDUSTRY -----------------END-----------

*** Transport alternative FE trajectory 
$ifthen.module "%transport%" == "complex"
$ifthen.demTtrend "%cm_demTcomplex%" == "fromEDGET"

Parameter
 p29_fedemand_trasp(tall,all_regi,all_GDPscen,all_demScen,EDGE_scenario_all,all_in)  "transport alternative demand for complex module based on EDGE-T"
;

Parameter
p29_fedemand_trasp "transport alternative demand for complex module based on EDGE-T"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/pm_fe_demand_EDGETbased.cs4r"
$offdelim
/
;
$ifthen "%cm_calibration_FE%" == "low"
  pm_fedemand(t,regi,in_dyn35)$(t.val ge 2006) = p29_fedemand_trasp(t,regi,"gdp_SDP","Mix1Wise",in_dyn35);
$elseif "%cm_calibration_FE%" == "medium"
  pm_fedemand(t,regi,in_dyn35)$(t.val ge 2006) = p29_fedemand_trasp(t,regi,"gdp_SSP2","Mix1",in_dyn35);
$elseif "%cm_calibration_FE%" == "high"
  pm_fedemand(t,regi,in_dyn35)$(t.val ge 2006) = p29_fedemand_trasp(t,regi,"gdp_SSP2","Mix1",in_dyn35);
$endif

Parameter
 p29_fedemand_trasp2005_2015(tall,all_regi,all_in)  "transport demand based on complex in 2005"
;

p29_fedemand_trasp2005_2015(t,regi,in_dyn35)$(t.val ge 2005 AND t.val le 2015)= pm_fedemand(t,regi,in_dyn35)$(t.val ge 2005 AND t.val le 2015);

display p29_fedemand_trasp2005_2015;

*** Linear convergence to EDGE-T based values to avoid pre-triangular infeasibility due to IEA balances mismatches
loop(ttot$(ttot.val ge 2005 AND ttot.val le 2015),
       pm_fedemand(ttot,regi,in_dyn35) = p29_fedemand_trasp2005_2015("2005",regi,in_dyn35) + (ttot.val-2005)*(p29_fedemand_trasp2005_2015("2015",regi,in_dyn35)-p29_fedemand_trasp2005_2015("2005",regi,in_dyn35))/10;
);

$endif.demTtrend
$endif.module

display pm_fedemand;

*** setting feh2i equal to 1% of fegai
$ifthen.indst_H2_penetration "%industry%" == "fixed_shares"
pm_fedemand(t,regi,"feh2i")$(t.val ge 2010) = 0.01*pm_fedemand(t,regi,"fegai");
$endif.indst_H2_penetration

display pm_fedemand;

*** Attribute technological data to p29_capitalUnitProjections according to putty-clay
 p29_capitalUnitProjections(all_regi,all_in,index_Nr) =  f29_capitalUnitProjections(all_regi,all_in,index_Nr,"cap") $ ( NOT in_putty(all_in))
                                                         + f29_capitalUnitProjections(all_regi,all_in,index_Nr,"inv") $ ( in_putty(all_in));
loop (cesOut2cesIn(out,in)$ppfKap(in),
loop (cesOut2cesIn2(out,in2),
p29_capitalUnitProjections(all_regi,all_in,index_Nr)$(p29_capitalUnitProjections(all_regi,all_in,index_Nr)
                                                      AND (sameAs(all_in,out) OR sameAs(all_in,in2))
                                                    )                                                      
                                        = p29_capitalUnitProjections(all_regi,all_in,index_Nr)$(p29_capitalUnitProjections(all_regi,in,index_Nr) ge p29_capitalUnitProjections(all_regi,in,"0")
                                        );
);
);                                                        
  
*** Change PPP for MER.
p29_capitalQuantity(tall,all_regi,all_in) 
 = p29_capitalQuantity(tall,all_regi,all_in) 
 * pm_shPPPMER(all_regi);

p29_capitalUnitProjections(all_regi,all_in,index_Nr)$ppfKap(all_in) 
  = p29_capitalUnitProjections(all_regi,all_in,index_Nr) 
  * pm_shPPPMER(all_regi);

*** Subtract "special" capital stocks from gross economy capital stock
p29_capitalQuantity(tall,all_regi,"kap") 
  = p29_capitalQuantity(tall,all_regi,"kap") 
  - sum(ppfKap(in)$( NOT sameAs(in,"kap")), 
      p29_capitalQuantity(tall,all_regi,in)
    );

*** Substract the end-use capital quantities from the aggregate capital

*** Change EJ to TWa
$ifthen.industry_subsectors "%industry%" == "subsectors"
  pm_fedemand(tall,all_regi,all_in)$( 
                              NOT industry_ue_calibration_target_dyn37(all_in) )
  = sm_EJ_2_TWa * pm_fedemand(tall,all_regi,all_in);
$else.industry_subsectors
  pm_fedemand(tall,all_regi,all_in)
    = sm_EJ_2_TWa * pm_fedemand(tall,all_regi,all_in);
$endif.industry_subsectors

*** Change $/kWh to Trillion$/TWa;
p29_capitalUnitProjections(all_regi,all_in,index_Nr)$ppfKap(all_in) =  p29_capitalUnitProjections(all_regi,all_in,index_Nr) * sm_TWa_2_kWh / sm_trillion_2_non;


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

*** Load putty-clay quantities if relevant (initialise to 0 in case it is not)
p29_cesIOdelta_load(t,regi,in) = 0;
if ( (sm_CES_calibration_iteration gt 1 OR s29_CES_calibration_new_structure eq 0) AND (card(in_putty) gt 0),
Execute_Loadpoint 'input'  p29_cesIOdelta_load = vm_cesIOdelta.l;
);

*** DEBUG: Load vm_deltacap
Execute_Loadpoint 'input' vm_deltacap;

*** Load exogenous Labour, GDP
pm_cesdata(t,regi,"inco","quantity") = pm_gdp(t,regi);
pm_cesdata(t,regi,"lab","quantity") = pm_lab(t,regi);
*** Load exogenous FE trajectories
pm_cesdata(t,regi,in,"quantity")$(pm_fedemand(t,regi,in)) = pm_fedemand(t,regi,in);

*** Load exogenous ES trajectories
pm_cesdata(t,regi,in,"quantity") $p29_esdemand(t,regi,in) = p29_esdemand(t,regi,in);

*** Load exogenous transport demand - required for the EDGE transport module
$ifthen.edgesm %transport% ==  "edge_esm"
pm_cesdata(t,regi,in,"quantity") $ p29_trpdemand(t,regi,"%cm_GDPscen%","%cm_demScen%","%cm_EDGEtr_scen%", in)
           = p29_trpdemand(t,regi,"%cm_GDPscen%","%cm_demScen%","%cm_EDGEtr_scen%", in);
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

$ifthen.indst_H2_offset "%industry%" == "fixed_shares"

*** Assuming feh2i minimun levels as 1% of fegai to avoid CES numerical calibration issues and allow more aligned efficiencies between gas and h2
loop ((t,regi)$(pm_cesdata(t,regi,"feh2i","quantity") lt (0.01 * pm_cesdata(t,regi,"fegai","quantity"))),
	pm_cesdata(t,regi,"feh2i","offset_quantity") = - (0.01 * pm_cesdata(t,regi,"fegai","quantity") - pm_cesdata(t,regi,"feh2i","quantity"));
  pm_cesdata(t,regi,"feh2i","quantity") = 0.01 * pm_cesdata(t,regi,"fegai","quantity");
);

*** Special treatment for fehei, which is part of ppfen_industry_dyn37, yet 
*** needs an offset value for some regions under fixed_shares
loop ((t,regi)$(pm_cesdata(t,regi,"fehei","quantity") lt 1e-5 ),
  pm_cesdata(t,regi,"fehei","offset_quantity")  = pm_cesdata(t,regi,"fehei","quantity") - 1e-5;
  pm_cesdata(t,regi,"fehei","quantity") = 1e-5;
);
$endif.indst_H2_offset

$ifthen.build_H2_offset "%buildings%" == "simple"
*** Assuming feh2b minimun levels as 5% of fegab to avoid CES numerical calibration issues and allow more aligned efficiencies between gas and h2
*loop ((t,regi)$(pm_cesdata(t,regi,"feh2b","quantity") lt (0.05 *pm_cesdata(t,regi,"fegab","quantity"))),
*	pm_cesdata(t,regi,"feh2b","offset_quantity") = - (0.05 * pm_cesdata(t,regi,"fegab","quantity") - pm_cesdata(t,regi,"feh2b","quantity"));
*	pm_cesdata(t,regi,"feh2b","quantity") = 0.05 * pm_cesdata(t,regi,"fegab","quantity");
*);

*** RK: feh2b offset scaled from 1% in 2025 to 50% in 2050 of fegab quantity
loop ((t,regi),
	pm_cesdata(t,regi,"feh2b","offset_quantity")
  = - (0.05 + 0.45 * min(1, max(0, (t.val - 2025) / (2050 - 2025))))
      * pm_cesdata(t,regi,"fegab","quantity")
    - pm_cesdata(t,regi,"feh2b","quantity");
	pm_cesdata(t,regi,"feh2b","quantity") 
  = (0.05 + 0.45 * min(1, max(0, (t.val - 2025) / (2050 - 2025))))
      * pm_cesdata(t,regi,"fegab","quantity");
);
$endif.build_H2_offset

*** Add an epsilon to the values which are 0 so that they can fit in the CES 
*** function. And withdraw this epsilon when going to the ESM side
loop((t,regi,in)$(    (ppf(in) OR ppf_29(in)) 
                  AND pm_cesdata(t,regi,in,"quantity") lt 1e-5 
                  AND NOT ppfen_industry_dyn37(in)
                  AND NOT ppfkap_industry_dyn37(in)  
                  AND NOT SAMEAS(in,"feh2i")  
                  AND NOT SAMEAS(in,"feh2b")        ),
  pm_cesdata(t,regi,in,"offset_quantity")  = pm_cesdata(t,regi,in,"quantity")  - 1e-5;
  pm_cesdata(t,regi,in,"quantity") = 1e-5;
);

*** Capital price assumption
p29_capitalPrice(t,regi) = 0.12;

*** Load capital price assumption for the first iteration, otherwise take it from gdx prices
if( sm_CES_calibration_iteration eq 1 AND s29_CES_calibration_new_structure eq 1,  pm_cesdata(t,regi,"kap","price") = p29_capitalPrice(t,regi));

*** In case there is one capital variable together with an energy variable in a same CES, give them the same efficiency growth pathways

loop (ue_fe_kap_29(out),
        loop ((cesOut2cesIn(out,in),cesOut2cesIn2(out,in2))$(ppfKap(in) AND ppfen(in2)),
        p29_efficiency_growth(t,regi,in) = p29_efficiency_growth(t,regi,in2);
        );
    );

***
loop ( (t0(t),regi, ppfIO_putty(in)),
    if (pm_cesdata(t,regi,in,"quantity") eq 0,
    abort "ppfIO_putty must have an exogenous value for the first period";
    );
);

p29_esubGrowth = 0.3;

*** EOF ./modules/29_CES_parameters/calibrate/datainput.gms

