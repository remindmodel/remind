*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
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
;

ppf_29("kap") = YES;
ppf_29("lab") = YES;

*** Useful energy
ue_29(all_in) 
  = ue_dyn36(all_in) !! Buildings
  ;
  
*** Fill the sets that need special treatment of efficiencies beyond calib
ue_fe_kap_29(in) = NO;

loop (ue_29(out)$ppf_29(out),
    sm_tmp = 0;
    sm_tmp2 = 0;
    
    loop (cesOut2cesIn(out,in),
        if (ppfKap(in) ,sm_tmp = sm_tmp + 1);
        if (ppfen(in), sm_tmp2 = sm_tmp2 +1);
    );
    
    if (sm_tmp eq 1 AND sm_tmp2 eq 1,  !! in case one input is ppfen/FE and the other Kap
        ue_fe_kap_29(out) = YES;
     else               
     sm_tmp = 0;
     loop (cesOut2cesIn(out,in),
     sm_tmp = sm_tmp +1;
     );
    
    );
        
    
);
 

***Compute the internal sets for the calibration of the CES

*** First, take the maximum level of ppf_29
sm_tmp = 0
 loop(cesLevel2cesIO(counter,in)$ppf_29(in),
if (counter.val gt sm_tmp,
      sm_tmp = counter.val;
    )
);

*** Second, all ppf_29 are part of in_29
loop(ppf,
 in_29(ppf_29) = YES
);

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

in_beyond_calib_29(all_in) = ipf_beyond_29(all_in) + ppf_beyondcalib_29(all_in);
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
p29_fedemand       "final energy demand"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/pm_fe_demand.cs4r"
$offdelim
/

p29_cesdata_price   "exogenous final energy prices"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/p29_cesdata_price.cs4r"
$offdelim
/


p29_esdemand       "energy service demand"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/pm_es_demand.cs4r"
$offdelim
/

$ifthen.edgesm %transport% ==  "edge_esm"
p29_trpdemand       "transport demand"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/pm_trp_demand.cs4r"
$offdelim
/
$endif.edgesm


p29_efficiency_growth       "efficency growth for ppf beyond calibration"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/p29_efficiency_growth.cs4r"
$offdelim

/


f29_capitalUnitProjections "Capital cost per unit of consumed energy and final energy per unit of useful energy (or UE per unit of ES) used to calibrate some elasticities of substitution"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/f29_capitalUnitProjections.cs4r"
$offdelim

/
;

parameter
p29_capitalQuantity                    "capital quantities"
/
$ondelim
$include "./modules/29_CES_parameters/calibrate/input/p29_capitalQuantity.cs4r"
$offdelim
/
;
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
p29_capitalQuantity(tall,all_regi,all_GDPscen,all_in) = p29_capitalQuantity(tall,all_regi,all_GDPscen,all_in) * pm_shPPPMER(all_regi);
p29_capitalUnitProjections(all_regi,all_in,index_Nr)$ppfKap(all_in) = p29_capitalUnitProjections(all_regi,all_in,index_Nr) * pm_shPPPMER(all_regi);

p29_capitalQuantity(tall,all_regi,all_GDPscen,"kap") = p29_capitalQuantity(tall,all_regi,all_GDPscen,"kap") 
                                                       - sum(ppfKap(in)$( NOT sameAs(in,"kap")), p29_capitalQuantity(tall,all_regi,all_GDPscen,in) );
*** Substract the end-use capital quantities from the aggregate capital

*** Change EJ to TWa
$ifthen.industry_subsectors "%industry%" == "subsectors"
  p29_fedemand(tall,all_regi,all_GDPscen,all_in)$( NOT cal_ppf_industry_dyn37(all_in))
    = sm_EJ_2_TWa * p29_fedemand(tall,all_regi,all_GDPscen,all_in);
$else.industry_subsectors
  p29_fedemand(tall,all_regi,all_GDPscen,all_in)
    = sm_EJ_2_TWa * p29_fedemand(tall,all_regi,all_GDPscen,all_in);
$endif.industry_subsectors

p29_fedemand(tall,all_regi,all_GDPscen,all_in)$( sameas(all_in,"ue_steel_primary")
                                                OR sameas(all_in,"ue_steel_secondary") )
  = 1e-3 * p29_fedemand(tall,all_regi,all_GDPscen,all_in);

*** Change million m2.C to trillion m2.C
p29_esdemand(tall,all_regi,all_GDPscen,all_in) = p29_esdemand(tall,all_regi,all_GDPscen,all_in)/sm_mega_2_non *1;

*** Change $/kWh to Trillion$/TWa;
p29_capitalUnitProjections(all_regi,all_in,index_Nr)$ppfKap(all_in) =  p29_capitalUnitProjections(all_regi,all_in,index_Nr) * sm_TWa_2_kWh / sm_trillion_2_non;


*** Load CES parameters parameters from the last run
Execute_Load 'input'  p29_cesdata_load= pm_cesdata;
*** Load quantities and efficiency growth from the last run
Execute_Loadpoint 'input'  p29_cesIO_load = vm_cesIO.l, p29_effGr = vm_effGr.l;

*** Load putty-clay quantities if relevant (initialise to 0 in case it is not)
p29_cesIOdelta_load(t,regi,in) = 0;
if ( (%c_CES_calibration_iteration% gt 1 OR %c_CES_calibration_new_structure% eq 0) AND (card(in_putty) gt 0),
Execute_Loadpoint 'input'  p29_cesIOdelta_load = vm_cesIOdelta.l;
);

*** DEBUG: Load vm_deltacap
Execute_Loadpoint 'input' vm_deltacap;

*** Load exogenous Labour, GDP
pm_cesdata(t,regi,"inco","quantity") = pm_gdp(t,regi);
pm_cesdata(t,regi,"lab","quantity") = pm_lab(t,regi);
*** Load exogenous FE trajectories
pm_cesdata(t,regi,in,"quantity") $ p29_fedemand(t,regi,"%cm_GDPscen%",in) 
           = p29_fedemand(t,regi,"%cm_GDPscen%",in);

*** Load exogenous ES trajectories
pm_cesdata(t,regi,in,"quantity") $ p29_esdemand(t,regi,"%cm_GDPscen%",in) 
           = p29_esdemand(t,regi,"%cm_GDPscen%",in);

*** Load exogenous transport demand - required for the EDGE transport module
$ifthen.edgesm %transport% ==  "edge_esm"
pm_cesdata(t,regi,in,"quantity") $ p29_trpdemand(t,regi,"%cm_GDPscen%","%cm_EDGEtr_scen%", in)
           = p29_trpdemand(t,regi,"%cm_GDPscen%", "%cm_EDGEtr_scen%", in);
$endif.edgesm

*** Load capital quantities
pm_cesdata(t,regi,ppfKap,"quantity") = p29_capitalQuantity(t,regi,"%cm_GDPscen%",ppfKap);

*** Add an epsilon to the values which are 0 so that they can fit in the CES function. And withdraw this epsilon when going to the ESM side

loop((t,regi,in)$ ((ppf(in) OR ppf_29(in) ) AND pm_cesdata(t,regi,in,"quantity") lt 1e-5),
pm_cesdata(t,regi,in,"offset_quantity")  = -1e-5 + pm_cesdata(t,regi,in,"quantity");
pm_cesdata(t,regi,in,"quantity") = 1e-5;
);

*** Capital price assumption
p29_capitalPrice(t,regi) = 0.12;

*** Load capital price assumption for the first iteration, otherwise take it from gdx prices
if( %c_CES_calibration_iteration% = 1 AND %c_CES_calibration_new_structure% = 1,  pm_cesdata(t,regi,"kap","price") = p29_capitalPrice(t,regi));

*** In case there is one capital variable together with an energy variable in a same CES, give them the same efficiency growth pathways

loop (ue_fe_kap_29(out),
        loop ((cesOut2cesIn(out,in),cesOut2cesIn2(out,in2))$(ppfKap(in) AND ppfen(in2)),
        p29_efficiency_growth(t,regi,"%cm_GDPscen%",in) = p29_efficiency_growth(t,regi,"%cm_GDPscen%",in2);
        );
    );

***
loop ( (t0(t),regi, ppfIO_putty(in)),
    if (pm_cesdata(t,regi,in,"quantity") eq 0,
    abort "ppfIO_putty must have an exogenous value for the first period";
    );
);

$ifthen.growth %cm_esubGrowth% ==  "low"
p29_esubGrowth = 0.3;
$elseif.growth %cm_esubGrowth% == "middle"
p29_esubGrowth = 0.5;
$elseif.growth %cm_esubGrowth% == "high"
p29_esubGrowth = 1;
$endif.growth
;
*** EOF ./modules/29_CES_parameters/calibrate/datainput.gms
