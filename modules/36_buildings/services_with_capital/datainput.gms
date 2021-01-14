*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/datainput.gms
*** substitution elasticities
Parameter 
  p36_cesdata_sigma(all_in)  "substitution elasticities"
  /
    
        enb     0.3
        esswb   -1 !! The Esub is estimated with technological data 
        ueswb   INF     !! all sigma equal to INF will be treated as a sum with coefficients equal to unity ie OUT = IN1+ IN2.
          uescb  -1    !! The Esub is estimated with technological data  
          uealb  -1 !! The Esub is estimated with technological data  
              
  /
  
;
pm_cesdata_sigma(ttot,in)$p36_cesdata_sigma(in) = p36_cesdata_sigma(in);

pm_capital_lifetime_exp(all_regi,"kapsc") = 20;
pm_capital_lifetime_exp(all_regi,"kapal") = 12;

pm_capital_lifetime_exp(all_regi,"esswb") = log ( 0.25) / log ( 1 -0.02 );

pm_delta_kap(regi,in)$((ppfKap_dyn36(in) AND NOT in_putty(in)) OR nests_putty_dyn36(in,in)) = - log (0.25) / pm_capital_lifetime_exp(regi,in);

loop (out,
pm_delta_kap(regi,in)$nests_putty_dyn36(out,in) = pm_delta_kap(regi,out);
);  
      
parameter

p36_floorspace_scen                    "floorspace"
/
$ondelim
$include "./modules/36_buildings/services_with_capital/input/p36_floorspace_scen.cs4r"
$offdelim
/

p36_demFeForEs_scen  "final energy demand projections for FE-UE technologies"
/
$ondelim
$include "./modules/36_buildings/services_with_capital/input/p36_serviceInputs.cs4r"
$offdelim
/

p36_prodEs_scen  "useful energy demand projections for FE-UE technologies"
/
$ondelim
$include "./modules/36_buildings/services_with_capital/input/p36_serviceOutputs.cs4r"
$offdelim
/

;

table f36_datafecostsglob(char,all_teEs)   "end-use (final energy) technologies characteristics"
$include "./modules/36_buildings/services_with_capital/input/generisdata_feCapCosts.prn"
;


 f36_datafecostsglob("inco0",teEs)            = sm_D2015_2_D2005      * f36_datafecostsglob("inco0",teEs); 
 f36_datafecostsglob("inco0",teEs)            = sm_DpKW_2_TDpTW       * f36_datafecostsglob("inco0",teEs);
 f36_datafecostsglob("omf",teEs)              = sm_D2015_2_D2005      * f36_datafecostsglob("omf",teEs); 
 f36_datafecostsglob("omf",teEs)              = sm_DpKW_2_TDpTW       * f36_datafecostsglob("omf",teEs);

table f36_dataeff(char,all_teEs)   "end-use (final energy) long term efficiency assumptions"
$include "./modules/36_buildings/services_with_capital/input/generisdata_Eff.prn"
;

p36_floorspace(ttot,regi) = p36_floorspace_scen(ttot,regi,"%cm_POPscen%") * 1e-3; !! from million to billion m2;

p36_demFeForEs(ttot,regi,entyFe,esty,teEs)$fe2es_dyn36(entyFe,esty,teEs) = p36_demFeForEs_scen(ttot,regi,"%cm_GDPscen%",entyFe,esty,teEs) * sm_EJ_2_TWa; !!  from EJ to TWa;
p36_prodEs(ttot,regi,entyFe,esty,teEs)$fe2es_dyn36(entyFe,esty,teEs) = p36_prodEs_scen(ttot,regi,"%cm_GDPscen%",entyFe,esty,teEs) * sm_EJ_2_TWa; !! from EJ to TWa;


***_____________________________Information for the ES layer  and the multinomial logit function _____________________________

*** Price sensitivity of the logit function
p36_logitLambda(regi,in)$inViaEs_dyn36(in) = cm_INNOPATHS_priceSensiBuild;

*** Compute efficiencies of technologies producing ES(UE) from FE
loop ( fe2es_dyn36(entyFe,esty,teEs),
p36_fe2es(ttot,regi,teEs)$p36_demFeForEs(ttot,regi,entyFe,esty,teEs) = p36_prodEs(ttot,regi,entyFe,esty,teEs) / p36_demFeForEs(ttot,regi,entyFe,esty,teEs);
);

p36_fe2es(ttot,regi,teEs)$(teEs_dyn36(teEs) AND ( NOT p36_fe2es(ttot,regi,teEs))) = 0.5;
p36_fe2es(ttot,regi,teEs)$(sameAs(teEs, "te_ueshhpb") OR sameAs(teEs,"te_uecwhpb")) = 3;

*** Compute share of heat pumps based on the efficiency of electricity
loop (mapElHp(teEs,teEs2),  !!teEs= electric resistance. teEs2= heat pump
loop (fe2es_dyn36(entyFe,esty,teEs),
loop (fe2es_dyn36_2(entyFe,esty2,teEs2),
sm_tmp = 0.9; !! maximum assumed efficiency of electric resistance
p36_demFeForEs(ttot,regi,entyFe,esty2,teEs2)$(p36_fe2es(ttot,regi,teEs) gt sm_tmp) 
         = p36_demFeForEs(ttot,regi,entyFe,esty,teEs)
           * (p36_fe2es(ttot,regi,teEs) - sm_tmp)
           /  (p36_fe2es(ttot,regi,teEs2) -sm_tmp)
          ;
p36_demFeForEs(ttot,regi,entyFe,esty,teEs) = p36_demFeForEs(ttot,regi,entyFe,esty,teEs)
                                          - p36_demFeForEs(ttot,regi,entyFe,esty2,teEs2);

p36_fe2es(ttot,regi,teEs)$(p36_fe2es(ttot,regi,teEs) gt sm_tmp) = sm_tmp;
);
);
);

*** Correct the UE quantities of heat pumps and electricity in accordance
p36_prodEs(ttot,regi,entyFe,esty,teEs) = p36_demFeForEs(ttot,regi,entyFe,esty,teEs) * p36_fe2es(ttot,regi,teEs);

if (cm_startyear gt 2005,
Execute_Loadpoint 'input_ref' p36_logitCalibration_load = p36_logitCalibration, p36_logitLambda_load = p36_logitLambda;
p36_logitCalibration(ttot,regi,enty,esty,teEs) = p36_logitCalibration_load(ttot,regi,enty,esty,teEs);
p36_logitLambda(regi,in) = p36_logitLambda_load(regi,in);
);

*** Introduce long term assumption concerning efficiencies
loop (t36_hist_last(ttot2),

p36_fe2es(ttot,regi,teEs)$( pm_ttot_val(ttot) gt pm_ttot_val(ttot2)) = p36_fe2es(ttot2,regi,teEs);

p36_fe2es(ttot,regi,teEs)$f36_dataeff("eta",teEs)
=
min(max((2100 - pm_ttot_val(ttot))/(2100 -ttot2.val),0),1)  !! lambda = 1 in 2015 and 0 in 2100
                                            * ( p36_fe2es(ttot,regi,teEs) 
                                               -  f36_dataeff("eta",teEs)
                                               ) 
                                            + f36_dataeff("eta",teEs)
;
);

*** Compute FE shares of technologies producing ES(UE) from FE
p36_shFeCes(ttot,regi,entyFe,in,teEs)$(feViaEs2ppfen(entyFe,in,teEs)
                                   AND teEs_dyn36(teEs)
                                   AND sum(fe2es(entyFe2,esty,teEs2)$es2ppfen(esty,in),  p36_demFeForEs(ttot,regi,entyFe2,esty,teEs2)))
=
sum(fe2es(entyFe,esty,teEs)$es2ppfen(esty,in),  p36_demFeForEs(ttot,regi,entyFe,esty,teEs))
/ sum(fe2es(entyFe2,esty,teEs2)$es2ppfen(esty,in),  p36_demFeForEs(ttot,regi,entyFe2,esty,teEs2))
;

*** Compute UE shares of technologies producing ES(UE) from FE
p36_shUeCes(ttot,regi,entyFe,in,teEs)$(feViaEs2ppfen(entyFe,in,teEs)
                                   AND teEs_dyn36(teEs)
                                   AND sum(fe2es(entyFe2,esty,teEs2)$es2ppfen(esty,in),  p36_prodEs(ttot,regi,entyFe2,esty,teEs2)))
=
sum(fe2es(entyFe,esty,teEs)$es2ppfen(esty,in),  p36_prodEs(ttot,regi,entyFe,esty,teEs))
/ sum(fe2es(entyFe2,esty,teEs2)$es2ppfen(esty,in),  p36_prodEs(ttot,regi,entyFe2,esty,teEs2))
;
display p36_shFeCes, p36_fe2es, p36_demFeForEs, p36_prodEs, p36_shUeCes;

p36_demUEtotal(ttot,regi,in) = sum (fe2ces_dyn36(entyFe,esty,teEs,in),  p36_prodEs(ttot,regi,entyFe,esty,teEs));

loop (t0(ttot),
p36_prodUEintern(ttot,regi,entyFe,esty,teEs) = p36_prodEs(ttot,regi,entyFe,esty,teEs);
);

if (cm_startyear gt 2005,
Execute_Loadpoint 'input_ref' p36_prodUEintern_load = v_prodEs.L;
p36_prodUEintern(ttot,regi,enty,esty,teEs)$(ttot.val gt 2005 and ttot.val lt cm_startyear) = p36_prodUEintern_load(ttot,regi,enty,esty,teEs);
);

*** Compute FE prices from input.gdx
if ( execError = 0,
Execute_Loadpoint 'input'  p36_marginalUtility = qm_budget.m;
    if (execError gt 0,
    execError = 0;
    p36_marginalUtility(ttot,regi) = 1;
    );
);
if ( execError = 0,
Execute_Loadpoint 'input' p36_fePrice_load = qm_balFe.m;
loop (se2fe(entySe,entyFe,te),
 p36_fePrice(ttot,regi,entyFe) = p36_fePrice_load(ttot,regi,entySe,entyFe,te);
 );
if (execError gt 0,
    execError = 0;
    p36_fePrice(ttot,regi,entyFe) = 1;
    );
);

p36_marginalUtility(ttot,regi)$( abs (p36_marginalUtility(ttot,regi)) lt sm_eps) = 1;

p36_fePrice(ttot,regi,entyFe) = abs (p36_fePrice(ttot,regi,entyFe)) / abs (p36_marginalUtility(ttot,regi));
p36_fePrice(ttot,regi,entyFe)$ ( NOT p36_fePrice(ttot,regi,entyFe)) = 0.01; !! give a default value in case the relevant information is not available in the input.gdx


p36_fePrice_iter(iteration,ttot,regi,entyFe) = 0;

if ((cm_noReboundEffect eq 1 ),
Execute_Load 'input_ref'  p36_cesIONoRebound = vm_cesIO.L;
);

*** Implicit discount rates mark-ups over the normal discount rate
if ((cm_DiscRateScen eq 0),
p36_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 elseif (cm_DiscRateScen eq 1),
 p36_implicitDiscRateMarg(ttot,regi,"ueshb") = 0.05;  !! 5% for the choice of space heating technology
 p36_implicitDiscRateMarg(ttot,regi,"uecwb") = 0.05;  !! 5% for the choice of cooking and water heating technology
 elseif (cm_DiscRateScen eq 2),
 p36_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 p36_implicitDiscRateMarg(ttot,regi,"ueshb")$(ttot.val ge 2005 AND ttot.val lt cm_startyear) = 0.05;  !! 5% for the choice of space heating technology
 p36_implicitDiscRateMarg(ttot,regi,"uecwb")$(ttot.val ge 2005 AND ttot.val lt cm_startyear) = 0.05;  !! 5% for the choice of cooking and water heating technology
 
 elseif (cm_DiscRateScen eq 3),
 p36_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 
 p36_implicitDiscRateMarg(ttot,regi,"ueshb") = 0.05;  !! 5% for the choice of space heating technology
 p36_implicitDiscRateMarg(ttot,regi,"uecwb") = 0.05;  !! 5% for the choice of cooking and water heating technology
 
 p36_implicitDiscRateMarg(ttot,regi,in)$( pm_ttot_val(ttot) ge cm_startyear
                                         AND (sameAs(in,"ueshb") 
                                              OR sameAs(in,"uecwb")
                                             )
                                         )
                                     = 0.25 * p36_implicitDiscRateMarg(ttot,regi,in) ; 
 
 elseif (cm_DiscRateScen eq 4),
 p36_implicitDiscRateMarg(ttot,regi,all_in) = 0;
 
 p36_implicitDiscRateMarg(ttot,regi,"ueshb") = 0.05;  !! 5% for the choice of space heating technology
 p36_implicitDiscRateMarg(ttot,regi,"uecwb") = 0.05;  !! 5% for the choice of cooking and water heating technology

 p36_implicitDiscRateMarg(ttot,regi,"ueshb") = min(max((2030 - pm_ttot_val(ttot))/(2030 -2020),0),1)    !! lambda = 1 in 2020 and 0 in 2030; 
                                               *  0.75 * p36_implicitDiscRateMarg(ttot,regi,"ueshb")
                                               +  0.25 * p36_implicitDiscRateMarg(ttot,regi,"ueshb");   !! Reduction of 75% of the Efficiency gap
 p36_implicitDiscRateMarg(ttot,regi,"uecwb") = min(max((2030 - pm_ttot_val(ttot))/(2030 -2020),0),1)    !! lambda = 1 in 2020 and 0 in 2030; 
                                               *  0.75 * p36_implicitDiscRateMarg(ttot,regi,"uecwb")
                                               +  0.25 * p36_implicitDiscRateMarg(ttot,regi,"uecwb");   !! Reduction of 75% of the Efficiency gap
 );
 
p36_kapPrice(ttot,regi) = pm_cesdata(ttot,regi,"kap","price") - pm_delta_kap(regi,"kap"); 
loop (fe2ces_dyn36(entyFe,esty,teEs,in),
p36_kapPriceImplicit(ttot,regi,teEs) = p36_kapPrice(ttot,regi) + p36_implicitDiscRateMarg(ttot,regi,in);
);

*** Inconvenience mark-up
f36_inconvpen(teEs)$(sameAs(teEs,"te_ueshstb") OR sameAs(teEs,"te_uecwstb"))       = 42;   !! In dollar per GJ 42$/GJ is app. eq to 0.15$/kWh
f36_inconvpen(teEs)$(sameAs(teEs,"te_ueshhob") OR sameAs(teEs,"te_uecwhob"))       = 14;   !! In dollar per GJ 14$/GJ is app. eq to 0.05$/kWh
f36_inconvpen(teEs)$(sameAs(teEs,"te_ueshsob") OR sameAs(teEs,"te_uecwsob"))       = 14;   !! In dollar per GJ 14$/GJ is app. eq to 0.05$/kWh
f36_inconvpen(teEs) = f36_inconvpen(teEs) * sm_DpGJ_2_TDpTWa; !! conversion $/GJ -> T$/TWa

*** Compute depreciation rates for technologies
p36_depreciationRate(teEs)$f36_datafecostsglob("lifetime",teEs) = - log (0.33) / f36_datafecostsglob("lifetime",teEs);

*** Define which technologies will have a faster reduction of their calibration parameter
p36_pushCalib(ttot,teEs) = 0;

$ifthen "%cm_INNOPATHS_pushCalib%" == "none" 
$elseif "%cm_INNOPATHS_pushCalib%" == "hydrogen"
teEs_pushCalib_dyn36("te_ueshh2b") = YES;
teEs_pushCalib_dyn36("te_uecwh2b") = YES;
p36_pushCalib(ttot,"te_ueshh2b") = 0;
p36_pushCalib(ttot,"te_uecwh2b") = 0.5;

p36_pushCalib(ttot,teEs_pushCalib_dyn36(teEs)) = 
      min(max((2050 -ttot.val)/(2050 - cm_startyear),0),1)  !! lambda = 1 in startyear and 0 in 2050     
      * ( 1 - p36_pushCalib(ttot,teEs))
      + p36_pushCalib(ttot,teEs) ;
$endif


*** Define for which technologies the investment costs will evolve
p36_costReduc(ttot,teEs_dyn36) = 1;

$ifthen "%cm_INNOPATHS_reducCostB%" == "none" 
$elseif "%cm_INNOPATHS_reducCostB%" == "hydrogen"

p36_costReduc(ttot,"te_ueshh2b") = 0.2;
p36_costReduc(ttot,"te_uecwh2b") = 0.5;

p36_costReduc(ttot,teEs_pushCalib_dyn36(teEs)) = 
      min(max((2050 -ttot.val)/(2050 - cm_startyear),0),1)  !! lambda = 1 in startyear and 0 in 2050     
      * ( 1 - p36_costReduc(ttot,teEs))
      + p36_costReduc(ttot,teEs) ;
      
$elseif "%cm_INNOPATHS_reducCostB%" == "heatpumps"
p36_costReduc(ttot,"te_ueshhpb") = 0.8;
p36_costReduc(ttot,"te_uecwhpb") = 0.8;

p36_costReduc(ttot,teEs_pushCalib_dyn36(teEs)) = 
      min(max((2050 -ttot.val)/(2050 - cm_startyear),0),1)  !! lambda = 1 in startyear and 0 in 2050     
      * ( 1 - p36_costReduc(ttot,teEs))
      + p36_costReduc(ttot,teEs) ;
$endif



*** Computation of omegs and opTimeYr2teEs for technology vintages
p36_omegEs(regi,opTimeYr,teEs_dyn36(teEs)) = 0;

loop(regi,
        p36_aux_lifetime(teEs_dyn36(teEs)) = 5/4 * f36_datafecostsglob("lifetime",teEs);
        loop(teEs_dyn36(teEs),

                loop(opTimeYr,
                        p36_omegEs(regi,opTimeYr,teEs) = 1 - ((opTimeYr.val-0.5) / p36_aux_lifetime(teEs))**4 ;
                        opTimeYr2teEs(teEs,opTimeYr)$(p36_omegEs(regi,opTimeYr,teEs) > 0 ) =  yes;
                        if( p36_omegEs(regi,opTimeYr,teEs) <= 0,
                                p36_omegEs(regi,opTimeYr,teEs) = 0;
                                opTimeYr2teEs(teEs,opTimeYr) =  no;
                        );
                )
        );
);
display p36_omegEs , opTimeYr2teEs ; 
***_____________________________END OF Information for the ES layer  and the multinomial logit function _____________________________


*** Adjustement cost factor
p36_adjFactor(ttot,regi) = 1;


*** Set dynamic regional set depending on testOneRegi
$ifthen "%optimization%" == "testOneRegi"
regi_dyn36(all_regi) = regi_dyn80(all_regi);
$else
regi_dyn36(all_regi) = regi(all_regi);
$endif

***-------------------------------------------------------------------------
***  pass on module specific parameter values to core parameters
***-------------------------------------------------------------------------

pm_fe2es(ttot,regi,teEs_dyn36) = p36_fe2es(ttot,regi,teEs_dyn36);
pm_shFeCes(ttot,regi,entyFe,in,teEs)$p36_shFeCes(ttot,regi,entyFe,in,teEs) = p36_shFeCes(ttot,regi,entyFe,in,teEs);
*** EOF ./modules/36_buildings/services_with_capital/datainput.gms
