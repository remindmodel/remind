*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_putty/presolve.gms

*** For the first iterations, avoid very high prices because of numerical reasons
if (ord(iteration) le 8,

   loop ((t,regi_dyn36(regi)),
      sm_tmp = smax(fe2ces_dyn36(entyFe,esty,teEs,in), p36_fePrice(t,regi,entyFe));
      if (sm_tmp gt 3,
           p36_fePrice(t,regi,entyFe) = max(0.01,
                                            p36_fePrice(t,regi,entyFe) / sm_tmp * 3
                                            );
      
      
      );
   );
);


*** Take average price over previous iterations
if (ord(iteration) ge 5,
p36_fePrice(t,regi_dyn36(regi),entyFe) $  p36_fePrice(t,regi,entyFe)= 
            ( p36_fePrice_iter(iteration - 1,t,regi,entyFe)
            + p36_fePrice_iter(iteration - 2,t,regi,entyFe)
            + p36_fePrice_iter(iteration - 3,t,regi,entyFe)
            + p36_fePrice_iter(iteration - 4,t,regi,entyFe)
            )
            / 4;
);
*** Beyond the 70th iteration, the prices are averaged over the prices since the 66th iteration
if (ord(iteration) ge 70,

p36_fePrice(t,regi_dyn36(regi),entyFe) =
          sum(iteration2 $ (ord(iteration2) ge 66 
                           AND ord(iteration2) lt ord(iteration)),
             p36_fePrice_iter(iteration2,t,regi,entyFe)
          )
          / 
          sum(iteration2 $ (ord(iteration2) ge 66 
                           AND ord(iteration2) lt ord(iteration)),
             1
          )
            ;

);
*** smooth the costs

*** Smooth 2005 prices
$offOrder
p36_kapPrice(t,regi_dyn36(regi))$(ord(t) eq 1)
  = ( p36_kapPrice(t+1,regi) * 2
    + p36_kapPrice(t+2,regi)
    )
  / 3;

p36_fePrice(t,regi_dyn36(regi),entyFe)$(ord(t) eq 1)
  = ( p36_fePrice(t+1,regi,entyFe) * 2
    + p36_fePrice(t+2,regi,entyFe)
    )
  / 3;
$onOrder  
*** Smooth non 2005 prices with moving average
$OFForder
loop (t$ ( not ((ord(t) le 1) or (ord(t) eq card(t)))),
p36_kapPrice(t,regi_dyn36(regi))  =
                           ( p36_kapPrice(t-1,regi)
                           + p36_kapPrice(t,regi)
                           + p36_kapPrice(t+1,regi)
                            ) / 3  ;

p36_fePrice(t,regi_dyn36(regi),entyFe)  =
                             (p36_fePrice(t-1,regi,entyFe)
                             + p36_fePrice(t,regi,entyFe)                             
                             + p36_fePrice(t+1,regi,entyFe)
                             ) / 3;

);
$ONorder 

*** Can you explain again the purpose of adding an implicit discount rate to the capital cost of fe2ue techs?
*** Is p36_costReduc(t,teEs) assuming some exogenous learning?
loop (fe2ces_dyn36(entyFe,esty,teEs,in),
p36_kapPriceImplicit(t,regi_dyn36(regi),teEs) = p36_kapPrice(t,regi) + p36_implicitDiscRateMarg(t,regi,in);
);

 p36_esCapCost(t,regi_dyn36(regi),teEs_dyn36(teEs)) =
   (f36_datafecostsglob("inco0",teEs) 
    * p36_costReduc(t,teEs)
   *   p36_kapPrice(t,regi) / (1 - (1 + p36_kapPrice(t,regi))** (-f36_datafecostsglob("lifetime",teEs))) !! annualised initial capital costs
   + f36_datafecostsglob("omf",teEs)   
   )
   / f36_datafecostsglob("usehr",teEs)   !! from T$/TW to T$/TWh
   * sm_day_2_hour * sm_year_2_day         !! from T$/TWh to T$/TWa
   ;

 p36_esCapCostImplicit(t,regi_dyn36(regi),teEs_dyn36(teEs)) =
   (f36_datafecostsglob("inco0",teEs) 
    * p36_costReduc(t,teEs)
   *   p36_kapPriceImplicit(t,regi,teEs) / (1 - (1 + p36_kapPriceImplicit(t,regi,teEs))** (-f36_datafecostsglob("lifetime",teEs))) !! annualised initial capital costs
   + f36_datafecostsglob("omf",teEs)   
   )
   / f36_datafecostsglob("usehr",teEs)   !! from T$/TW to T$/TWh
   * sm_day_2_hour * sm_year_2_day         !! from T$/TWh to T$/TWa
   ;   
 
p36_inconvpen(t,regi_dyn36(regi),teEs)$f36_inconvpen(teEs) = 
   (1 -
    min(max((20 - (vm_cesIO.L(t,regi,"inco")$( NOT sameAs(iteration,"1"))
                   +pm_gdp(t,regi)$ sameAs(iteration,"1")) / pm_shPPPMER(regi)
                  / pm_pop(t,regi))
            /(20 - 3),0),1)  !! (1-lambda) = 0 if gdppop < 3000, 1 if gdppop >= 20000
    )
    * f36_inconvpen(teEs) ;

loop ( (fe2es_dyn36(entyFe,esty,teEs)),
p36_techCosts(t,regi_dyn36(regi),entyFe,esty,teEs) =
       p36_esCapCostImplicit(t,regi,teEs)
       +
      (p36_fePrice(t,regi,entyFe)
      + p36_inconvpen(t,regi,teEs))
      / pm_fe2es(t,regi,teEs)
      !! add taxes, subsidies, and later on costs
      ;
);      


*** Compute the share of UE for each technology that is needed to get the aggregate technological distribution observed
loop ((t36_hist(ttot),fe2ces_dyn36(entyFe,esty,teEs,in)),
p36_shUeCesDelta(ttot,regi_dyn36(regi),entyFe,in,teEs) 
               = p36_prodUEintern(ttot,regi,entyFe,esty,teEs)
                 / sum ( fe2ces_dyn36_2(entyFe2,esty2,teEs2,in),
                         p36_prodUEintern(ttot,regi,entyFe2,esty2,teEs2)
                        )
                    ;

     loop (regi_dyn36(regi),
     if ( p36_shUeCesDelta(ttot,regi,entyFe,in,teEs) lt 0,
     put testfile;
     put p36_shUeCesDelta.tn(ttot,regi,entyFe,in,teEs) , " = ", p36_shUeCesDelta(ttot,regi,entyFe,in,teEs) /;
     put p36_demUEtotal.tn(ttot,regi,in) , " = ", p36_demUEtotal(ttot,regi,in) /;
     put p36_prodEs.tn(ttot,regi,entyFe,esty,teEs) , " = ", p36_prodEs(ttot,regi,entyFe,esty,teEs) /;
     put p36_prodUEintern.tn(ttot,regi,entyFe,esty,teEs), " = ", p36_prodUEintern(ttot,regi,entyFe,esty,teEs) /;
     putclose;
     execute_unload "abort.gdx";
     abort "some share was decreasing faster than planned. Look at the logfile for more information";
     );
     );                                        
);

*** Compute the calibration factors for the historical periods
loop ((t36_hist(ttot),fe2ces_dyn36(entyFe,esty,teEs,in)),
p36_logitCalibration(ttot,regi_dyn36(regi),entyFe,esty,teEs) $ p36_shUeCesDelta(ttot,regi,entyFe,in,teEs) !! exclude shares which are zero
        =
   (1 / (p36_logitLambda(regi,in))
    * log ( p36_shUeCesDelta(ttot,regi,entyFe,in,teEs))
    - p36_techCosts(ttot,regi,entyFe,esty,teEs)
   )
   -
   (1 
   / sum (fe2ces_dyn36_2(entyFe2,esty2,teEs2,in)$ p36_shUeCesDelta(ttot,regi,entyFe2,in,teEs2),
          1) 
   ) 
   * sum (fe2ces_dyn36_2(entyFe2,esty2,teEs2,in)$ p36_shUeCesDelta(ttot,regi,entyFe2,in,teEs2), !! exclude shares which are zero
          1 / ( p36_logitLambda(regi,in))
           * log ( p36_shUeCesDelta(ttot,regi,entyFe2,in,teEs2))
           - p36_techCosts(ttot,regi,entyFe2,esty2,teEs2)
          );

);

*** For the last historical period, attribute the last historical value of the calibration parameter to the scenario periods
*** The calibration factors are reduced towards 80% in the long term to represent the enhanced flexibility of the system
*** Long lasting non-price barriers should preferably be represented through price mark-ups
loop ( t36_hist_last(ttot),

 p36_logitCalibration(ttot,regi_dyn36(regi),entyFe,esty,teEs) $ ( fe2es_dyn36(entyFe,esty,teEs)
                                                                 AND NOT p36_logitCalibration(ttot,regi,entyFe,esty,teEs))
  = 5;

  loop ( t36_scen(t2),
   
  p36_logitCalibration(t2,regi_dyn36(regi),entyFe,esty,teEs) $ fe2es_dyn36(entyFe,esty,teEs)
   = min(max((2040 - pm_ttot_val(t2))/(2040 -ttot.val),0),1)  !! lambda = 1 in 2015 and 0 in 2040
    * (p36_logitCalibration(ttot,regi,entyFe,esty,teEs)
       - cm_logitCal_markup_conv_b * p36_logitCalibration(ttot,regi,entyFe,esty,teEs))
     +  cm_logitCal_markup_conv_b * p36_logitCalibration(ttot,regi,entyFe,esty,teEs)
    ;
    
    !! give a high parameter value to the technologies that do not have some
   p36_logitCalibration(t2,regi_dyn36(regi),entyFe,esty,teEs) $ (fe2es_dyn36(entyFe,esty,teEs)
                                                    AND NOT p36_logitCalibration(t2,regi,entyFe,esty,teEs))
  =   min(max((2040 - pm_ttot_val(t2))/(2040 -ttot.val),0),1)  !! lambda = 1 in 2015 and 0 in 2040     
      * (3
       - cm_logitCal_markup_newtech_conv_b * 3)
     +  cm_logitCal_markup_newtech_conv_b * 3;
     
     !! Decrease the calibration factor for some technologies, based on the difference between the 2015 (ttot) Income per capita and scenario (t2) income per capita.
     !! the calibration factor decreases by 90% when income reaches 30 k$ if income per capita was equal or below 5 k$ in 2015.
     !! the decrease is lower if the starting income was above 10k$ and is 0 if income was above 30k$
   p36_logitCalibration(t2,regi_dyn36(regi),entyFe,esty,teEs) $ richTechs(teEs) =  !! calib = calib * (1 - 0.90 * X) 
     p36_logitCalibration(ttot,regi,entyFe,esty,teEs) 
     *  (1 - 0.90 
     * (( max ( 5, min (30, (vm_cesIO.L(t2,regi,"inco")$( NOT sameAs(iteration,"1")) + pm_gdp(t2,regi)$ sameAs(iteration,"1")) / pm_shPPPMER(regi) / pm_pop(t2,regi) ))
         - min (30, max (5, (vm_cesIO.L(ttot,regi,"inco")$( NOT sameAs(iteration,"1")) + pm_gdp(ttot,regi)$ sameAs(iteration,"1")) / pm_shPPPMER(regi) / pm_pop(ttot,regi) ))
         )
         / (30 -5))
       ) 
     ;
     
     
    p36_logitCalibration(t2,regi_dyn36(regi),entyFe,esty,teEs) $ (fe2es_dyn36(entyFe,esty,teEs) AND teEs_pushCalib_dyn36(teEs)) = 
      p36_pushCalib(t2,teEs) 
      * p36_logitCalibration(t2,regi,entyFe,esty,teEs)
      ;
);
); 

option
  limrow = 10000000
  limcol = 10000000
  solprint = on
;

s36_logit = 1;
if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve logit_36 maximizing v36_shares_obj using nlp;
s36_logit = 0;

option
  limrow = 0
  limcol = 0
  solprint = off
;

if ( NOT ( logit_36.solvestat eq 1  AND (logit_36.modelstat eq 1 OR logit_36.modelstat eq 2)),
abort "model logit_36 is infeasible";
);

*** Compute the aggregate UE shares
loop (fe2ces_dyn36(entyFe,esty,teEs,in),
    p36_shUeCes(t,regi_dyn36(regi),entyFe,in,teEs)
                        =  v36_prodEs.L(t,regi,entyFe,esty,teEs)
                            / p36_demUEtotal(t,regi,in);
);


*** Set 1e-3 as a lower bound for shares
p36_shUeCes(ttot,regi_dyn36(regi),entyFe,in,teEs) $ ( t36_scen(ttot)
                                                      AND p36_shUeCes(ttot,regi,entyFe,in,teEs) lt 1e-3)
                                                      = 0
                                                      ;
p36_shUeCes(ttot,regi_dyn36(regi),entyFe,in,teEs) $ ( t36_scen(ttot)
                                                     AND feteces_dyn36(entyFe,teEs,in)
                                                     )
                                                     = p36_shUeCes(ttot,regi,entyFe,in,teEs)
                                                    / sum( feteces_dyn36_2(entyFe2,teEs2,in),
                                                    p36_shUeCes(ttot,regi,entyFe2,in,teEs2))
                                                    ;

*** Compute FE shares

p36_shFeCes(t,regi_dyn36(regi),entyFe,in,teEs)$feteces_dyn36(entyFe,teEs,in)
                                                = (1 / p36_fe2es(t,regi,teEs))
                                                 / sum ( (fe2ces_dyn36(entyFe2,esty2,teEs2,in)),
                                                       (1 / p36_fe2es(t,regi,teEs2))
                                                        * p36_shUeCes(t,regi,entyFe2,in,teEs2)
                                                        )
                                                 * p36_shUeCes(t,regi,entyFe,in,teEs)
                                                 ;
                                                 
*** Pass on to core parameters
loop (fe2ces_dyn36(entyFe,esty,teEs,in),
pm_shFeCes(t,regi_dyn36(regi),entyFe,in,teEs)$( NOT t0(t)) 
    = p36_shFeCes(t,regi,entyFe,in,teEs);
);
pm_esCapCost(t,regi_dyn36(regi),teEs_dyn36(teEs)) 
    = p36_esCapCost(t,regi,teEs);


*** Diagnostics
*** Compute the norm of the difference between the share vectors of two iterations
p36_shUeCes_iter(iteration,t,regi,entyFe,in,teEs)  
       = p36_shUeCes(t,regi,entyFe,in,teEs) ;
if ( ord(iteration) gt 1,
loop ((t,regi_dyn36(regi),inViaEs_dyn36(in)),
p36_logitNorm(iteration,t,regi,in) = sqrt ( 
                                            sum (fe2ces_dyn36(entyFe,esty,teEs,in) ,
                                                 power ( p36_shUeCes_iter(iteration,t,regi,entyFe,in,teEs)
                                                         - p36_shUeCes_iter(iteration - 1,t,regi,entyFe,in,teEs),
                                                         2)
                                                 )
                                            )
;
)
);                                            

*** Reporting
put file_logit_buildings;
put "scenario", "iteration", "period", "region", "variable", "tech", "ces_out", "value" /;

*** Report on the historical shares

  loop (t36_hist(ttot),
    loop (regi_dyn36(regi),
      loop (fe2ces_dyn36(entyFe,esty,teEs,in),
         
         put "%c_expname%", "target", ttot.tl, regi.tl, "shareFE", teEs.tl, in.tl, p36_shFeCes(ttot,regi,entyFe,in,teEs) /;
         
            );
           );
         );

loop ((t,regi_dyn36(regi),fe2ces_dyn36(entyFe,esty,teEs,in)),
put "%c_expname%", iteration.tl, t.tl,regi.tl, "shareFE", teEs.tl, in.tl, p36_shFeCes(t,regi,entyFe,in,teEs) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "shareUE", teEs.tl, in.tl, p36_shUeCes(t,regi,entyFe,in,teEs) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "cost", teEs.tl, in.tl, (p36_techCosts(t,regi,entyFe,esty,teEs) * 1000 / (sm_day_2_hour * sm_year_2_day)) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "calibfactor", teEs.tl, in.tl, (p36_logitCalibration(t,regi,entyFe,esty,teEs)* 1000 / (sm_day_2_hour * sm_year_2_day)) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "FEpriceWoTax", teEs.tl, in.tl,  (p36_fePrice(t,regi,entyFe) * 1000 / (sm_day_2_hour * sm_year_2_day)) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "OM", teEs.tl, in.tl, ((p36_fePrice(t,regi,entyFe)
                                                                         + p36_inconvpen(t,regi,teEs)
                                                                         )
                                                                         / pm_fe2es(t,regi,teEs) * 1000 / (sm_day_2_hour * sm_year_2_day)) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "OM_FEpriceWtax", teEs.tl, in.tl, (
                                                                         (p36_fePrice(t,regi,entyFe)
                                                                         )
                                                                         / pm_fe2es(t,regi,teEs) * 1000 / (sm_day_2_hour * sm_year_2_day)) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "OM_inconvenience", teEs.tl, in.tl, ((
                                                                          p36_inconvpen(t,regi,teEs)
                                                                         )
                                                                         / pm_fe2es(t,regi,teEs) * 1000 / (sm_day_2_hour * sm_year_2_day)) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "FEpriceTax", teEs.tl, in.tl,  ((p36_fePrice(t,regi,entyFe)
                                                                         )
                                                                         * 1000 / (sm_day_2_hour * sm_year_2_day)) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "CapCosts", teEs.tl, in.tl, (p36_esCapCost(t,regi,teEs) * 1000 / (sm_day_2_hour * sm_year_2_day)) /;
put "%c_expname%", iteration.tl, t.tl,regi.tl, "CapCostsImplicit", teEs.tl, in.tl, (p36_esCapCostImplicit(t,regi,teEs) * 1000 / (sm_day_2_hour * sm_year_2_day)) /;
);

if ( ord(iteration) gt 1,
loop ((t,regi_dyn36(regi),inViaEs_dyn36(in)),
put "%c_expname%", iteration.tl, t.tl,regi.tl, "norm_diff", "NA" ,in.tl, p36_logitNorm(iteration,t,regi,in) /;
);
);

putclose;

*** EOF ./modules/36_buildings/services_putty/presolve.gms

