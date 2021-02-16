*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/05_initialCap/on/preloop.gms

***------------------------------------------------------------------------------
*** Normalization of historical vintage structure - ESM
***------------------------------------------------------------------------------
*RP* Rescale vintages to 1 so they can be multiplied with the actual 2005 capacities coming from the intialization routine initialcap2
loop(regi,
  loop(te,
*--- Sum all historical capacities
    p05_aux_vintage_renormalization(regi,te)
      = sum(opTimeYr2te(te,opTimeYr)$( opTime5(opTimeYr) AND (opTimeYr.val > 1) ),
          (pm_vintage_in(regi,opTimeYr,te) * pm_omeg(regi,opTimeYr+1,te))
        )
        + pm_vintage_in(regi,"1",te) * pm_omeg(regi,"2",te) * 0.5;
*--- Normalization
    if(p05_aux_vintage_renormalization(regi,te) gt 0,
      p05_vintage(regi,opTimeYr,te) = pm_vintage_in(regi,opTimeYr,te)/p05_aux_vintage_renormalization(regi,te);
    );
  );
);
display p05_vintage;

***---------------------------------------------------------------------------
***           MODEL    initialcap2         START
***---------------------------------------------------------------------------
*** the following model calculates the initial capacities that are needed
*** to satisfy the internal and external energy demand at time t0.
s05_inic_switch = 1;

*** energy demand = external demand + sum of all (direct + indirect)
*** transformation pathways that consume this enty - sum of the indirect
*** transformation pathways that produce this enty
q05_eedemini(regi,enty)..
  v05_INIdemEn0(regi,enty)
  =e=
    !! Pathway I: FE to ppfEn.
    sum(fe2ppfEn(enty,in),
      pm_cesdata("2005",regi,in,"quantity")
    + pm_cesdata("2005",regi,in,"offset_quantity")
  ) * s05_inic_switch
    !! Pathway II: FE via UE to ppfEn
  + sum(ue2ppfen(enty,in),
      pm_cesdata("2005",regi,in,"quantity")
    + pm_cesdata("2005",regi,in,"offset_quantity")
    ) * s05_inic_switch
    !! Pathway III: FE via ES to ppfEn
    !! For the ES layer, we have to be consistent with conversion and share
    !! parameters when providing FE demands from CES node values.
  + sum(feViaEs2ppfen(enty,in,teEs),
      pm_shFeCes("2005",regi,enty,in,teEs)
    * ( pm_cesdata("2005",regi,in,"quantity")
      + pm_cesdata("2005",regi,in,"offset_quantity")
      )
    / ( sum(fe2es(enty2,esty,teEs2)$es2ppfen(esty,in),
          pm_fe2es("2005",regi,teEs2)
        * pm_shFeCes("2005",regi,enty2,in,teEs2)
        )
      )
    ) * s05_inic_switch
    !! Transformation pathways that consume this enty:
  + sum(en2en(enty,enty2,te),
      pm_cf("2005",regi,te)
    / pm_data(regi,"eta",te)
    * v05_INIcap0(regi,te)
    )
    !! subtract couple production pathways that produce this enty (= add couple production pathways that consume this enty):
  - sum(pc2te(enty3,enty4,te2,enty),
      pm_prodCouple(regi,enty3,enty4,te2,enty)
    * pm_cf("2005",regi,te2)
    * v05_INIcap0(regi,te2)
    )
;

*** capacity meets demand of the produced energy:
q05_ccapini(regi,en2en(enty,enty2,te)) ..
    pm_cf("2005",regi,te)
  * pm_dataren(regi,"nur","1",te)
  * v05_INIcap0(regi,te)
  =e=
    pm_data(regi,"mix0",te)
  * v05_INIdemEn0(regi,enty2)
;

display pm_data;

*** model definition
model initialcap2 / q05_eedemini, q05_ccapini /;

option limcol = 70;
option limrow = 70;

*** solve statement
if (execError > 0,
  execute_unload "abort.gdx";
  abort "at least one execution error occured, abort.gdx written";
);

solve initialcap2 using cns;

display v05_INIdemEn0.l, v05_INIcap0.l;

pm_cap0(regi,te) = v05_INIcap0.l(regi,te);

*RP keep energy demand for the Kyoto target calibration
pm_EN_demand_from_initialcap2(regi,enty) = v05_INIdemEn0.l(regi,enty);

*** write report about v05_INIcap0:
file report_capini;
put report_capini;
put "v05_INIcap0.l:" /;
     loop(regi,loop(te,
     put regi.tl, @15, te.tl, @30, v05_INIcap0.l(regi,te):10:7 /;
     ));
putclose report_capini;
*** write report on v05_INIdemEn0
file check_INIdemEn0 / check_INIdemEn0.csv /;
put check_INIdemEn0;
put "regi;enty;value";
put /;
loop((regi,enty),
  put regi.tl, ";" , enty.tl, ";" ;
  put v05_INIdemEn0.l(regi,enty):10:3 ;
  put /;
);
putclose check_INIdemEn0;

*AG* turn ESM calibration routine equations off (allows usage of model /all/ later)
v05_INIcap0.fx(regi,te)                = 0;
v05_INIdemEn0.fx(regi,enty)             = 0;
s05_inic_switch                       = 0;
***---------------------------------------------------------------------------
***           MODEL    initialcap2            END
***---------------------------------------------------------------------------

***---------------------------------------------------------------------------
***            Fix  to initialcap2           START
***---------------------------------------------------------------------------
*** Fix deltacaps until 2005 according to the vm_cap values calculated in initialcap2
*RP* First for renewables; this has to be different due to the different grades in the potential
*** and the way initialcap2 is formulated (it takes only the nur of the first grade into account)
vm_deltaCap.fx(tsu,regi,te,rlf)$(te2rlf(te,rlf))    = 0;
vm_deltaCap.fx("2005",regi,te,rlf)$(te2rlf(te,rlf)) = 0;

loop(regi,
  loop(teReNoBio(te),
    s05_aux_tot_prod
    = pm_cap0(regi,te)
    * pm_cf("2005",regi,te)
    * pm_dataren(regi,"nur","1",te);

    loop (pe2se(entyPe,entySe,te),
      o_INI_DirProdSeTe(regi,entySe,te) = s05_aux_tot_prod
    );
    s05_aux_prod_remaining = s05_aux_tot_prod;

    !! ensure that the production in 2005 is the same as in initialcap2
    loop (pe2se(entyPe,entySe,te),
      vm_prodSe.fx("2005",regi,entyPe,entySe,te)
      = s05_aux_tot_prod;
    );

    loop(teRe2rlfDetail(te,rlf),      !! fill up the renewable grades to calculate the total capacity needed to produce the amount calculated in initialcap2
        if(s05_aux_prod_remaining > 0,
            p05_aux_prod_thisgrade(rlf)    = min( 0.95 * pm_dataren(regi,"maxprod",rlf,te), s05_aux_prod_remaining) ;
            s05_aux_prod_remaining         = s05_aux_prod_remaining - p05_aux_prod_thisgrade(rlf);
            p05_aux_cap_distr(regi,te,rlf) = p05_aux_prod_thisgrade(rlf) / ( pm_cf("2005",regi,te) * pm_dataren(regi,"nur",rlf,te) );
        );
    ); !! teRe2rlfDetail
    p05_aux_cap(regi,te) = sum(teRe2rlfDetail(te,rlf), p05_aux_cap_distr(regi,te,rlf) );

    loop(opTimeYr2te(te,opTimeYr)$(teReNoBio(te)),
        loop(tsu2opTime5(ttot,opTimeYr),
            sm_tmp = 1 / pm_ts(ttot) * p05_aux_cap(regi,te) * p05_vintage(regi,opTimeYr,te);

            vm_deltaCap.lo(ttot,regi,te,"1") = sm_tmp;
            vm_deltaCap.up(ttot,regi,te,"1") = sm_tmp;
            vm_deltaCap.l(ttot,regi,te,"1")  = sm_tmp
        ); !! tsu2opTime5
    ); !! opTimeYr2te
  ); !! teReNoBio
); !! regi

*RP* for non-renewables
loop(regi,
  loop(opTimeYr2te(te,opTimeYr)$(NOT teReNoBio(te)),
    loop(tsu2opTime5(ttot,opTimeYr),
      loop(pe2se(entyPe,entySe,te), o_INI_DirProdSeTe(regi,entySe,te) = pm_cap0(regi,te) * pm_cf("2005",regi,te) * pm_dataren(regi,"nur","1",te) );
      sm_tmp = 1 / pm_ts(ttot) * pm_cap0(regi,te) * p05_vintage(regi,opTimeYr,te);

      vm_deltaCap.lo(ttot,regi,te,"1") = sm_tmp;
      vm_deltaCap.up(ttot,regi,te,"1") = sm_tmp;
      vm_deltaCap.l(ttot,regi,te,"1")  = sm_tmp
    );
  );
);
display vm_deltaCap.l;
***---------------------------------------------------------------------------
***                 Fix  to initialcap2      END
***---------------------------------------------------------------------------

***---------------------------------------------------------------------------
***           Calculate the lower bounds on capacities in 2010-2025  Start
***---------------------------------------------------------------------------

p05_aux_calccapLowerLimitSwitch(ttot)$(ttot.val < 2010) = 1;
p05_aux_calccapLowerLimitSwitch(ttot)$(ttot.val > 2005) = 0;
loop( ttot$( ( ttot.val > 2000 ) AND ( ttot.val < 2030 ) ),
  pm_aux_capLowerLimit(te,regi,ttot) =
***cb early retirement for some fossil technologies
*RP* assume no ER         (1 - vm_capEarlyReti(ttot,regi,te)) *
  (sum(opTimeYr2te(te,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
                    pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
                  * pm_omeg(regi,opTimeYr+1,te)
                  * vm_deltaCap.l(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te,"1") * p05_aux_calccapLowerLimitSwitch(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
              )
*LB* half of the last time step ttot
          +  pm_dt(ttot)/2
           * pm_omeg(regi,"2",te)
           * vm_deltaCap.l(ttot,regi,te,"1") * p05_aux_calccapLowerLimitSwitch(ttot)
  )
  ;
);
option pm_aux_capLowerLimit:5:1:1;
display pm_aux_capLowerLimit;


***---------------------------------------------------------------------------
***           Calculate the lower bounds on capacities in 2010-2025   END
***---------------------------------------------------------------------------


***---------------------------------------------------------------------------
***            Calculate aggregated power sector numbers for 2005     START
***---------------------------------------------------------------------------

loop(regi,
  o_INI_TotalCap(regi)            = sum(pe2se(enty,"seel",te), pm_cap0(regi,te) );
  o_INI_TotalDirProdSe(regi,entySe) = sum(pe2se(enty,entySe,te), o_INI_DirProdSeTe(regi,entySe,te) );
  o_INI_AvCapFac(regi)            = o_INI_TotalDirProdSe(regi,"seel") / o_INI_TotalCap(regi);
);

display
o_INI_DirProdSeTe
o_INI_TotalCap
o_INI_TotalDirProdSe
o_INI_AvCapFac
pm_cap0
;

***---------------------------------------------------------------------------
***            Calculate aggregated power sector numbers for 2005     END
***---------------------------------------------------------------------------

***---------------------------------------------------------------------------
***      recalibrate time-variable etas     START
***---------------------------------------------------------------------------
*RP* In this section, the conversion technology efficiencies (etas) are recalibrated to fit the original 2005 PE-FE calibration (initialcap2)
*** This is required as the time-variable etas (pm_dataeta) follow the same time path for all regions (read-in in generisdata_varying_eta), but the calibration
*** in 2005 to IEA (2007) values results in different regional etas (pm_dataeta).
*** Procedure:
*** Step 1: calculate the initial average eta from the initial input and output that would result from the past deltacap values
***         coming out of initialcap2 (needs to be calculated because of the different etas in the past)
*** Step 2: compare this average eta-value to the eta-value used in the 2005-calibration
*** Step 3: shift all pm_dataeta-values from 1900 to 2005 up/down by the correction factor deduced in step 2
*** Step 4: check if the recalibration of past dataetas worked
*** Step 5: apply the 2005 recalibration to later dataetas, with fade-out until 2025

display pm_dataeta;

p05_eta_correct_factor(regi,te) = 1;

loop(regi,
  loop(te$((teEtaIncr(te)) AND (pm_cap0(regi,te) > 1.E-8)),
    p05_initial_capacity(regi,te)
    = sum(ttot$sameas(ttot,"2005"),
        sum(teSe2rlf(te,rlf),
          sum(opTimeYr2te(te,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
            pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
            * pm_omeg(regi,opTimeYr+1,te)
            * vm_deltaCap.lo(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te,rlf)
          )
*LB* add half of the last time step ttot
          + pm_dt(ttot)/2
          * pm_omeg(regi,"2",te)
          * vm_deltaCap.lo(ttot,regi,te,rlf)
        )
      );
      p05_inital_output(regi,te)
      = sum(ttot$sameas(ttot,"2005"),
          pm_cf(ttot,regi,te)
          * sum(teSe2rlf(te,rlf),
              sum(opTimeYr2te(te,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
                pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
                * pm_omeg(regi,opTimeYr+1,te)
                * vm_deltaCap.lo(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te,rlf)
              )
*LB* add half of the last time step ttot
              + pm_dt(ttot)/2
              * pm_omeg(regi,"2",te)
              * vm_deltaCap.lo(ttot,regi,te,rlf)
            )
        );
        p05_inital_input(regi,te)
        = sum(ttot$sameas(ttot,"2005"),
            sum(teSe2rlf(teEtaIncr(te),rlf),
              pm_cf(ttot,regi,te)
              *(sum(opTimeYr2te(te,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
                  pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
                  / pm_dataeta(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te)
                  * pm_omeg(regi,opTimeYr+1,te)
                  * vm_deltaCap.lo(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te,rlf)
                )
*LB* add half of the last time step ttot
                + (pm_dt(ttot)/2)
                / pm_dataeta(ttot,regi,te)
                * pm_omeg(regi,"2",te)
                * vm_deltaCap.lo(ttot,regi,te,rlf)
              )
            )
          );
          p05_inital_eta(regi,te)         = p05_inital_output(regi,te) / p05_inital_input(regi,te);
          p05_eta_correct_factor(regi,te) = pm_data(regi,"eta",te) / p05_inital_eta(regi,te);
          loop(ttot$(ttot.val < 2010),
            pm_dataeta(ttot,regi,te) = pm_dataeta(ttot,regi,te) * p05_eta_correct_factor(regi,te);
          );
*** test the correction:
          p05_corrected_inital_input(regi,te)
          = sum(ttot$sameas(ttot,"2005"),
              sum(teSe2rlf(teEtaIncr(te),rlf),
                pm_cf(ttot,regi,te)
                *(sum(opTimeYr2te(te,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
                    pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
                    / pm_dataeta(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te)
                    * pm_omeg(regi,opTimeYr+1,te)
                    * vm_deltaCap.lo(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te,rlf)
                  )
*LB* add half of the last time step ttot
                  +  (pm_dt(ttot)/2)
                  / pm_dataeta(ttot,regi,te)
                  * pm_omeg(regi,"2",te)
                  * vm_deltaCap.lo(ttot,regi,te,rlf)
                 )
              )
            );

            p05_corrected_inital_eta(regi,te) = p05_inital_output(regi,te)/p05_corrected_inital_input(regi,te);
        ); !! te
); !! regi

*RP: The eta correction worked if corrected_initial_eta is now the same as pm_data("eta"), as pm_data("eta") is used in intialcap2
*RP* apply the eta correction also to the related technologies which are not yet built in  2005 - it is unreasonable to assume that power plants in a region
*** will be suddenly better if you change the type of technology
loop(regi,
  p05_eta_correct_factor(regi,"igcc")  = p05_eta_correct_factor(regi,"pc");
  p05_eta_correct_factor(regi,"coalchp")  = p05_eta_correct_factor(regi,"pc");
  p05_eta_correct_factor(regi,"biochp")  = p05_eta_correct_factor(regi,"pc");
  p05_eta_correct_factor(regi,"pco")   = p05_eta_correct_factor(regi,"pc");
  p05_eta_correct_factor(regi,"pcc")   = p05_eta_correct_factor(regi,"pc");
  p05_eta_correct_factor(regi,"igccc") = p05_eta_correct_factor(regi,"pc");
  p05_eta_correct_factor(regi,"ngccc") = p05_eta_correct_factor(regi,"ngcc");
    p05_eta_correct_factor(regi,"gaschp")  = p05_eta_correct_factor(regi,"ngcc");
*RP* for teEtaIncr-technologies, set the 2005 value of pm_dataeta, and the rest will be scaled accordingly
  pm_dataeta("2005",regi,"igcc")      = pm_dataeta("2005",regi,"igcc")  * p05_eta_correct_factor(regi,"pc");
  pm_dataeta("2005",regi,"igccc")     = pm_dataeta("2005",regi,"igccc") * p05_eta_correct_factor(regi,"pc");
  pm_dataeta("2005",regi,"ngccc")     = pm_dataeta("2005",regi,"ngccc") * p05_eta_correct_factor(regi,"ngcc");
*RP* for teEtaConst-technologies, set pm_data("eta"), and the rest will be scaled accordingly. Carefull - this is only ok if mix0 = 0, else it would override calibration values
  if( (pm_data(regi,"mix0","pcc") eq 0),
    pm_data(regi,"eta","pcc") =  fm_dataglob("eta","pcc") * p05_eta_correct_factor(regi,"pcc");
  );
  if( (pm_data(regi,"mix0","pco") eq 0),
    pm_data(regi,"eta","pco") =  fm_dataglob("eta","pco") * p05_eta_correct_factor(regi,"pco");
  );
  if( (pm_data(regi,"mix0","coalchp") eq 0),
    pm_data(regi,"eta","coalchp") =  fm_dataglob("eta","coalchp") * p05_eta_correct_factor(regi,"coalchp");
  );
  if( (pm_data(regi,"mix0","gaschp") eq 0),
    pm_data(regi,"eta","gaschp") =  fm_dataglob("eta","gaschp") * p05_eta_correct_factor(regi,"gaschp");
  );
  if( (pm_data(regi,"mix0","biochp") eq 0),
    pm_data(regi,"eta","biochp") =  fm_dataglob("eta","biochp") * p05_eta_correct_factor(regi,"biochp");
  );
);
*RP* slowly fade out recalibration in the next 15 years:
loop(ttot$((ttot.val le 2030) AND (ttot.val ge 2010)),
   pm_dataeta(ttot,regi,te) = pm_dataeta(ttot,regi,te) * 1/ (2030-2005) * (((2030-ttot.val) * p05_eta_correct_factor(regi,te)) + (ttot.val-2005));
);

display p05_inital_eta, p05_corrected_inital_eta, pm_data, pm_dataeta;

*RP*   Also converge not explicitly time-variable eta until 2050
*** For technologies with not explicit time-varying etas also need to be adjusted, if we don't want to keep the regional differences resulting from the 2005-IEA-calibration (aggregation based on IEA World Energy Balances, 2007)
*** (values in pm_data("eta") for the whole time horizon. For these technologies, the etas are not vintage-dependent, but rather etas change FOR ALL STANDING CAPACITIES in each time step.
*** We therefore fade out the 2005 etas until 2050 to the initial values that are read-in from generisdata_tech (now in fm_dataglob("eta")).
loop(regi,
  loop(teEtaConst(te)$(NOT teCHP(te)),
    loop(ttot$(ttot.val < 2010),
      pm_eta_conv(ttot,regi,te) = pm_data(regi,"eta",te) ;
    )
    loop(ttot$((ttot.val > 2005) AND (ttot.val <= 2050)),
      pm_eta_conv(ttot,regi,te) = pm_data(regi,"eta",te) + ( fm_dataglob("eta",te) - pm_data(regi,"eta",te) ) * (ttot.val - 2005) / (2050-2005) ;
    )
    loop(ttot$(ttot.val > 2050),
      pm_eta_conv(ttot,regi,te) = fm_dataglob("eta",te);
    )
  );
);
pm_eta_conv(ttot,regi,teCHP) = pm_data(regi,"eta",teCHP)

display pm_eta_conv, fm_dataglob;


*RP* Regions where efficiency is below the average see this lower efficiency also for new construction - therefore these plants should be cheaper (e.g., subcritical instead of supercritical coal)
$if %cm_techcosts% == "GLO"   loop(ttot$((ttot.val le 2030) AND (ttot.val ge 2005)),
$if %cm_techcosts% == "GLO"     loop(te$( teEtaIncr(te) AND (sameas(te,"pc") OR sameas(te,"ngt") OR  sameas(te,"ngcc") ) ),
$if %cm_techcosts% == "GLO"      pm_inco0_t(ttot,regi,te) = pm_inco0_t(ttot,regi,te) * 1/ (2030-2005) * (((2030-ttot.val) * p05_eta_correct_factor(regi,te)) + (ttot.val-2005));
$if %cm_techcosts% == "GLO"     );
$if %cm_techcosts% == "GLO"   );
$if %cm_techcosts% == "GLO"   loop(ttot$((ttot.val le 2050) AND (ttot.val ge 2005)),
$if %cm_techcosts% == "GLO"     loop(te$(teEtaConst(te) AND ( sameas(te,"pc") OR sameas(te,"ngt") OR  sameas(te,"ngcc") ) ),
$if %cm_techcosts% == "GLO"       pm_inco0_t(ttot,regi,te) = pm_inco0_t(ttot,regi,te) *  ( 1 - ( fm_dataglob("eta",te) - pm_data(regi,"eta",te) ) / fm_dataglob("eta",te)  * (2050 - ttot.val) / (2050-2005) )
$if %cm_techcosts% == "GLO"     );
$if %cm_techcosts% == "GLO"   );
display  pm_inco0_t;

***---------------------------------------------------------------------------
***      recalibrate time-variable etas     END
***---------------------------------------------------------------------------


***---------------------------------------------------------------------------
***      Enhancing residue potential     START
***---------------------------------------------------------------------------
*DK* Enhancing residue potential to make sure that the whole demand
***  for traditional biomass technology (biotr) can be satisfied by residues
***  and no purpose grown biomass is taken for traditional biomass

*** Assume all technologies phase out after 2005
p05_deltacap_res(ttot,regi,te) = 0;
p05_deltacap_res(ttot,regi,teBioPebiolc) = vm_deltaCap.l(ttot,regi,teBioPebiolc,"1")$(ttot.val le 2005);
*** Phase out of biotr is given exougenously
*** Note: make sure that this matches with the phaseout in core/bounds.gms

* BS/DK* Developed regions phase out quickly (no new capacities)
* BS/DK* Developing regions (GDP PPP threshold) phase out more slowly (varied by SSP)
loop(regi,
     if( ( pm_gdp("2005",regi)/pm_pop("2005",regi) / pm_shPPPMER(regi) ) < 4,
          p05_deltacap_res("2010",regi,"biotr") = 1.3  * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2015",regi,"biotr") = 0.9  * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2020",regi,"biotr") = 0.7  * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2025",regi,"biotr") = 0.5  * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2030",regi,"biotr") = 0.4  * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2035",regi,"biotr") = 0.3  * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2040",regi,"biotr") = 0.2  * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2045",regi,"biotr") = 0.15 * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2050",regi,"biotr") = 0.1  * vm_deltaCap.lo("2005",regi,"biotr","1");
          p05_deltacap_res("2055",regi,"biotr") = 0.1  * vm_deltaCap.lo("2005",regi,"biotr","1");
      );
);

* quickest phaseout in SDP (no new capacities allowed), quick phaseout in SSP1 und SSP5
$if %cm_GDPscen% == "gdp_SDP"  p05_deltacap_res(t,regi,"biotr")$(t.val gt 2020) = 0. * p05_deltacap_res(t,regi,"biotr");
$if %cm_GDPscen% == "gdp_SSP1" p05_deltacap_res(t,regi,"biotr")$(t.val gt 2020) = 0.5 * p05_deltacap_res(t,regi,"biotr");
$if %cm_GDPscen% == "gdp_SSP5" p05_deltacap_res(t,regi,"biotr")$(t.val gt 2020) = 0.5 * p05_deltacap_res(t,regi,"biotr");

display p05_deltacap_res;

p05_cap_res(ttot,regi,teBioPebiolc) =
  sum(opTimeYr2te(teBioPebiolc,opTimeYr)$tsu2opTimeYr(ttot,opTimeYr),
    pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1)) * pm_omeg(regi,opTimeYr,teBioPebiolc)
    * p05_deltacap_res(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,teBioPebiolc)
  )
;
*** PE demand for pebiolc resulting from all technologies using pebiols assuming they would phase out after 2005
pm_pedem_res(ttot,regi,teBioPebiolc) = p05_cap_res(ttot,regi,teBioPebiolc)* pm_cf(ttot,regi,teBioPebiolc) / pm_data(regi,"eta",teBioPebiolc);

display p05_deltacap_res,p05_cap_res,pm_pedem_res;
***---------------------------------------------------------------------------
***      Enhancing residue potential     END
***---------------------------------------------------------------------------

***------------------------------------------------------------------------------
***------------------------------------------------------------------------------
***                            EMISSIONS
***------------------------------------------------------------------------------
***------------------------------------------------------------------------------
*gl Establish upper bounds for CO2 emissions based on Kyoto targets for EUR, JPN, RUS
*gl detail see Kyoto_targets.xls
*gl no targets for non-Annex I, USA (has not ratified Kyoto), ROW (hot air in EITs, non-compliance of CAN)
loop(regi,
  p05_emi2005_from_initialcap2(regi,emiTe) =
    sum(pe2se(enty,enty2,te),
      pm_emifac("2005",regi,enty,enty2,te,emiTe)
      * 1/(pm_data(regi,"eta",te)) * pm_cf("2005",regi,te) * pm_cap0(regi,te)
    )
    +
    sum(se2fe(enty,enty2,te),
      pm_emifac("2005",regi,enty,enty2,te,emiTe) * pm_cf("2005",regi,te) * pm_cap0(regi,te)
    );
*** no CCS leakage in the first time step
);
display pm_EN_demand_from_initialcap2, p05_emi2005_from_initialcap2;

*** To be moved to new emiAccounting module
* Discounting se2fe emissions from pe2se emission factors
loop(entySe$(sameas(entySe,"segafos") OR sameas(entySe,"seliqfos") OR sameas(entySe,"sesofos")),
  pm_emifac(ttot,regi,entyPe,entySe,te,"co2")$pm_emifac(ttot,regi,entyPe,entySe,te,"co2") = 
    pm_emifac(ttot,regi,entyPe,entySe,te,"co2") 
    - pm_eta_conv(ttot,regi,te)
      *( sum(se2fe(entySe,entyFe2,te2)$pm_emifac(ttot,regi,entySe,entyFe2,te2,"co2"), pm_emifac(ttot,regi,entySe,entyFe2,te2,"co2")*pm_eta_conv(ttot,regi,te2))/sum(se2fe(entySe,entyFe2,te2)$pm_emifac(ttot,regi,entySe,entyFe2,te2,"co2"),1)  );
);

display pm_emifac;


*** EOF ./modules/05_initialCap/on/preloop.gms

