*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/preloop.gms
$OFForder


*** ==================================================================================
***
*** For a documentation of this file, see the goxygen documentation, chapter
***       CES parameters (29_CES_parameters) / Realizations / (A) Calibrate
***
*** For a practical calibration tutorial, see 12_Calibrating_CES_Parameters.md
*** in the tutorials folder
***
*** ==================================================================================


option pm_cesdata:4:3:1;
display "check sets production function 29", ces_29, in_29, ppf_29, ipf_29,
        ppf_beyondcalib_29, ipf_beyond_29;
display "check starting pm_cesdata", pm_cesdata;

*** Abort if new structure flag is not set but should be
$ifthen.old_structure %c_CES_calibration_new_structure% == "0"
Execute_Load 'input'  ces2_29=cesOut2cesIn;
sm_tmp = 0;
loop ( ces2_29(out,in)$( NOT cesOut2cesIn2(out,in) ), sm_tmp = 1);
loop (cesOut2cesIn2(out,in)$( NOT  ces2_29(out,in) ), sm_tmp = 1);
if (sm_tmp,
  execute_unload "abort.gdx";
  abort "CES structure does not match. Enable c_CES_calibration_new_structure";
);

Execute_Load 'input'  regi_29_load=regi;
sm_tmp = 0;
loop ( regi_29_load(regi2)$( NOT regi(regi2) ), sm_tmp = 1);
loop (regi(regi2)$( NOT  regi_29_load(regi2) ), sm_tmp = 1);
if (sm_tmp,
  execute_unload "abort.gdx";
  abort "Regional structure does not match. Enable c_CES_calibration_new_structure";
);
$endif.old_structure


***_____________________________START OF:  1 - CALCULATE PRICES _____________________________
*** In the first iteration with a changed CES structure, ppf prices are set to an initial default.
if( sm_CES_calibration_iteration eq 1 and s29_CES_calibration_new_structure eq 1,
  !! Set CES prices to the value specified by cm_CES_calibration_default_prices
  !! and abort if cm_CES_calibration_default_prices == 0
$ifthen.default_prices %cm_CES_calibration_default_prices% == "0"
    abort "Please set cm_CES_calibration_default_prices > 0 to get the calibration started";
$endif.default_prices
  pm_cesdata(t,regi,all_in,"price") = %cm_CES_calibration_default_prices%;

  pm_cesdata(t,regi,ipf_29,"price") = 1;

  pm_cesdata(t,regi,industry_ue_calibration_target_dyn37(in),"price")$(
                                            pm_cesdata(t,regi,in,"price") eq 1 )
    = %cm_CES_calibration_default_prices%;

else
  !! If not first iteration with unknown CES structure, compute ppf prices from CES derivatives loaded from file

  !! Compute prices of each node from CES derivatives of previous run:
  !! d(V_o)/d(V_i) = pi_i  = xi_i * eff_i * effGr_i * V_o**(1-rho_o)  *  (eff_i * effGr_i * V_i)**(rho_o-1)
  p29_CESderivative(t,regi_dyn29(regi),ces_29(out,in))$(p29_cesIO_load(t,regi,in))
    = p29_cesdata_load(t,regi,in,"xi")
    * p29_cesdata_load(t,regi,in,"eff")
    * p29_effGr(t,regi,in)
    * p29_cesIO_load(t,regi,out)

    ** (1 - p29_cesdata_load(t,regi,out,"rho"))

    * exp(
         log(
             p29_cesdata_load(t,regi,in,"eff")
           * p29_effGr(t,regi,in)
           * p29_cesIO_load(t,regi,in)
         )
       * (p29_cesdata_load(t,regi,out,"rho") - 1)
        );

  !! Propagate price down the CES tree to get prices in terms of inco,
  !! i.e. calc d(inco)/d(in) by applying the chain rule (product of node derivatives)
  !! Going down, iteratively compute each income derivative as product of all prices in branch above
  !! Ppf prices will later be used as: pm_cesdata(in,"price") = p29_CESderivative("inco",in).
  !! the rest is discarded.
  loop ((cesLevel2cesIO(counter,in),ces_29(in,in2),ces2_29(in2,in3)),
      !! in3 is the current node, in2 is the node above.
      p29_CESderivative(t,regi_dyn29(regi),"inco",in3) !!   d(inco)/d(in3)
      = p29_CESderivative(t,regi,"inco",in2)           !! = d(inco)/d(in2)
      * p29_CESderivative(t,regi,in2,in3);             !! * d(in2 )/d(in3)
  );


  !! Prices of intermediate production factors are all set to 1,
  !! To account for the chain rule multiplication above.
  loop ( cesOut2cesIn(in2,in),
    p29_CESderivative(t,regi_dyn29(regi),out,ipf_29(in2))$(
                                              p29_CESderivative(t,regi,out,in2) )
    = 1;
  );
  !! Price of inco is 1
  p29_cesdata_load(t,regi_dyn29(regi),"inco","price") = 1;   !! unit price

  !! Transfer prices
  pm_cesdata(t,regi_dyn29(regi), in, "price") =
  p29_CESderivative(t,regi,"inco",in);

  option
    p29_CESderivative:3:3:1
    pm_cesdata:3:3:1
  ;

  !! The calibration of elasticities of substitution takes
  !! much longer to converge if it starts from a high elasticity of
  !! substitution. To avoid this situation, the price of the capital stock
  !! is increased
  if (sm_CES_calibration_iteration eq 1,
    loop (cesOut2cesIn(out,in)$(pm_cesdata_sigma("2015",out) eq -1 AND ppfKap(in) AND in_29(in)),
        pm_cesdata(t,regi,in,"price") = pm_cesdata(t,regi,in,"price") *1.3;
    );
  );

  display "derivatives", p29_CESderivative, p29_effGr, p29_cesIO_load;

  !! Write prices to file and abort, to use them in calibration with differing
  !! CES structure
$ifthen.write_prices %c_CES_calibration_write_prices% == "1"
  file file_pm_cesdata_price /"pm_cesdata_price"/;

  file_pm_cesdata_price.lw =  0;
  file_pm_cesdata_price.nw = 20;
  file_pm_cesdata_price.nd = 15;

  put file_pm_cesdata_price;

  loop ((ttot,regi_dyn29(regi),ppf_29(in)),
    if (ttot.val ge 2005 AND p29_cesdata_load(ttot,regi,in,"price") gt 0,
      put p29_cesdata_load.tn(ttot,regi,in,"price"), " = ";
      put p29_cesdata_load(ttot,regi,in,"price"), ";" /;
    );
  );

  putclose file_pm_cesdata_price;

  abort "wrote pm_cesdata_price as by c_CES_calibration_write_prices setting" ;
$endif.write_prices
)

*** Abort if any ppf prices are <= 0
if (smin((t,regi_dyn29(regi),ppf_29(in)), pm_cesdata(t,regi,in,"price")) le 0,
  put logfile;
  loop ((t,regi_dyn29(regi),ppf_29(in))$( pm_cesdata(t,regi,in,"price") le 0 ),
    put pm_cesdata.tn(t,regi,in,"price"), " = ", pm_cesdata(t,regi,in,"price") /;
  );
  execute_unload "abort.gdx";
  abort "Some ppf prices are <= 0. Check ./modules/29_CES_parameters/calibrate/input/pm_cesdata_price_XXX.inc!";
);

*** Write prices to file
if (sm_CES_calibration_iteration eq 1, !! first CES calibration iteration
  put file_CES_calibration;

  loop ((t,regi_dyn29(regi),in)$(    ppf_29(in)
                                  OR sameas(in,"inco")
                                  OR ppf_beyondcalib_29(in)
                                  OR sameas(in,"enhb")
                                  OR sameas(in,"enhgab")       ),
    if ((ppf_29(in) OR sameas(in,"inco")),
      put "%c_expname%", "origin", t.tl, regi.tl, "quantity",   in.tl;
      put p29_cesIO_load(t,regi,in) /;

      put "%c_expname%", "origin", t.tl, regi.tl, "price",      in.tl;
      put pm_cesdata(t,regi,in,"price") /;

      if (p29_cesdata_load("2005",regi,in,"eff") AND p29_effGr(t,regi,in),
        put "%c_expname%", "origin", t.tl, regi.tl, "total efficiency", in.tl;
        put ( sum(cesOut2cesIn(out,in),
                p29_cesdata_load(t,regi,in,"xi")
             ** (1 / p29_cesdata_load(t,regi,out,"rho"))
              * ( p29_cesdata_load("2005",regi,in,"eff")
                * p29_effGr(t,regi,in)
                )
              )
            ) /;
      );
    );

    put "%c_expname%", "origin", t.tl, regi.tl, "efficiency", in.tl;
    put (p29_cesdata_load("2005",regi,in,"eff") * p29_effGr(t,regi,in)) /;

    put "%c_expname%", "origin", t.tl, regi.tl, "efficiency growth", in.tl;
    put p29_effGr(t,regi,in) /;

    put "%c_expname%", "origin", t.tl, regi.tl, "xi", in.tl;
    put p29_cesdata_load(t,regi,in,"xi") /;
  );

  loop ((ttot,regi_dyn29(regi),te_29_report),
    put "%c_expname%", "origin", ttot.tl, regi.tl, "vm_deltaCap";
    put te_29_report.tl;
    put sum(rlf,vm_deltaCap.L(ttot,regi,te_29_report,rlf)) /;
  );
  putclose file_CES_calibration;
);
option pm_cesdata:4:3:1;
display "loaded", pm_cesdata;


*** # Abort if any prices are zero or negative
sm_tmp = 0;
put logfile;
loop ((t_29(t),regi_dyn29(regi),ppf_29(in))$(
                                           pm_cesdata(t,regi,in,"price") le 0 ),
  put pm_cesdata.tn(t,regi,in,"price"), " = ", pm_cesdata(t,regi,in,"price") /;
  sm_tmp = 1;
);
putclose logfile;

if (sm_tmp eq 1,
  execute_unload "abort.gdx";
  abort "some prices are negative. See log file";
);

display "before price smoothing", cesOut2cesIn_below, pm_cesdata;
*** Smooth 2005 prices
pm_cesdata("2005",regi_dyn29(regi),in_29,"price")$( ppf_29(in_29) )
  = ( pm_cesdata("2010",regi,in_29,"price") * 2
    + pm_cesdata("2015",regi,in_29,"price")
    )
  / 3;

*** Smooth non 2005 prices with moving average
pm_cesdata(t,regi,in_29,"price")$(    (NOT (ord(t) le 1 OR ord(t) eq card(t)))
                                  AND ppf_29(in_29) )
  = ( pm_cesdata(t-1,regi,in_29,"price") / 8
    + pm_cesdata(t,  regi,in_29,"price")
    + pm_cesdata(t+1,regi,in_29,"price") / 8
    ) / 1.25;

*** Further smooth prices from 2005-2020 by calculating a linear fit
*** price_fit = alpha + beta * t
*** and then taking the arithmetic mean of the unsmoothed price and the linear fit

*** compute beta = cov(price,t) / var(t)
*** (search linear regression for more info)
p29_beta(regi_dyn29(regi),in_29)$( ppf_29(in_29) )
  = ( ((2020 - 2000) / 5)
    * sum(ttot$( ttot.val ge 2005 AND ttot.val le 2020 ),
        ttot.val
      * pm_cesdata(ttot,regi,in_29,"price")
      )
    - ( sum(ttot$( ttot.val ge 2005 AND ttot.val le 2020 ), ttot.val)
      * sum(ttot$( ttot.val ge 2005 AND ttot.val le 2020 ),
          pm_cesdata(ttot,regi,in_29,"price")
        )
      )
    )
  / ( ((2020 - 2000) / 5)
    * sum(ttot$( ttot.val ge 2005 AND ttot.val le 2020 ), sqr(ttot.val))
    - sqr(sum(ttot$( ttot.val ge 2005 AND ttot.val le 2020 ), ttot.val))
    );

*** compute alpha = avg(price) - beta * avg(t)
p29_alpha(regi_dyn29(regi),in_29)$(ppf_29(in_29))
  = ( sum(ttot$( ttot.val ge 2005 AND ttot.val le 2020 ),
        pm_cesdata(ttot,regi,in_29,"price")
      )
    - p29_beta(regi,in_29)
    * sum(ttot$( ttot.val ge 2005 AND ttot.val le 2020 ), ttot.val)
    )
  / ((2020 - 2000) / 5);

Display p29_alpha, p29_beta;


*** for entrp_frgt_lo (energy transport - freight transport - long distance)
*** pass on to pm_cesdata and ensure the resulting price is positive
$ifthen.edge_esm %transport% == "edge_esm"

loop (ttot$( ttot.val ge 2005 AND ttot.val lt 2020 ),
  pm_cesdata(ttot,regi_dyn29(regi),"entrp_frgt_lo","price")
  = max(
  1e-4,
    ( pm_cesdata(ttot,regi,"entrp_frgt_lo","price")
    + p29_alpha(regi,"entrp_frgt_lo")
    + p29_beta(regi,"entrp_frgt_lo") * ttot.val
    )
  / 2
  );
);

*** Set minimal price for all periods
loop (ttot$( ttot.val ge 2005),
  pm_cesdata(ttot,regi_dyn29(regi),"entrp_frgt_lo","price")
  = max(
    1e-4,
    pm_cesdata(ttot,regi,"entrp_frgt_lo","price")
    );
);

display "after entrp_frgt_lo smoothening", pm_cesdata;

$endif.edge_esm

*** for all other modes
*** pass on to pm_cesdata and ensure the resulting price is positive
loop (ttot$( ttot.val ge 2005 AND ttot.val lt 2020),
  pm_cesdata(ttot,regi_dyn29(regi),in_29,"price")$(ppf_29(in_29) AND (NOT sameas(in_29, "entrp_frgt_lo")))
  = max(
    1e-2,
    ( pm_cesdata(ttot,regi,in_29,"price")
      + p29_alpha(regi,in_29) + p29_beta(regi,in_29) * ttot.val
      )
    / 2
  );
);

*** Set minimal price for all periods
loop (ttot$( ttot.val ge 2005),
  pm_cesdata(ttot,regi_dyn29(regi),in_29,"price")$( ppf_29(in_29) AND (NOT sameas(in_29,"entrp_frgt_lo")) )
  = max(
    ( 1e-2$( NOT in_industry_dyn37(in_29) )
    + 1e-4$(     in_industry_dyn37(in_29) )
    ),
    pm_cesdata(ttot,regi,in_29,"price")
  );
);

display "after all but entrp_frgt_lo smoothening", pm_cesdata;

display "after price smoothing",  cesOut2cesIn_below;

***_____________________________ END OF:  1 - CALCULATE PRICES _____________________________

***_____________________________ START OF:  2 - CALCULATE QUANTITIES_____________________________

*** All effGr, are set to one, so that we can focus on efficiencies
*** we will split xi and eff evolutions later and pass it on to effGr
pm_cesdata(t,regi_dyn29,in_29,"effGr") = 1;

*** First, using the prices and quantities of the ppfEn, the prices of ipf
*** we compute thanks to the Euler equation the quantities of the ipf.
*** we compute quantities for everything up to the last CES level inco.(lab,kap,en)

!! Write to file
if (sm_CES_calibration_iteration eq 1, !! first CES calibration iteration
  put file_CES_calibration;

  loop ((t,regi_dyn29(regi),in)$(    ppf_29(in)
                                  OR sameas(in,"inco")
                                  OR ppf_beyondcalib_29(in)
                                  OR sameas(in,"enhb")
                                  OR sameas(in,"enhgab")       ),
    if ((ppf_29(in) OR sameas(in,"inco")),
      put "%c_expname%", "target", t.tl, regi.tl, "quantity",   in.tl;
      put pm_cesdata(t,regi,in,"quantity") /;
    );
  );

  loop ((t_29hist(t),regi_dyn29(regi),ppf_beyondcalib_29(in)),
    put "%c_expname%", "target", t.tl, regi.tl, "quantity", in.tl;
    put pm_cesdata(t,regi,in,"quantity") /;
  );

$ifthen.subsectors "%industry%" == "subsectors"
$ifthen.industry_FE_target "%c_CES_calibration_industry_FE_target%" == "1"
  loop((t_29scen(t),regi_dyn29(regi),in)$(   ppfen_industry_dyn37(in)
                                          OR ppfKap_industry_dyn37(in) ),
    put "%c_expname%", "target", t.tl, regi.tl, "quantity", in.tl;
    put pm_cesdata(t,regi,in,"quantity") /;
  );
$endif.industry_FE_target
$endif.subsectors

  putclose file_CES_calibration;
);

loop  ((t,cesRev2cesIO(counter,ipf_29(out)))$( NOT (  sameas(out,"inco")) ),
  pm_cesdata(t,regi_dyn29,out,"quantity")
  = sum(cesOut2cesIn(out,in),
      pm_cesdata(t,regi_dyn29,in,"price")
    * pm_cesdata(t,regi_dyn29,in,"quantity")
    );
);
*** Ensure that the labour share in GDP is at least 20 % for historical periods
*** and 0.5 % for others.
sm_tmp  = 0;
sm_tmp2 = 0;

put logfile;
loop ((t_29hist(t),regi_dyn29(regi)),
  sm_tmp
  = sum(in$(sameAs(in, "kap") OR sameAs(in,"en")),
      pm_cesdata(t,regi,in,"quantity")
    * pm_cesdata(t,regi,in,"price")
    )
    / pm_cesdata(t,regi,"inco","quantity");


   if ( (0.8$( t_29hist(t) ) + 0.995$( NOT t_29hist(t) )) lt sm_tmp,

   put t.tl, " ", regi.tl, " labour share in GDP: ", (1 - sm_tmp);

     pm_cesdata(t,regi,ppf_29(in),"price") $ ( NOT sameAs(in, "lab"))
     = pm_cesdata(t,regi,in,"price")
     * (0.8$( t_29hist(t) ) + 0.995$( NOT t_29hist(t) ))
     / sm_tmp;

     put " -> ", (1 - (0.8$( t_29hist(t) ) + 0.995$( NOT t_29hist(t) ))) /;
     sm_tmp2 = sm_tmp2 + 1;
     );
);
putclose logfile;
!! If there has been a rescaling for historical steps, repeat previous steps with new prices
if ( sm_tmp2 gt 0, !! If there has been a rescaling

  loop  ((t,cesRev2cesIO(counter,ipf_29(out)))$( NOT ( sameas(out,"inco"))),

    pm_cesdata(t,regi_dyn29,out,"quantity")
    = sum(cesOut2cesIn(out,in),
        pm_cesdata(t,regi_dyn29,in,"price")
      * pm_cesdata(t,regi_dyn29,in,"quantity")
      );
  );   
);

***_____________________________ END OF:  2 - CALCULATE QUANTITIES_____________________________

***_____________________________ START OF: 3 - CALCULATE EFFICIENCIES _____________________________

*** We ensure that the prices correspond to the derivatives, because
*** the Euler equation holds for derivatives. Using prices makes only sense if
*** prices equal derivatives.
loop  ((cesRev2cesIO(counter,ipf_29(out)),ces_29(out,in))$(
                                                    NOT sameas(out,"inco") ),
    pm_cesdata(t,regi_dyn29, in,"xi")
      = pm_cesdata(t,regi_dyn29,in,"price")
      * pm_cesdata(t,regi_dyn29,in,"quantity")
      / pm_cesdata(t,regi_dyn29,out,"quantity");

   pm_cesdata(t,regi_dyn29,in,"eff")
      = pm_cesdata(t,regi_dyn29,out, "quantity")
      / pm_cesdata(t,regi_dyn29,in, "quantity");
);
display "after change up to en consistency", pm_cesdata;

***_____________________________ END OF: 3 - CALCULATE EFFICIENCIES _____________________________

***_____________________________ START OF: 4 - ADJUST LABOUR PRICE to GDP _____________________________

*** Then, we consider the top level of the CES tree, where capital and labor
*** have specific restrictions. Capital works as for the other ppfen, Labour
*** will be the adjustment variable to meet inco. xi will not be equal to the
*** income share of capital (from equation price = derivative)

pm_cesdata(t,regi_dyn29,"kap","xi")
  = pm_cesdata(t,regi_dyn29,"kap","price")
  * pm_cesdata(t,regi_dyn29,"kap","quantity")
  / pm_cesdata(t,regi_dyn29,"inco","quantity");

pm_cesdata(t,regi_dyn29,"kap","eff")
  = pm_cesdata(t,regi_dyn29,"inco", "quantity")
  / pm_cesdata(t,regi_dyn29,"kap", "quantity");

display "after change cap eff consistency", pm_cesdata;

*** If the value (quantity x price) of either en or kap, or the sum of both,
*** exceed the quantity of inco (all of which would result in negative labour
*** prices), scale these prices down accordingly, and warn this is happening.
if (smax((t,regi_dyn29(regi)),
       sum(cesOut2cesIn("inco",in)$( NOT sameas(in,"lab") ),
         pm_cesdata(t,regi,in,"quantity")
       * pm_cesdata(t,regi,in,"price")
       )
     / pm_cesdata(t,regi,"inco","quantity")
     ) gt 1,   !! does the sum of en and cap exceed inco?
  put logfile, ">>> Warning: Rescaling en and kap prices as their combined ",
               "value exceeds inco <<<" /;
  loop ((t,regi_dyn29(regi)),
    sm_tmp   !! by how much does en + kap exceed inco?
    = ( (  pm_cesdata(t,regi,"en","quantity")
         * pm_cesdata(t,regi,"en","price")
        )
      + (  pm_cesdata(t,regi,"kap","quantity")
         * pm_cesdata(t,regi,"kap","price")
        )
      )
     / pm_cesdata(t,regi,"inco","quantity");

    if (sm_tmp > 1,
      put "  ", t.tl, " ", regi.tl, "   ",
          pm_cesdata(t,regi,"en","quantity"), " x ",
          pm_cesdata(t,regi,"en","price"), " + ",
          pm_cesdata(t,regi,"kap","quantity"), " x ",
          pm_cesdata(t,regi,"kap","price"), " > ",
          pm_cesdata(t,regi,"inco","quantity"), " -> ";

      sm_tmp2
      = ( pm_cesdata(t,regi,"inco","quantity")
        - ( pm_cesdata(t,regi,"lab","quantity")
          * pm_cesdata(t,regi,"lab","price")
          )
        )
      / ( ( pm_cesdata(t,regi,"en","quantity")
          * pm_cesdata(t,regi,"en","price")
          )
        + ( pm_cesdata(t,regi,"kap","quantity")
          * pm_cesdata(t,regi,"kap","price")
          )
        );

      pm_cesdata(t,regi,"en","price")
      = pm_cesdata(t,regi,"en","price")
      * sm_tmp2;

      pm_cesdata(t,regi,"kap","price")
      = pm_cesdata(t,regi,"kap","price")
      * sm_tmp2;

      put pm_cesdata(t,regi,"en","price"), ", ",
          pm_cesdata(t,regi,"kap","price") /;
    );
  );
  putclose logfile, " " /;
);

!! do either en or kap exceed inco?
loop (cesOut2cesIn("inco",in)$( NOT sameas(in,"lab") ),
  if (smax((t,regi_dyn29(regi)),
        pm_cesdata(t,regi,in,"quantity")
      * pm_cesdata(t,regi,in,"price")
      / pm_cesdata(t,regi,"inco","quantity")
      ) gt 1,
    put logfile, ">>> Warning: Rescaling ", in.tl, " prices as its value ",
                 "exceedes inco <<<" /;
    loop ((t,regi_dyn29(regi)),
           sm_tmp
           = pm_cesdata(t,regi,in,"quantity")
           * pm_cesdata(t,regi,in,"price")
           / pm_cesdata(t,regi,"inco","quantity");

          if (sm_tmp gt 1,
              put "  ", t.tl, " ", regi.tl, in.tl:>4, "   ",
               pm_cesdata(t,regi,in,"quantity"), " x ",
               pm_cesdata(t,regi,in,"price"), " > ",
               pm_cesdata(t,regi,"inco","quantity"), " -> ";

               pm_cesdata(t,regi,in,"price")
            = ( pm_cesdata(t,regi,"inco","quantity")
              - sum(cesOut2cesIn2("inco",in2)$( NOT sameas(in,in2) ),
                  pm_cesdata(t,regi,in2,"quantity")
                * pm_cesdata(t,regi,in2,"price")
                )
              )
             / pm_cesdata(t,regi,in,"quantity");

            put pm_cesdata(t,regi,in,"price") /;
         );
    );
    putclose logfile, " " /;
  );
);

*** Second, adjust the price of labour, so that, whithout changing the price of
*** energy, the Euler equation holds.
pm_cesdata(t,regi_dyn29,"lab","price")
  = ( pm_cesdata(t,regi_dyn29,"inco","quantity")
    - sum(cesOut2cesIn("inco",in)$( NOT sameas(in,"lab") ),
        pm_cesdata(t,regi_dyn29,in,"price")
      * pm_cesdata(t,regi_dyn29,in,"quantity")
      )
    )
  / pm_cesdata(t,regi_dyn29,"lab","quantity")
;

*** Fourth, adjust eff and xi of labour, energy, and capital, so that the price
*** matches the derivative.
loop ((t,regi_dyn29,ces_29("inco",in)),
  pm_cesdata(t,regi_dyn29,in,"xi")
  = pm_cesdata(t,regi_dyn29,in,"price")
  * pm_cesdata(t,regi_dyn29,in,"quantity")
  / pm_cesdata(t,regi_dyn29,"inco","quantity");

  pm_cesdata(t,regi_dyn29,in,"eff")
  = pm_cesdata(t,regi_dyn29,"inco","quantity")
  / pm_cesdata(t,regi_dyn29,in,"quantity");
);

*** Assert xi gt 0
sm_tmp = 0;
loop ((t,regi_dyn29(regi),in_29)$(
                                     pm_cesdata(t,regi,in_29,"xi")       le 0
                                 AND pm_cesdata(t,regi,in_29,"quantity") gt 0
                                 AND NOT sameas(in_29,"inco")                 ),
  sm_tmp = 1;
);

if (sm_tmp,
  put logfile;
  loop ((t,regi_dyn29(regi),in_29)$(
                                     pm_cesdata(t,regi,in_29,"xi")       le 0
                                 AND pm_cesdata(t,regi,in_29,"quantity") gt 0
                                 AND NOT sameas(in_29,"inco")                 ),
    put pm_cesdata.tn(t,regi,in_29,"xi"), " = ";
    put pm_cesdata(t,regi,in_29,"xi") /;

    loop (cesOut2cesIn(out,in_29),
      put @3, pm_cesdata.tn(t,regi,out,"quantity"), " = ",
          pm_cesdata(t,regi,out,"quantity") /;

      loop (cesOut2cesIn2(out,in),
        put @5, pm_cesdata.tn(t,regi,in,"price"), " = ",
            pm_cesdata(t,regi,in,"price") /;
        put @5, pm_cesdata.tn(t,regi,in,"quantity"), " = ",
            pm_cesdata(t,regi,in,"quantity") /;
      );
    );
  );

  execute_unload "abort.gdx";
  abort "assertion xi gt 0 failed, see .log file for details";
);

display " end consistency", pm_cesdata;
*** End of the part ensuring consistency given the ppfEn prices and quantities, the ipf prices,
*** the labor quantities, and the capital efficiency growth.

***_____________________________ END OF: 4 - ADJUST LABOUR PRICE to GDP _____________________________

***_____________________________ START OF: BEYOND CALIBRATION PART I _________________________________________________

*** Beyond calib allows for calibration of intermediate levels.
*** At the time of documentation, this was mainly used for the industry module subsectors realization.
*** Here, the above steps are only carried out down to the UE level of the different sectors.
*** (Hence sets like 'in' have a trimmed duplicate like 'in_29').
*** 'Beyond calib' now handles the part of the CES tree below this intermediate level.
*** To this end, in the following, a similar procedure as for the upper part of the tree is carried out.
*** However, consistency with the top most node(s) of the respective part of the tree is handled differently:
*** Here, all ppfen prices are scaled in beyond calib, instead of labour price in the 'normal' part.

if (card(ppf_beyondcalib_29) >= 1, !! if there are any nodes in beyond calib
  Display "  before computing xi in beyond", pm_cesdata;

  !! if prices haven't already been loaded
  if (sm_CES_calibration_iteration > 1 or s29_CES_calibration_new_structure eq 0,

    !! Compute ppf prices from CES derivatives of previous run
    p29_CESderivative(t,regi_dyn29(regi),cesOut2cesIn(out,in))$(
                                                      p29_cesIO_load(t,regi,in) )
      = p29_cesdata_load(t,regi,in,"xi")
      * p29_cesdata_load(t,regi,in,"eff")
      * p29_effGr(t,regi,in)
      * p29_cesIO_load(t,regi,out)

      ** (1 - p29_cesdata_load(t,regi,out,"rho"))

      * exp(
           log(
                p29_cesdata_load(t,regi,in,"eff")
              * p29_effGr(t,regi,in)
              * p29_cesIO_load(t,regi,in)
           )
        * (p29_cesdata_load(t,regi,out,"rho") - 1)
        );

    !! Propagate price down the CES tree
    loop ((cesLevel2cesIO(counter,in),cesOut2cesIn(in,in2),cesOut2cesIn2(in2,in3)),
      p29_CESderivative(t,regi_dyn29(regi),"inco",in3)
      = p29_CESderivative(t,regi,"inco",in2)
      * p29_CESderivative(t,regi,in2,in3);
    );


    !! Prices of intermediate production factors are all 1
    loop (cesOut2cesIn(in2,in),
      p29_CESderivative(t,regi_dyn29(regi),out,ipf_beyond_29_excludeRoot(in2))$(
                                              p29_CESderivative(t,regi,out,in2) )
      = 1;
    );

    display "check p29_CESderivative", p29_CESderivative;

    loop ((regi_dyn29(regi),
          cesOut2cesIn(out,in_beyond_calib_29_excludeRoot(in))),
      pm_cesdata(t,regi,in,"price")
      = p29_CESderivative(t,regi,out,in);
    );

$ifthen.subsectors "%industry%" == "subsectors"
$ifthen.FE_target "%c_CES_calibration_industry_FE_target%" == "1" !! c_CES_calibration_industry_FE_target
    !! set minimum price on ppf_industry
    pm_cesdata(t,regi_dyn29(regi),ppf_industry_dyn37(in),"price")$(NOT ue_industry_dyn37(in))
    = max(pm_cesdata(t,regi,in,"price"), 1e-5);
$endif.FE_target
$endif.subsectors

    !! smooth historical prices
    pm_cesdata(t_29hist(t),regi_dyn29(regi),in,"price")$(
                                              in_beyond_calib_29_excludeRoot(in) )
    = (0.25 * pm_cesdata(t,regi,in,"price"))
    + ( 0.75
      * sum(t_29hist2(t2), pm_cesdata(t2,regi,in,"price"))
      / card(t_29hist2)
      );

  else
    pm_cesdata(t,regi,ipf_beyond_29(in),"price")$( NOT ue_industry_dyn37(in) )
    = 1;
  );

  !! The calibration of elasticities of substitution takes much longer to
  !! converge if it starts from a high elasticity of substitution. To avoid
  !! this situation, the price of the capital stock is increased.
  if (sm_CES_calibration_iteration eq 1,
    loop (cesOut2cesIn(out,in_beyond_calib_29_excludeRoot(ppfKap(in)))$(
                                            pm_cesdata_sigma("2015",out) eq -1 ),
      pm_cesdata(t,regi,in,"price")
      = pm_cesdata(t,regi,in,"price")
      * 5;
    );
  );

  !! Report prices based on the inco marginal, before they are scaled.
  put capital_unit;

  loop ((t,regi_dyn29(regi),cesOut2cesIn(out,in),cesOut2cesIn2(out,in2))$(
                            ppfKap(in) AND (NOT ppfKap(in2))
                        AND (t.val eq 2005 OR t.val eq 2050 OR t.val eq 2100)
                        AND pm_cesdata_sigma(t,out) eq -1                     ),

    if (sm_CES_calibration_iteration eq 1 and s29_CES_calibration_new_structure eq 1,
      put sm_CES_calibration_iteration:0:0, "remind", t.tl, in.tl ;
      put "price_Noscale", regi.tl, pm_cesdata(t,regi,in,"price") /;
      put sm_CES_calibration_iteration:0:0, "remind", t.tl, in2.tl;
      put "price_Noscale", regi.tl, pm_cesdata(t,regi,in2,"price") /;
    else
      put sm_CES_calibration_iteration:0:0, "remind", t.tl, in.tl;
      put "price_Noscale", regi.tl, p29_CESderivative(t,regi,"inco",in) /;
      put sm_CES_calibration_iteration:0:0, "remind", t.tl, in2.tl;
      put "price_Noscale", regi.tl, p29_CESderivative(t,regi,"inco",in2) /;
    );
  );
  putclose;

  !! First, we compute the quantity for the root deriving from the ppf
  !! quantities and prices and we adjust the ppf prices so that it matches the
  !! root quantity. 

  loop ((t_29hist(t),regi_dyn29(regi),root_beyond_calib_29(out)),
    sm_tmp
    = sum(cesOut2cesIn_below(out,ppf(in)),
        pm_cesdata(t,regi,in,"price")
      * pm_cesdata(t,regi,in,"quantity")
      )
    / pm_cesdata(t,regi,out,"quantity");

    if (sm_tmp le 0,
      put logfile;
      put "sm_tmp   [", t.tl, ",", regi.tl, ",", out.tl, "]" /;
      put " = sum(cesOut2cesIn('", out.tl, "',in)," /;
      loop (cesOut2cesIn_below(out,in),
        put "      ", in.tl, @30 pm_cesdata(t,regi,in,"quantity");
        put " @ ", pm_cesdata(t,regi,in,"price") /;
      );
      put "   ) " /;
      put " / ", pm_cesdata(t,regi,out,"quantity") /;
      put " = ", sm_tmp /;
      put " " /;

      loop (cesOut2cesIn(out,in),
        put pm_cesdata.tn(t,regi,in,"quantity"), " = ";
        put pm_cesdata(t,regi,in,"quantity") /;
        put pm_cesdata.tn(t,regi,in,"price"), " = ";
        put pm_cesdata(t,regi,in,"price") /;
      );

      execute_unload "abort.gdx";
      abort "assertion sm_tmp is <= 0, see .log file for details";
    );

    loop (cesOut2cesIn_below(out,ppf(in)),
     !! adjust the price for historical periods
      pm_cesdata(t,regi,in,"price") $ (
                                t_29hist(t))
      = pm_cesdata(t,regi,in,"price")
      / sm_tmp;
     !! adjust the quantity for scenario periods
      pm_cesdata(t,regi,in,"quantity") $ (
                                t_29scen(t))
      = pm_cesdata(t,regi,in,"quantity")
      / sm_tmp;
    );
  );

  loop ((t_29,cesRev2cesIO(counter,ipf_beyond_29_excludeRoot(out)))$(
                                                   NOT sameas(out,"inco") ),
    pm_cesdata(t_29,regi_dyn29,out,"quantity")
    = sum(cesOut2cesIn(out,in),
        pm_cesdata(t_29,regi_dyn29,in,"price")
      * pm_cesdata(t_29,regi_dyn29,in,"quantity")
      );
  );

  loop ((t_29hist(t_29),cesOut2cesIn(out,in_beyond_calib_29_excludeRoot(in))),
      pm_cesdata(t_29,regi_dyn29,in,"xi")
      = pm_cesdata(t_29,regi_dyn29,in,"price")
      * pm_cesdata(t_29,regi_dyn29,in,"quantity")
      / pm_cesdata(t_29,regi_dyn29,out,"quantity");

      pm_cesdata(t_29,regi_dyn29,in,"eff")
      = pm_cesdata(t_29,regi_dyn29,out,"quantity")
      / pm_cesdata(t_29,regi_dyn29,in,"quantity");
  );
);

***_____________________________ END OF: BEYOND CALIBRATION PART I ________________________________________

***_____________________________ START OF: 5 - COMPUTE ELASTICITIES OF SUBSTITUTION ________________________________________


*** Compute the rho parameter from the elasticity of substitution
pm_cesdata(ttot,regi,ipf(out),"rho")$(    ttot.val ge 2005
                                      AND pm_cesdata_sigma(ttot,out)
                                      AND pm_cesdata_sigma(ttot,out) ne -1 )
    !! Do not compute it if sigma = 0, because these should be estimated
  = 1 - (1 / pm_cesdata_sigma(ttot,out));
***_____________________________ END OF: COMPUTE ELASTICITIES OF SUBSTITUTION ________________________________________

***_____________________________ START OF: 5 - PASS EFF TIME EVOLUTION TO EFFGR ________________________________________

*** Finally, we take the evolution of xi and eff, and pass it on to effGr.
*** (a) for items in ces_29
loop ((t,regi_dyn29(regi),ces_29(out,in),t0),
  pm_cesdata(t,regi,in,"effgr")$( pm_cesdata(t,regi,in,"quantity") gt 0 )
  = (pm_cesdata(t,regi,in,"eff") / pm_cesdata(t0,regi,in,"eff"))
  * (pm_cesdata(t,regi,in,"xi")  / pm_cesdata(t0,regi,in,"xi"))
 ** (1 / pm_cesdata(t,regi,out,"rho"));

  pm_cesdata(t,regi,in,"eff") = pm_cesdata(t0,regi,in,"eff");
  pm_cesdata(t,regi,in,"xi")  = pm_cesdata(t0,regi,in,"xi");
);

pm_cesdata(t,regi_dyn29(regi),"inco","effgr") = 1;

*** (b) for items beyond calibration, whose growth beyond t_29hist is treated
*** below

loop ((t_29,t0,cesOut2cesIn(out,in),regi_dyn29(regi))$(
                                     ces_beyondcalib_29(out,in)
                                 AND t_29hist(t_29) ),
  pm_cesdata(t_29,regi,in,"effgr")$( pm_cesdata(t_29,regi,in,"quantity") gt 0 )
  = (pm_cesdata(t_29,regi,in,"eff") / pm_cesdata(t0,regi,in,"eff"))
  * (pm_cesdata(t_29,regi,in,"xi")  / pm_cesdata(t0,regi,in,"xi"))
 ** (1 / pm_cesdata(t_29,regi,out,"rho"));

  pm_cesdata(t_29,regi,in,"eff") = pm_cesdata(t0,regi,in,"eff");
  pm_cesdata(t_29,regi,in,"xi")  = pm_cesdata(t0,regi,in,"xi");
);

loop ((t0,in_beyond_calib_29_excludeRoot),
  pm_cesdata(t_29,regi_dyn29,in,"eff") = pm_cesdata(t0,regi_dyn29,in,"eff");
  pm_cesdata(t_29,regi_dyn29,in,"xi")  = pm_cesdata(t0,regi_dyn29,in,"xi");
);


*** For beyond calib: treatment of effGr after historical periods

*** First, initialize effGr to the last value of the historical period
loop ((t_29hist_last(t2),regi_dyn29(regi),cesOut2cesIn(out,in))$(
                                           in_beyond_calib_29_excludeRoot(in)
                                       AND NOT ue_fe_kap_29(out)),
  pm_cesdata(t_29,regi,in, "effGr")$( pm_ttot_val(t_29) gt pm_ttot_val(t2) )
  = pm_cesdata(t2,regi,in, "effGr");
);

***_____________________________ END OF: 5 - PASS EFF TIME EVOLUTION TO EFFGR ________________________________________


***_____________________________ START OF: BEYOND CALIBRATION PART II ________________________________________

$ifthen.subsectors "%industry%" == "subsectors"
$ifthen.industry_FE_target "%c_CES_calibration_industry_FE_target%" == "1"

*** c_CES_calibration_industry_FE_target == 1 means that
*** industry ppfen input prices are scaled to make the Euler identity hold

*** Abort if any industry EEK value is lower than subsector output quantity
sm_tmp = smin((t,regi_dyn29(regi),
               cesOut2cesIn(ue_industry_dyn37(out),ppfKap(in))
               ),
             pm_cesdata(t,regi,out,"quantity")
          - ( pm_cesdata(t,regi,in,"quantity")
            * pm_cesdata(t,regi,in,"price")
            )
         );
if (0 gt sm_tmp,
  put logfile,  "Error in industry FE price rescaling: ",
                "EEK value exceeds subsector output quantity" /;
  logfile.nr = 1;
  loop ((t,regi_dyn29(regi),
         cesOut2cesIn(ue_industry_dyn37(out),ppfKap(in))),
    sm_tmp = pm_cesdata(t,regi,out,"quantity")
           - ( pm_cesdata(t,regi,in,"quantity")
             * pm_cesdata(t,regi,in,"price")
             );
    if (0 gt sm_tmp,
      put t.tl, ".", regi.tl, "   ", out.tl:>20,
          pm_cesdata(t,regi,out,"quantity"):>10:4, " < ",
          pm_cesdata(t,regi,in,"quantity"):>8:4, " x ",
          pm_cesdata(t,regi,in,"price"):<8:4, " ",
          in.tl:<0 /;
    );
  );
  putclose logfile, " " /;
  execute_unload "abort.gdx";
  abort "assertion EEK value < subsector output quantity failed. See log for details.";
);

*** scale industry ppfen input prices as a slack variable to make the Euler identity
*** hold
put logfile, ">>> Industry FE Price Rescaling <<<" /;
loop ((t,regi_dyn29(regi),ue_industry_dyn37(out)),
  if (not sum(in,ue_industry_2_pf(out,in)),
    sm_tmp = 1;
  else
    sm_tmp
    = ( pm_cesdata(t,regi,out,"quantity")
      - sum(cesOut2cesIn(out,ppfKap(in)),
          pm_cesdata(t,regi,in,"quantity")
        * pm_cesdata(t,regi,in,"price")
        )
      )
    / sum(ue_industry_2_pf(out,ppfen_industry_dyn37(in)),
        pm_cesdata(t,regi,in,"price")
      * pm_cesdata(t,regi,in,"quantity")
      );
  );

  if (sm_tmp ne 1,
    loop (ue_industry_2_pf(out,ppfen_industry_dyn37(in)),
      put pm_cesdata.tn(t,regi,in,"price"),
          @60 pm_cesdata(t,regi,in,"price"), " x ";
      if (abs(sm_tmp - 1) lt 1e-2,
        if (sm_tmp gt 1,
          put "(1 + ", (sm_tmp - 1), ") = ";
        else
          put "(1 - ", (1 - sm_tmp), ") = ";
        );
      else
        put "     ", sm_tmp, "  = ";
      );

      pm_cesdata(t,regi,in,"price")
      = pm_cesdata(t,regi,in,"price")
      * sm_tmp;

      put pm_cesdata(t,regi,in,"price") /;
    );
  );
);
putclose logfile, " " /;

*** recompute all ipf from Euler equation
loop (cesRev2cesIO(counter,ipf_industry_dyn37(out))$(
                                                   NOT ue_industry_dyn37(out) ),
  pm_cesdata(t,regi_dyn29(regi),out,"quantity")
  = sum(cesOut2cesIn(out,in),
      pm_cesdata(t,regi,in,"price")
    * pm_cesdata(t,regi,in,"quantity")
    );
);

loop ((t,regi_dyn29(regi),cesOut2cesIn(out,in_industry_dyn37(in)))$(
                                                    NOT ue_industry_dyn37(in) ),
  pm_cesdata(t,regi,in,"xi")
  = pm_cesdata(t,regi,in,"price")
  * pm_cesdata(t,regi,in,"quantity")
  / pm_cesdata(t,regi,out,"quantity");

  pm_cesdata(t,regi,in,"eff")
  = pm_cesdata(t,regi,out,"quantity")
  / pm_cesdata(t,regi,in,"quantity");

  loop (t0,
    pm_cesdata(t,regi,in,"effGr")$( pm_cesdata(t,regi,in,"quantity") gt 0 )
    = (pm_cesdata(t,regi,in,"eff") / pm_cesdata(t0,regi,in,"eff"))
    * (pm_cesdata(t,regi,in,"xi")  / pm_cesdata(t0,regi,in,"xi"))
   ** (1 / pm_cesdata(t,regi,out,"rho"));

    pm_cesdata(t,regi,in,"eff") = pm_cesdata(t0,regi,in,"eff");
    pm_cesdata(t,regi,in,"xi")  = pm_cesdata(t0,regi,in,"xi");
  );
);
$else.industry_FE_target

*** c_CES_calibration_industry_FE_target == 0 means that
*** the efficiency time evolution computed above if discarded and instead
*** efficiency improvements assumptions to industrial final energy and capital inputs are applied:
loop ((t_29hist_last(t2),cesOut2cesIn_below(out,in))$(
                                            industry_ue_calibration_target_dyn37(out)
                                            AND ppf_beyondcalib_29(in)),
  pm_cesdata(t_29,regi_dyn29(regi),in, "effGr")$( NOT t_29hist(t_29) )
  = pm_cesdata(t2,regi,in, "effGr")
  * ((1 + pm_ue_eff_target(out)) ** (t_29.val - pm_ttot_val(t2)))
  ;
);
$endif.industry_FE_target

!! - adjust efficiency parameters for feelhth_X and feh2_X
$ifthen.industry_FE_target "%c_CES_calibration_industry_FE_target%" == "0"
loop (cesOut2cesIn(in_industry_dyn37(out),in)$(
                              (ppfEn(in) OR ipf(in))
                          AND NOT industry_ue_calibration_target_dyn37(out)
                          AND NOT cesOut2cesIn_below("ue_steel_secondary",in) ),
  !! in2 is the reference energy input (gas if 'in' is H2)
  loop (in2$( pm_calibrate_eff_scale(in,in2,"level") ),
    !! compute the parameter describing the speed of convergence towards in2
    p29_t_tmp(t)$( t_29scen(t) )
    = pm_calibrate_eff_scale(in,in2,"level")
    / ( 1
      + exp((pm_calibrate_eff_scale(in,in2,"midperiod") - t.val)
          / pm_calibrate_eff_scale(in,in2,"width")
          )
      );

    p29_t_tmp(t) = p29_t_tmp(t) - sum(t0, p29_t_tmp(t0));
    p29_t_tmp(t) = min(1, max(0, p29_t_tmp(t)));

    pm_cesdata(t_29scen(t),regi_dyn29(regi),in,"effGr")
    =  1
       / ( pm_cesdata(t,regi,in,"eff")
          * pm_cesdata(t,regi,in,"xi")
          ** (1
              / pm_cesdata(t,regi,out,"rho")
              )
          )
       * (
          (1 - p29_t_tmp(t))
           * ( pm_cesdata(t,regi,in,"xi")
               ** ( 1
                     / pm_cesdata(t,regi,out,"rho")
                   )
             * pm_cesdata(t,regi,in,"eff")
             * pm_cesdata(t,regi,in,"effGr")
             )
          + p29_t_tmp(t)
           * ( pm_cesdata(t,regi,in2,"xi")
               ** ( 1
                     / pm_cesdata(t,regi,out,"rho")
                   )
             * pm_cesdata(t,regi,in2,"eff")
             * pm_cesdata(t,regi,in2,"effGr")
             )
         );
   );
);
$endif.industry_FE_target
$endif.subsectors

***_____________________________ END OF: BEYOND CALIBRATION PART II ________________________________________

display "after long term efficiencies", pm_cesdata;

*** All efficiences after t_29_last are set to their t_29_last values. This is
*** done in order to avoid xi negative in the latest periods. Should not be
*** necessary to split pre and post-t_29_last with reasonable FE pathways
* Exclude industry from this, since it may lead to infeasibilities.
loop ((t,t_29_last,in)$(    t.val gt t_29_last.val
                        AND NOT in_industry_dyn37(in) ),
  pm_cesdata(t,regi_dyn29(regi),in,"effGr")
  = pm_cesdata(t_29_last,regi,in,"effGr");

  pm_cesdata(t,regi_dyn29(regi),in,"eff")
  = pm_cesdata(t_29_last,regi,in,"eff");

  pm_cesdata(t,regi_dyn29(regi),in,"xi")
  = pm_cesdata(t_29_last,regi,in,"xi");

);

*** REPORTING for the elasticities of substitution
*** it has been separated from the esubs model results since the PDF reporting needs the CES efficiencies after 2015 as well
put capital_unit;
loop (regi_dyn29(regi),
loop ((out,in,in2,t)$((pm_cesdata_sigma(t,out) eq -1)
                                    AND ( cesOut2cesIn(out,in) AND cesOut2cesIn2(out,in2))
                                    AND ( ppfKap(in) AND ( NOT ppfKap(in2)))
                                    AND (sameAs(t, "2015") OR sameAs(t, "2050") OR sameAs(t, "2100"))) ,

       put sm_CES_calibration_iteration:0:0, "remind" , t.tl, out.tl   , "quantity", regi.tl, pm_cesdata(t,regi,out,"quantity") /;
       put sm_CES_calibration_iteration:0:0, "remind" , t.tl, in.tl , "quantity", regi.tl, pm_cesdata(t,regi,in,"quantity") /;
       put sm_CES_calibration_iteration:0:0, "remind" , t.tl, in2.tl  , "quantity", regi.tl, pm_cesdata(t,regi,in2,"quantity") /;

       put sm_CES_calibration_iteration:0:0,"remind" , t.tl, in.tl , "eff", regi.tl, pm_cesdata(t,regi,in,"eff") /;
       put sm_CES_calibration_iteration:0:0,"remind" , t.tl, in2.tl  , "eff", regi.tl, pm_cesdata(t,regi,in2,"eff") /;

       put sm_CES_calibration_iteration:0:0,"remind" , t.tl, in.tl , "effGr", regi.tl, pm_cesdata(t,regi,in,"effGr") /;
       put sm_CES_calibration_iteration:0:0,"remind" , t.tl, in2.tl  , "effGr", regi.tl, pm_cesdata(t,regi,in2,"effGr") /;

       put sm_CES_calibration_iteration:0:0,"remind" , t.tl, in.tl , "xi", regi.tl, pm_cesdata(t,regi,in,"xi") /;
       put sm_CES_calibration_iteration:0:0,"remind" , t.tl, in2.tl  , "xi", regi.tl, pm_cesdata(t,regi,in2,"xi") /;

       put sm_CES_calibration_iteration:0:0,"remind" , t.tl, in.tl , "price", regi.tl, pm_cesdata(t,regi,in,"price") /;
       put sm_CES_calibration_iteration:0:0,"remind" , t.tl, in2.tl  , "price", regi.tl, pm_cesdata(t,regi,in2,"price") /;

       put sm_CES_calibration_iteration:0:0,"remind" , t.tl,out.tl  , "rho", regi.tl, pm_cesdata(t,regi,out,"rho") /;
       );
);
putclose;


***_____________________________ START OF: CONSISTENCY CHECKS ________________________________________

*** check technological consistency of the CES tree.
p29_test_CES_recursive(t_29,regi,in) = 0;

p29_test_CES_recursive(t_29hist,regi_dyn29,ppf(in))
= pm_cesdata(t_29hist,regi_dyn29,in,"quantity");

p29_test_CES_recursive(t_29,regi_dyn29,ppf_29(in))
= pm_cesdata(t_29,regi_dyn29,in,"quantity");

display "consistency beyond 1", p29_test_CES_recursive;

*** test for the historical periods, where beyond_calib is also taken into account
loop ((t_29hist(t),regi_dyn29(regi),cesRev2cesIO(counter,ipf(out))),

  p29_test_CES_recursive(t,regi,out)
  = sum(cesOut2cesIn(out,in),
      pm_cesdata(t,regi,in,"xi")
    * ( pm_cesdata(t,regi,in,"eff")
      * pm_cesdata(t,regi,in,"effGr")
      * p29_test_CES_recursive(t,regi,in)
      )
   ** pm_cesdata(t,regi,out,"rho")
    )
 ** (1 / pm_cesdata(t,regi,out,"rho"));

);
putclose logfile;

display "consistency beyond 2", p29_test_CES_recursive;

*** test for the other periods, and restrict to in_29
loop ((t_29(t),regi_dyn29(regi),cesRev2cesIO(counter,ipf_29(out)))$(
                                                              NOT t_29hist(t) ),

  p29_test_CES_recursive(t,regi,out)
  !! use exp(log(a) * b) = a ** b because the latter is not accurate in GAMS
  = exp(
      log(
        sum(cesOut2cesIn(out,in),
          pm_cesdata(t,regi,in,"xi")
        * exp(
            log(
              ( pm_cesdata(t,regi,in,"eff")
              * pm_cesdata(t,regi,in,"effGr")
              * p29_test_CES_recursive(t,regi,in)
              )
            )
          * pm_cesdata(t,regi,out,"rho")
          )
        )
      )
    * (1 / pm_cesdata(t,regi,out,"rho"))
    );
);

display "consistency beyond 3", p29_test_CES_recursive;

option p29_test_CES_recursive:8;
display "check technological consistency beyond calibration", pm_cesdata,
        p29_test_CES_recursive;

sm_tmp = 0;
loop ((t_29(t),regi_dyn29(regi),cesOut2cesIn(out,in))$( NOT sameas(in,"inco") ),
  if (   pm_cesdata(t,regi,in,"effGr") lt 1e-10
     AND ( pm_cesdata(t,regi,in,"xi")
         * ( pm_cesdata(t,regi,in,"eff")
           * pm_cesdata(t,regi,in,"effGr")
           )
        ** pm_cesdata(t,regi,out,"rho")
         ) lt 1e-10,

    put logfile;
    if (sm_tmp eq 0,
      put ">>> Too low efficiency growth and total efficiency parameters <<<" /;
    );

    put t.tl, ",", regi.tl, ",", in.tl, ": ";
    put @30 pm_cesdata(t,regi,in,"xi"), " * (";
    put pm_cesdata(t,regi,in,"eff"), " * ";
    put pm_cesdata(t,regi,in,"effGr"), ") ^ ";
    put pm_cesdata(t,regi,out,"rho"), " = ";
    put ( pm_cesdata(t,regi,in,"xi")
        * exp(
            log( pm_cesdata(t,regi,in,"eff")
               * pm_cesdata(t,regi,in,"effGr")
               )
          * pm_cesdata(t,regi,out,"rho")
          )
        ) /;
    sm_tmp = 1;
  );
);

if (sm_tmp,
  put " " /;
  putclose logfile;
  execute_unload "abort.gdx";
  abort "some total efficiencies are too low, see logfile for details";
);
putclose logfile;

***_____________________________ END OF: CONSISTENCY CHECKS ________________________________________

$ONorder

*** Assert that q37_energy_limits is feasible for calibration runs
sm_tmp = 0;
loop ((ttot(t),regi_dyn29(regi),industry_ue_calibration_target_dyn37(out))$(
                                      t.val gt 2015 AND pm_energy_limit(out) ),
  sm_tmp2 = sum(ces_eff_target_dyn37(out,in), pm_cesdata(t,regi,in,"quantity"));
  if (sm_tmp2 le pm_cesdata(t,regi,out,"quantity") * pm_energy_limit(out),
    sm_tmp = 1;
  );
);

$ifthen.subsectors "%industry%" == "subsectors"   !! subsectors
if (sm_tmp eq 1,
  put logfile, "Assertion of industry energy limits failed: " /;
  loop ((regi_dyn29(regi),ttot(t),industry_ue_calibration_target_dyn37(out))$(
                                      t.val gt 2015 AND pm_energy_limit(out) ),
    sm_tmp
    = sum(ces_eff_target_dyn37(out,in), pm_cesdata(t,regi,in,"quantity"));

    if (sm_tmp le pm_cesdata(t,regi,out,"quantity") * pm_energy_limit(out),
      put pm_cesdata.tn(t,regi,out,"quantity"), " * ", pm_energy_limit.tn(out);
      put @80 " = " (pm_cesdata(t,regi,out,"quantity") * pm_energy_limit(out));
      put " > ", sm_tmp /;
      loop (ces_eff_target_dyn37(out,in)$( pm_cesdata(t,regi,in,"quantity") ),
        put @3 pm_cesdata.tn(t,regi,in,"quantity"), @73 " = ";
        put pm_cesdata(t,regi,in,"quantity") /;
      );
      put " " /;
    );
  );
  putclose logfile, " " /;

  execute_unload "abort.gdx";
  abort "Assertion of industry energy limits failed. See .log file for details.";
);
$endif.subsectors

*** EOF ./modules/29_CES_parameters/calibrate/preloop.gms
