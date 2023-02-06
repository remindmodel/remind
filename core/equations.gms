*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/equations.gms
***---------------------------------------------------------------------------
***---------------------------------------------------------------------------
***---------------------------------------------------------------------------
*** DEFINITION OF MODEL EQUATIONS:
***---------------------------------------------------------------------------
***---------------------------------------------------------------------------

***---------------------------------------------------------------------------
*' Fuel costs are associated with the use of exhaustible primary energy (fossils, uranium) and biomass.
***---------------------------------------------------------------------------
q_costFu(t,regi)..
  v_costFu(t,regi)
  =e=
  vm_costFuBio(t,regi) + sum(peEx(enty), vm_costFuEx(t,regi,enty))
;

***---------------------------------------------------------------------------
*' Specific investment costs of learning technologies are a model-endogenous variable; 
*' those of non-learning technologies are fixed to constant values. 
*' Total investment costs are the product of specific costs and capacity additions plus adjustment costs.
***---------------------------------------------------------------------------
q_costInv(t,regi)..
  v_costInv(t,regi)
  =e=
*** investment cost of conversion technologies
  sum(en2en(enty,enty2,te),
    v_costInvTeDir(t,regi,te) + v_costInvTeAdj(t,regi,te)$teAdj(te)
  )
  +
*** investment cost of non-conversion technologies (storage, grid etc.)
  sum(teNoTransform,
    v_costInvTeDir(t,regi,teNoTransform) + v_costInvTeAdj(t,regi,teNoTransform)$teAdj(teNoTransform)
  )
*** additional transmission and distribution cost (increases hydrogen cost at low hydrogen penetration levels when hydrogen infrastructure is not yet developed) 
  +
  sum(sector2te_addTDCost(sector,te),
    vm_costAddTeInv(t,regi,te,sector)
  )
*** end-use transformation cost of novel technologies placed on CES nodes that are to be accounted in the budget equation
  +
  sum(in$(ppfen_CESMkup(in)),
    vm_costCESMkup(t,regi,in)
  )
;


*** investment costs
q_costInvTeDir(t,regi,te)..
  v_costInvTeDir(t,regi,te)
  =e=
  vm_costTeCapital(t,regi,te) * sum(te2rlf(te,rlf), vm_deltaCap(t,regi,te,rlf) )
;


*RP* 2011-12-01 remove global adjustment costs to decrease runtime, only keep regional adjustment costs. Maybe change in the future.
v_adjFactorGlob.fx(t,regi,te) = 0;

*RP* 2010-05-10 adjustment costs
q_costInvTeAdj(t,regi,teAdj)..
  v_costInvTeAdj(t,regi,teAdj)
  =e=
  vm_costTeCapital(t,regi,teAdj) * ( (p_adj_coeff(t,regi,teAdj) * v_adjFactor(t,regi,teAdj)) + (p_adj_coeff_glob(teAdj) * v_adjFactorGlob(t,regi,teAdj) ) )
;

***---------------------------------------------------------------------------
*' Operation and maintenance costs from maintenance of existing facilities according to their capacity and
*' operation of energy transformations according to the amount of produced secondary and final energy.
***---------------------------------------------------------------------------
q_costOM(t,regi)..
  v_costOM(t,regi)
  =e=
  sum(en2en(enty,enty2,te),
    pm_data(regi,"omf",te) 
    * sum(te2rlf(te,rlf), vm_costTeCapital(t,regi,te) * vm_cap(t,regi,te,rlf) )
    +
    pm_data(regi,"omv",te)
      * (vm_prodSe(t,regi,enty,enty2,te)$entySe(enty2)
         + vm_prodFe(t,regi,enty,enty2,te)$entyFe(enty2))
  )
  +
  sum(teNoTransform(te),
     pm_data(regi,"omf",te)
          * sum(te2rlf(te,rlf),
             vm_costTeCapital(t,regi,te) * vm_cap(t,regi,te,rlf)
            )
  )
  + vm_omcosts_cdr(t,regi)
;

***---------------------------------------------------------------------------
*' Energy balance equations equate the production of and demand for each primary, secondary and final energy.
*' The balance equation for primary energy equals supply of primary energy demand on primary energy.
***---------------------------------------------------------------------------
q_balPe(t,regi,entyPe(enty))..
         vm_prodPe(t,regi,enty) + p_macPE(t,regi,enty)
         =e=
         sum(pe2se(enty,enty2,te), vm_demPe(t,regi,enty,enty2,te))
*** through p_datacs one could correct for non-energetic use, e.g. bitumen for roads; set to 0 in current version, as the total oil value already contains the non-energy use part
         + p_datacs(regi,enty) / 0.95 
;


***---------------------------------------------------------------------------
*' The secondary energy balance comprises the following terms (except power, defined on module):
*' 1. Secondary energy can be produced from primary or (another type of) secondary energy.
*' 2. Own consumption of secondary energy occurs from the production of secondary and final energy, and from CCS technologies. 
*'Own consumption is calculated as the product of the respective production and a negative coefficient. 
*'The mapping defines possible combinations: the first two enty types of the mapping define the underlying
*'transformation process, the 3rd argument the technology, and the 4th argument specifies the consumed energy type.
*' 3. Couple production is modeled as own consumption, but with a positive coefficient.
*' 4. Secondary energy can be demanded to produce final or (another type of) secondary energy.
***---------------------------------------------------------------------------
q_balSe(t,regi,enty2)$( entySE(enty2) AND (NOT (sameas(enty2,"seel"))) )..
    sum(pe2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te))
  + sum(se2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te))
  + sum(pc2te(enty,entySE(enty3),te,enty2), 
      pm_prodCouple(regi,enty,enty3,te,enty2) 
    * vm_prodSe(t,regi,enty,enty3,te)
         )
  + sum(pc2te(enty4,entyFE(enty5),te,enty2), 
      pm_prodCouple(regi,enty4,enty5,te,enty2) 
    * vm_prodFe(t,regi,enty4,enty5,te)
    )
  + sum(pc2te(enty,enty3,te,enty2),
                sum(teCCS2rlf(te,rlf),
        pm_prodCouple(regi,enty,enty3,te,enty2) 
      * vm_co2CCS(t,regi,enty,enty3,te,rlf)
                )
         )
***   add (reused gas from waste landfills) to segas to not account for CO2 
***   emissions - it comes from biomass
  + ( s_MtCH4_2_TWa
    * ( vm_macBase(t,regi,"ch4wstl")
      - vm_emiMacSector(t,regi,"ch4wstl")
      )
    )$( sameas(enty2,"segabio") AND t.val gt 2005 )
  + sum(prodSeOth2te(enty2,te), vm_prodSeOth(t,regi,enty2,te) ) 
  + vm_Mport(t,regi,enty2) 
  =e=
    sum(se2fe(enty2,enty3,te), vm_demSe(t,regi,enty2,enty3,te))
  + sum(se2se(enty2,enty3,te), vm_demSe(t,regi,enty2,enty3,te))
  + sum(demSeOth2te(enty2,te), vm_demSeOth(t,regi,enty2,te) )  
  + vm_Xport(t,regi,enty2)
;

***---------------------------------------------------------------------------
*' Taking the technology-specific transformation eficiency into account, 
*' the equations describe the transformation of an energy type to another type.
*' Depending on the detail of the technology representation, the transformation technology's eficiency
*' can depend either only on the current year or on the year when a specific technology was built.
*' Transformation from primary to secondary energy: 
***---------------------------------------------------------------------------
*MLB 05/2008* correction factor included to avoid pre-triangular infeasibility
q_transPe2se(ttot,regi,pe2se(enty,enty2,te))$(ttot.val ge cm_startyear)..
         vm_demPe(ttot,regi,enty,enty2,te)
         =e=
         (1 / pm_eta_conv(ttot,regi,te) * vm_prodSe(ttot,regi,enty,enty2,te))$teEtaConst(te)
         +
***cb early retirement for some fossil technologies
        (1 - vm_capEarlyReti(ttot,regi,te))
        *

		sum(teSe2rlf(teEtaIncr(te),rlf),
                vm_capFac(ttot,regi,te)
             * (
                 sum(opTimeYr2te(te,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
                        pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1)) 
                      / pm_dataeta(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te) 
                      * pm_omeg(regi,opTimeYr+1,te)
                                * vm_deltaCap(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te,rlf)
                      )
*LB* add half of the last time step ttot
               +  pm_dt(ttot)/2 / pm_dataeta(ttot,regi,te)
                * pm_omeg(regi,"2",te)
                * vm_deltaCap(ttot,regi,te,rlf)   
                )
            );

***---------------------------------------------------------------------------
*' Transformation from secondary to final energy:
***---------------------------------------------------------------------------
q_transSe2fe(t,regi,se2fe(entySe,entyFe,te))..
         pm_eta_conv(t,regi,te) * vm_demSe(t,regi,entySe,entyFe,te)
         =e=
         vm_prodFe(t,regi,entySe,entyFe,te) 
;


***---------------------------------------------------------------------------
*' Transformation between secondary energy types:
***---------------------------------------------------------------------------
q_transSe2se(t,regi,se2se(enty,enty2,te))..
         pm_eta_conv(t,regi,te) * vm_demSe(t,regi,enty,enty2,te)
         =e=
         vm_prodSe(t,regi,enty,enty2,te);


***---------------------------------------------------------------------------
*** FE Balance
***---------------------------------------------------------------------------
qm_balFe(t,regi,entySe,entyFe,te)$se2fe(entySe,entyFe,te)..
  vm_prodFe(t,regi,entySe,entyFe,te)
  =e=
  sum((sector2emiMkt(sector,emiMkt),entyFE2sector(entyFE,sector)),
    vm_demFEsector(t,regi,entySE,entyFE,sector,emiMkt)
  )
;

*' FE balance equation including FE sectoral taxes effect
q_balFeAfterTax(t,regi,entySe,entyFe,sector,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt))..
  vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)
  =e=
  vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt)
; 

***To be moved to specific modules---------------------------------------------------------------------------
*' FE Pathway III: Energy service layer (prodFe -> demFeForEs -> prodEs), no capacity tracking.
***---------------------------------------------------------------------------

*' Transformation from final energy to energy services:
q_transFe2Es(t,regi,fe2es(entyFe,esty,teEs))..
    pm_fe2es(t,regi,teEs) * vm_demFeForEs(t,regi,entyFe,esty,teEs)
    =e=
    vm_prodEs(t,regi,entyFe,esty,teEs);

*' Hand-over to CES:
q_es2ppfen(t,regi,in)$ppfenFromEs(in)..
    vm_cesIO(t,regi,in) + pm_cesdata(t,regi,in,"offset_quantity")
    =e=
    sum(fe2es(entyFe,esty,teEs)$es2ppfen(esty,in), vm_prodEs(t,regi,entyFe,esty,teEs))
;

*' Shares of FE carriers w.r.t. a CES node:
q_shFeCes(t,regi,entyFe,in,teEs)$feViaEs2ppfen(entyFe,in,teEs)..
    sum(fe2es(entyFe2,esty,teEs2)$es2ppfen(esty,in), vm_demFeForEs(t,regi,entyFe2,esty,teEs2))
    * pm_shFeCes(t,regi,entyFe,in,teEs)
    =e=
    sum(fe2es(entyFe,esty,teEs)$es2ppfen(esty,in), vm_demFeForEs(t,regi,entyFe,esty,teEs))
;

***---------------------------------------------------------------------------
*' Definition of capacity constraints for primary energy to secondary energy transformation:
***--------------------------------------------------------------------------
q_limitCapSe(t,regi,pe2se(enty,enty2,te))..
        vm_prodSe(t,regi,enty,enty2,te)
        =e=
        sum(teSe2rlf(te,rlf),
               vm_capFac(t,regi,te) * pm_dataren(regi,"nur",rlf,te)
               * vm_cap(t,regi,te,rlf)
        )$(NOT teReNoBio(te))
    +
        sum(teRe2rlfDetail(te,rlf),
               ( 1$teRLDCDisp(te) +  pm_dataren(regi,"nur",rlf,te)$(NOT teRLDCDisp(te)) ) * vm_capFac(t,regi,te)  
               * vm_capDistr(t,regi,te,rlf)
        )$(teReNoBio(te))
;

***----------------------------------------------------------------------------
*' Definition of capacity constraints for secondary energy to secondary energy transformation:
***---------------------------------------------------------------------------
q_limitCapSe2se(t,regi,se2se(enty,enty2,te))..
         vm_prodSe(t,regi,enty,enty2,te)
         =e=
         sum(teSe2rlf(te,rlf),
                vm_capFac(t,regi,te) * pm_dataren(regi,"nur",rlf,te)
                * vm_cap(t,regi,te,rlf)
         );

***---------------------------------------------------------------------------
*' Definition of capacity constraints for secondary energy to final energy transformation:
***---------------------------------------------------------------------------
q_limitCapFe(t,regi,te)..
         sum((entySe,entyFe)$(se2fe(entySe,entyFe,te)), vm_prodFe(t,regi,entySe,entyFe,te))
         =l=
         sum(teFe2rlf(te,rlf), vm_capFac(t,regi,te) * vm_cap(t,regi,te,rlf));

***---------------------------------------------------------------------------
*' Definition of capacity constraints for CCS technologies:
***---------------------------------------------------------------------------
q_limitCapCCS(t,regi,ccs2te(enty,enty2,te),rlf)$teCCS2rlf(te,rlf)..
         vm_co2CCS(t,regi,enty,enty2,te,rlf)
         =e=
         sum(teCCS2rlf(te,rlf), vm_capFac(t,regi,te) * vm_cap(t,regi,te,rlf));

***-----------------------------------------------------------------------------
*' The capacities of vintaged technologies depreciate according to a vintage depreciation scheme, 
*' with generally low depreciation at the beginning of the lifetime, and fast depreciation around the average lifetime. 
*' Depreciation can generally be tracked for each grade separately. 
*' By implementation, however, only grades of level 1 are affected. The depreciation of any fossil
*' technology can be accelerated by early retirement, which is a crucial way to quickly phase out emissions 
*' after the implementation of stringent climate policies.
*' Calculation of actual capacities (exponential and vintage growth TE):
***-----------------------------------------------------------------------------

q_cap(ttot,regi,te2rlf(te,rlf))$(ttot.val ge cm_startyear)..
         vm_cap(ttot,regi,te,rlf)
         =e=
    !! early retirement for some fossil technologies
        (1 - vm_capEarlyReti(ttot,regi,te))
        *

        (sum(opTimeYr2te(te,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val gt 1) ),
                  pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1)) 
                * pm_omeg(regi,opTimeYr+1,te)
                * vm_deltaCap(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te,rlf)
            )
       !! half of the last time step ttot
        +  ( pm_dt(ttot) / 2 
       * pm_omeg(regi,"2",te)
       * vm_deltaCap(ttot,regi,te,rlf)
            )
         )
;

q_capDistr(t,regi,teReNoBio(te))..
    sum(teRe2rlfDetail(te,rlf), vm_capDistr(t,regi,te,rlf) )
    =e=
    vm_cap(t,regi,te,"1")
;


***---------------------------------------------------------------------------
*' Calculation of total primary to secondary energy capacities 
*' Used for comfortably setting bounds on total capacity without technology differentiation.
***--------------------------------------------------------------------------
q_capTotal(t,regi,entyPe,entySe)$( capTotal(entyPe,entySe))..
  vm_capTotal(t,regi,entyPe,entySe)
  =e=
  sum( pe2se(entyPe, entySe, te), 
    vm_cap(t,regi,te,"1"))
;

***---------------------------------------------------------------------------
*' CG: implementing simple exogenous wind offshore energy production
*'
***---------------------------------------------------------------------------
$IFTHEN.WindOff %cm_wind_offshore% == "1"
q_windoff_low(t,regi)$(t.val > 2020)..
   sum(rlf, vm_deltaCap(t,regi,"windoff",rlf))
   =g=
   pm_shareWindOff(t,regi) * pm_shareWindPotentialOff2On(regi) * 0.5 * sum(rlf, vm_deltaCap(t,regi,"wind",rlf))
;

q_windoff_high(t,regi)$(t.val > 2020)..
   sum(rlf, vm_deltaCap(t,regi,"windoff",rlf))
   =l=
   pm_shareWindOff(t,regi) * pm_shareWindPotentialOff2On(regi) * 2 * sum(rlf, vm_deltaCap(t,regi,"wind",rlf))
;

$ENDIF.WindOff
***---------------------------------------------------------------------------
*' Technological change is an important driver of the evolution of energy systems.
*' For mature technologies, such as coal-fired power plants, the evolution
*' of techno-economic parameters is prescribed exogenously. For less mature
*' technologies with substantial potential for cost decreases via learning-bydoing,
*' investment costs are determined via an endogenous one-factor learning
*' curve approach that assumes floor costs.
***---------------------------------------------------------------------------
***---------------------------------------------------------------------------
*' Calculation of cumulated capacities (learning technologies only):
***---------------------------------------------------------------------------
qm_deltaCapCumNet(ttot,regi,teLearn)$(ord(ttot) lt card(ttot) AND pm_ttot_val(ttot+1) ge max(2010, cm_startyear))..
  vm_capCum(ttot+1,regi,teLearn)
  =e=
  sum(te2rlf(teLearn,rlf),
         (pm_ts(ttot) / 2 * vm_deltaCap(ttot,regi,teLearn,rlf)) + (pm_ts(ttot+1) / 2 * vm_deltaCap(ttot+1,regi,teLearn,rlf))
  )
  +
  vm_capCum(ttot,regi,teLearn);

***---------------------------------------------------------------------------
*' Initial values for cumulated capacities (learning technologies only):
*' (except for tech_stat 4 technologies that have no standing capacities in 2005 and ccap0 refers to another year)
***---------------------------------------------------------------------------
q_capCumNet(t0,regi,teLearn)$(NOT (pm_data(regi,"tech_stat",teLearn) eq 4))..
  vm_capCum(t0,regi,teLearn)
  =e=
  pm_data(regi,"ccap0",teLearn);

***---------------------------------------------------------------------------
*' Additional equation for fuel shadow price calulation:
***---------------------------------------------------------------------------
*ml* reasonable results only for members of peExGrade and peren2rlf30
*NB*110625 changes for transition towards grades
qm_fuel2pe(t,regi,peRicardian(enty))..
  vm_prodPe(t,regi,enty)
  =e=
  sum(pe2rlf(enty,rlf2),vm_fuExtr(t,regi,enty,rlf2))-(vm_Xport(t,regi,enty)-(1-pm_costsPEtradeMp(regi,enty))*vm_Mport(t,regi,enty))$(tradePe(enty)) -
                      sum(pe2rlf(enty2,rlf2), (pm_fuExtrOwnCons(regi, enty, enty2) * vm_fuExtr(t,regi,enty2,rlf2))$(pm_fuExtrOwnCons(regi, enty, enty2) gt 0));

***---------------------------------------------------------------------------
*' Definition of resource constraints for renewable energy types:
***---------------------------------------------------------------------------
*ml* assuming maxprod to be technical potential
q_limitProd(t,regi,teRe2rlfDetail(teReNoBio(te),rlf))..
  pm_dataren(regi,"maxprod",rlf,te)
  =g=
  ( 1$teRLDCDisp(te) +  pm_dataren(regi,"nur",rlf,te)$(NOT teRLDCDisp(te)) ) * vm_capFac(t,regi,te) * vm_capDistr(t,regi,te,rlf);
  
***-----------------------------------------------------------------------------
*' Definition of competition for geographical potential for renewable energy types:
***-----------------------------------------------------------------------------
*RP* assuming q_limitGeopot to be geographical potential, whith luse equivalent to the land use parameter
q_limitGeopot(t,regi,peReComp(enty),rlf)..
  p_datapot(regi,"limitGeopot",rlf,enty)
  =g=
  sum(te$teReComp2pe(enty,te,rlf), (vm_capDistr(t,regi,te,rlf) / (pm_data(regi,"luse",te)/1000)));

***  learning curve for investment costs
***  deactivate learning for tech_stat 4 technologies before 2025 as they are not built before
q_costTeCapital(t,regi,teLearn)$(NOT (pm_data(regi,"tech_stat",teLearn) eq 4 AND t.val le 2020)) .. 
  vm_costTeCapital(t,regi,teLearn)
  =e=
***  special treatment for first time steps: using global estimates better
***  matches historic values
    ( fm_dataglob("learnMult_wFC",teLearn) 
    * ( ( sum(regi2, vm_capCum(t,regi2,teLearn)) 
          + pm_capCumForeign(t,regi,teLearn)
        )
        ** fm_dataglob("learnExp_wFC",teLearn)
      )
    )$( t.val le 2005 )
***  special treatment for 2010, 2015: start divergence of regional values by using a
***  t-split of global 2005 to regional 2020 in order to phase-in the observed 2020 regional 
***  variation from input-data
  + ( (2020 - t.val)/15 * fm_dataglob("learnMult_wFC",teLearn) 
      * ( sum(regi2, vm_capCum(t,regi2,teLearn)) 
        + pm_capCumForeign(t,regi,teLearn)
        )
        ** fm_dataglob("learnExp_wFC",teLearn)
  	  
    + (t.val - 2005)/15 * pm_data(regi,"learnMult_wFC",teLearn)
      * ( sum(regi2, vm_capCum(t,regi2,teLearn)) 
        + pm_capCumForeign(t,regi,teLearn)
        )
  	  ** pm_data(regi,"learnExp_wFC",teLearn) 
    )$( (t.val gt 2005) AND (t.val lt 2020) )
  
***  assuming linear convergence of regional learning curves to global values until 2050
  + ( (pm_ttot_val(t) - 2020) / 30 * fm_dataglob("learnMult_wFC",teLearn) 
    * ( sum(regi2, vm_capCum(t,regi2,teLearn)) 
      + pm_capCumForeign(t,regi,teLearn)
      )
      ** fm_dataglob("learnExp_wFC",teLearn)
	  
    + (2050 - pm_ttot_val(t)) / 30 * pm_data(regi,"learnMult_wFC",teLearn)
    * ( sum(regi2, vm_capCum(t,regi2,teLearn)) 
      + pm_capCumForeign(t,regi,teLearn)
      )
	  ** pm_data(regi,"learnExp_wFC",teLearn) 
    )$( t.val ge 2020 AND t.val le 2050 )
	
*** globally harmonized costs after 2050
  + ( fm_dataglob("learnMult_wFC",teLearn) 
     * (sum(regi2, vm_capCum(t,regi2,teLearn)) + pm_capCumForeign(t,regi,teLearn) )
       **(fm_dataglob("learnExp_wFC",teLearn))
	)$(t.val gt 2050)
	
***  floor costs - calculated such that they coincide for all regions   
  + pm_data(regi,"floorcost",teLearn)
;


***---------------------------------------------------------------------------
*' EMF27 limits on fluctuating renewables, only turned on for special EMF27 and AWP 2 scenarios, not for SSP
***---------------------------------------------------------------------------
*** this is to prevent that in the long term, all solids are supplied by biomass. Residential solids can be fully supplied by biomass (-> wood pellets), so the FE residential demand is subtracted
q_limitBiotrmod(t,regi)$(t.val > 2020).. 
    vm_prodSe(t,regi,"pebiolc","sesobio","biotrmod") 
   - sum (in$sameAs("fesob",in), vm_cesIO(t,regi,in) + pm_cesdata(t,regi,in,"offset_quantity")) 
   - sum (fe2es(entyFe,esty,teEs)$buildMoBio(esty), vm_demFeForEs(t,regi,entyFe,esty,teEs) )
    =l=
    (2 +  max(0,min(1,( 2100 - pm_ttot_val(t)) / ( 2100 - 2020 ))) * 3) !! 5 in 2020 and 2 in 2100
    * vm_prodSe(t,regi,"pecoal","sesofos","coaltr") 
;

***-----------------------------------------------------------------------------
*' Emissions result from primary to secondary energy transformation,
*' from secondary to final energy transformation (some air pollutants), or
*' transformations within the chain of CCS steps (Leakage).
***-----------------------------------------------------------------------------
q_emiTeDetail(t,regi,enty,enty2,te,enty3)$(emi2te(enty,enty2,te,enty3) OR (pe2se(enty,enty2,te) AND sameas(enty3,"cco2")) ) ..
  vm_emiTeDetail(t,regi,enty,enty2,te,enty3)
  =e=
  sum(emiMkt, vm_emiTeDetailMkt(t,regi,enty,enty2,te,enty3,emiMkt))
;

***--------------------------------------------------
*' Total energy-emissions:
***--------------------------------------------------
*** calculate total energy system emissions for each region and timestep:
q_emiTe(t,regi,emiTe(enty))..
  vm_emiTe(t,regi,enty)
  =e=
  sum(emiMkt, vm_emiTeMkt(t,regi,enty,emiMkt))
;

***-----------------------------------------------------------------------------
*' Emissions per market
*' from primary to secondary energy transformation,
*' from secondary to final energy transformation (some air pollutants), or
*' transformations within the chain of CCS steps (Leakage).
***-----------------------------------------------------------------------------

q_emiTeDetailMkt(t,regi,enty,enty2,te,enty3,emiMkt)$(emi2te(enty,enty2,te,enty3) OR (pe2se(enty,enty2,te) AND sameas(enty3,"cco2")) ) ..
  vm_emiTeDetailMkt(t,regi,enty,enty2,te,enty3,emiMkt)
  =e=
    sum(emi2te(enty,enty2,te,enty3),
      (
	    sum(pe2se(enty,enty2,te),
		  pm_emifac(t,regi,enty,enty2,te,enty3)
		  * vm_demPE(t,regi,enty,enty2,te)
		  )
	    + sum((ccs2Leak(enty,enty2,te,enty3),teCCS2rlf(te,rlf)),
		    pm_emifac(t,regi,enty,enty2,te,enty3)
		    * vm_co2CCS(t,regi,enty,enty2,te,rlf)
		  )
	  )$(sameas(emiMkt,"ETS"))
	  + sum(se2fe(enty,enty2,te),
          pm_emifac(t,regi,enty,enty2,te,enty3)
		  * sum(sector$(entyFe2Sector(enty2,sector) AND sector2emiMkt(sector,emiMkt)), vm_demFeSector(t,regi,enty,enty2,sector,emiMkt))
		)
	)
;

***--------------------------------------------------
*' energy emissions from fuel extraction  
***--------------------------------------------------

q_emiEnFuelEx(t,regi,emiTe(enty))..
  v_emiEnFuelEx(t,regi,enty)
  =e=
***   emissions from non-conventional fuel extraction
	sum(emi2fuelMine(enty,enty2,rlf),      
		  p_cint(regi,enty,enty2,rlf)
		* vm_fuExtr(t,regi,enty2,rlf)
		)$( c_cint_scen eq 1 )
***   emissions from conventional fuel extraction
	+ (sum(pe2rlf(enty3,rlf2),
      sum(enty2$(peFos(enty2)),   
		    (p_cintraw(enty2)
		     * pm_fuExtrOwnCons(regi, enty2, enty3) 
		     * vm_fuExtr(t,regi,enty3,rlf2))$(pm_fuExtrOwnCons(regi, enty2, enty3) gt 0))))$(sameas("co2",enty))
;    
		 


***--------------------------------------------------
*' Total energy-emissions per emission market, region and timestep  
***--------------------------------------------------
q_emiTeMkt(t,regi,emiTe(enty),emiMkt)..
  vm_emiTeMkt(t,regi,enty,emiMkt)
  =e=
***   emissions from fuel combustion
    sum(emi2te(enty2,enty3,te,enty),     
      vm_emiTeDetailMkt(t,regi,enty2,enty3,te,enty,emiMkt)
    )
***   energy emissions fuel extraction
	+ v_emiEnFuelEx(t,regi,enty)$(sameas(emiMkt,"ETS"))
***   Industry CCS emissions
	- ( sum(emiMac2mac(emiInd37_fuel,enty2),
		  vm_emiIndCCS(t,regi,emiInd37_fuel)
		)$( sameas(enty,"co2") )
	)$(sameas(emiMkt,"ETS"))
***   LP, Valve from cco2 capture step, to mangage if capture capacity and CCU/CCS capacity don't have the same lifetime
  + ( v_co2capturevalve(t,regi)$( sameas(enty,"co2") ) )$(sameas(emiMkt,"ETS"))
***  JS CO2 from short-term CCU (short term CCU co2 is emitted again in a time period shorter than 5 years)
  + sum(teCCU2rlf(te2,rlf),
		vm_co2CCUshort(t,regi,"cco2","ccuco2short",te2,rlf)$( sameas(enty,"co2") ) 
	)$(sameas(emiMkt,"ETS"))
;

***--------------------------------------------------
*' Total emissions
***--------------------------------------------------
q_emiAllMkt(t,regi,emi,emiMkt)..
  vm_emiAllMkt(t,regi,emi,emiMkt)
	=e=
	vm_emiTeMkt(t,regi,emi,emiMkt)
*** Non-energy sector emissions. Note: These are emissions from all MAC curves. 
*** So, this includes fugitive emissions, which are sometimes also subsumed under the term energy emissions. 
	+	sum(emiMacSector2emiMac(emiMacSector,emiMac(emi))$macSector2emiMkt(emiMacSector,emiMkt),
   	vm_emiMacSector(t,regi,emiMacSector)
  )
*** CDR from CDR module
	+ vm_emiCdr(t,regi,emi)$(sameas(emi,"co2") AND sameas(emiMkt,"ETS")) 
*** Exogenous emissions
  +	pm_emiExog(t,regi,emi)$(sameas(emiMkt,"other"))
;


***--------------------------------------------------
*' Sectoral energy-emissions used for taxation markup with cm_CO2TaxSectorMarkup
***--------------------------------------------------

*** CO2 emissions from (fossil) fuel combustion in buildings and transport (excl. bunker fuels)
q_emiCO2Sector(t,regi,sector)$(sameAs(sector, "build") OR
                                sameAs(sector, "trans"))..
vm_emiCO2Sector(t,regi,sector)
  =e=
*** calculate direct CO2 emissions per end-use sector
    sum(se2fe(entySe,entyFe,te),
      sum(emiMkt$(sector2emiMkt(sector,emiMkt)),
        pm_emifac(t,regi,entySe,entyFe,te,"co2")
        * vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)
    )
  )
*** substract emissions of bunker fuels for transport sector
  - sum(se2fe(entySe,entyFe,te),
        pm_emifac(t,regi,entySe,entyFe,te,"co2")
        * vm_demFeSector(t,regi,entySe,entyFe,sector,"other")
  )$(sameAs(sector, "trans"))
;

***------------------------------------------------------
*' Mitigation options that are independent of energy consumption are represented
*' using marginal abatement cost (MAC) curves, which describe the
*' percentage of abated emissions as a function of the costs. 
*' Baseline emissions are obtained by three different methods: by source (via emission factors),
*' by econometric estimate, and exogenous. Emissions are calculated as
*' baseline emissions times (1 - relative emission reduction).
*' If coupled to MAgPIE pm_macBaseMagpie contains all N2O landuse emissions including n2o from biomass production
*' and p_efFossilFuelExtr(regi,"pebiolc","n2obio") is zero then. If running standalone 
*' pm_macBaseMagpie does not include n2o from biomass but it is added here.
*' In case of CO2 from landuse (co2luc), emissions can be negative. 
*' To treat these emissions in the same framework, we subtract the minimal emission level from
*' baseline emissions. This shift factor is then added again when calculating total emissions.
*' The endogenous baselines of non-energy emissions are calculated in the following equation:
***------------------------------------------------------
q_macBase(t,regi,enty)$( emiFuEx(enty) OR sameas(enty,"n2ofertin") ) ..
  vm_macBase(t,regi,enty)
  =e=
    sum(emi2fuel(enty2,enty), 
      p_efFossilFuelExtr(regi,enty2,enty) 
    * sum(pe2rlf(enty2,rlf), vm_fuExtr(t,regi,enty2,rlf))
    )$( emiFuEx(enty) )
  + ( pm_macBaseMagpie(t,regi,enty) 
    + p_efFossilFuelExtr(regi,"pebiolc","n2obio") 
    * vm_fuExtr(t,regi,"pebiolc","1")
    )$( sameas(enty,"n2ofertin") )
;

***------------------------------------------------------
*' Total non-energy emissions:
***------------------------------------------------------
q_emiMacSector(t,regi,emiMacSector(enty))..
  vm_emiMacSector(t,regi,enty)
  =e=

    ( vm_macBase(t,regi,enty)
    * sum(emiMac2mac(enty,enty2),
        1 - (pm_macSwitch(enty) * pm_macAbatLev(t,regi,enty2))
      )
    )$( NOT sameas(enty,"co2cement_process") )
***   cement process emissions are accounted for in the industry module
  + ( vm_macBaseInd(t,regi,enty,"cement")
    - vm_emiIndCCS(t,regi,enty)
    )$( sameas(enty,"co2cement_process") )

   + p_macPolCO2luc(t,regi)$( sameas(enty,"co2luc") )
;

q_emiMac(t,regi,emiMac) .. 
  vm_emiMac(t,regi,emiMac)
  =e=
  sum(emiMacSector2emiMac(emiMacSector,emiMac),
    vm_emiMacSector(t,regi,emiMacSector)
  )
;

***--------------------------------------------------
*' All CDR emissions summed up
***--------------------------------------------------
q_emiCdrAll(t,regi)..
  vm_emiCdrAll(t,regi)
       =e= !! BECC + DACC
  (sum(emiBECCS2te(enty,enty2,te,enty3),vm_emiTeDetail(t,regi,enty,enty2,te,enty3))
  + sum(teCCS2rlf(te,rlf), vm_ccs_cdr(t,regi,"cco2","ico2","ccsinje",rlf)))
  !! scaled by the fraction that gets stored geologically
  * (sum(teCCS2rlf(te,rlf),
        vm_co2CCS(t,regi,"cco2","ico2",te,rlf)) /
  (sum(teCCS2rlf(te,rlf),
        vm_co2capture(t,regi,"cco2","ico2","ccsinje",rlf))+sm_eps))
  !! net negative emissions from co2luc
  -  p_macBaseMagpieNegCo2(t,regi)
       !! negative emissions from the cdr module that are not stored geologically
       -       (vm_emiCdr(t,regi,"co2") + sum(teCCS2rlf(te,rlf), vm_ccs_cdr(t,regi,"cco2","ico2","ccsinje",rlf)))
;


***------------------------------------------------------
*' Total regional emissions are the sum of emissions from technologies, MAC-curves, CDR-technologies and emissions that are exogenously given for REMIND.
***------------------------------------------------------
*LB* calculate total emissions for each region at each time step
q_emiAll(t,regi,emi(enty)).. 
  vm_emiAll(t,regi,enty) 
  =e= 
    vm_emiTe(t,regi,enty) 
  + vm_emiMac(t,regi,enty) 
  + vm_emiCdr(t,regi,enty) 
  + pm_emiExog(t,regi,enty)
;

***------------------------------------------------------
*' Total global emissions are calculated for each GHG emission type and links the energy system to the climate module.
***------------------------------------------------------
*LB* calculate total global emissions for each timestep - link to the climate module
q_emiAllGlob(t,emi(enty)).. 
  vm_emiAllGlob(t,enty) 
  =e= 
  sum(regi, 
    vm_emiAll(t,regi,enty) 
  + pm_emissionsForeign(t,regi,enty)
  )
;

***------------------------------------------------------
*' Total regional emissions in CO2 equivalents that are part of the climate policy  are computed based on regional GHG
*' emissions from different sectors(energy system, non-energy system, exogenous, CDR technologies).
***------------------------------------------------------
*mlb 8/2010* extension for multigas accounting/trading 
*cb only "static" equation to be active before cm_startyear, as multigasscen could be different from a scenario to another that is fixed on the first
  q_co2eq(ttot,regi)$(ttot.val ge cm_startyear)..
         vm_co2eq(ttot,regi)
         =e=
         sum(emiMkt, vm_co2eqMkt(ttot,regi,emiMkt));

  q_co2eqMkt(ttot,regi,emiMkt)$(ttot.val ge cm_startyear)..
  vm_co2eqMkt(ttot,regi,emiMkt)
  =e=
  vm_emiAllMkt(ttot,regi,"co2",emiMkt)
  + (sm_tgn_2_pgc   * vm_emiAllMkt(ttot,regi,"n2o",emiMkt) +
     sm_tgch4_2_pgc * vm_emiAllMkt(ttot,regi,"ch4",emiMkt)) $(cm_multigasscen eq 2 or cm_multigasscen eq 3) 
  - vm_emiMacSector(ttot,regi,"co2luc") $((cm_multigasscen eq 3) AND (sameas(emiMkt,"other")));	

***------------------------------------------------------
*' Total global emissions in CO2 equivalents that are part of the climate policy also take into account foreign emissions. 
***------------------------------------------------------
*mlb 20140108* computation of global emissions (related to cap)
  q_co2eqGlob(t) $(t.val > 2010)..
        vm_co2eqGlob(t) =e= sum(regi, vm_co2eq(t,regi) + pm_co2eqForeign(t,regi)); 

***------------------------------------
*' Linking GHG emissions to tradable emission permits.
***------------------------------------
*mh for each region and time step: emissions + permit trade balance < emission cap
q_emiCap(t,regi) ..
                vm_co2eq(t,regi) + vm_Xport(t,regi,"perm") - vm_Mport(t,regi,"perm")
                + vm_banking(t,regi)
                =l= vm_perm(t,regi);

***-----------------------------------------------------------------
*** Budgets on GHG emissions (single or two subsequent time periods)
***-----------------------------------------------------------------

qm_co2eqCum(regi)..
    v_co2eqCum(regi)
    =e=
    sum(ttot$(ttot.val lt sm_endBudgetCO2eq and ttot.val gt s_t_start),
      pm_ts(ttot)
    * vm_co2eq(ttot,regi)
    )
    + sum(ttot$(ttot.val eq sm_endBudgetCO2eq or ttot.val eq s_t_start),
      pm_ts(ttot)
    / 2
    * vm_co2eq(ttot,regi)
    )
;    

q_budgetCO2eqGlob$(cm_emiscen=6)..
   sum(regi, v_co2eqCum(regi))
   =l=
   sum(regi, pm_budgetCO2eq(regi));


***---------------------------------------------------------------------------
*' Definition of carbon capture :
***---------------------------------------------------------------------------
q_balcapture(t,regi,ccs2te(ccsCO2(enty),enty2,te)) ..
  sum(teCCS2rlf(te,rlf),vm_co2capture(t,regi,enty,enty2,te,rlf))
  =e=
    sum(emi2te(enty3,enty4,te2,enty),
      vm_emiTeDetail(t,regi,enty3,enty4,te2,enty)
    )
  + sum(teCCS2rlf(te,rlf),
      vm_ccs_cdr(t,regi,enty,enty2,te,rlf)
    )
***   CCS from industry
  + sum(emiInd37,
      vm_emiIndCCS(t,regi,emiInd37)
    )
;
***--------------------------------------------------------------------------- 
*' Definition of splitting of captured CO2 to CCS, CCU and a valve (the valve 
*' accounts for different lifetimes of capture, CCS and CCU technologies s.t. 
*' extra capture capacities of CO2 capture can release CO2  directly to the 
*' atmosphere)
***---------------------------------------------------------------------------
q_balCCUvsCCS(t,regi) .. 
  sum(teCCS2rlf(te,rlf), vm_co2capture(t,regi,"cco2","ico2",te,rlf))
  =e=
    sum(teCCS2rlf(te,rlf), vm_co2CCS(t,regi,"cco2","ico2",te,rlf))
  + sum(teCCU2rlf(te,rlf), vm_co2CCUshort(t,regi,"cco2","ccuco2short",te,rlf))
  + v_co2capturevalve(t,regi)
;

***---------------------------------------------------------------------------
*' Definition of the CCS transformation chain:
***---------------------------------------------------------------------------
*** no effect while CCS chain is limited to just one step (ccsinje)   
q_transCCS(t,regi,ccs2te(enty,enty2,te),ccs2te2(enty2,enty3,te2),rlf)$teCCS2rlf(te2,rlf)..    
        (1-pm_emifac(t,regi,enty,enty2,te,"co2")) * vm_co2CCS(t,regi,enty,enty2,te,rlf)
        =e=
        vm_co2CCS(t,regi,enty2,enty3,te2,rlf);

q_limitCCS(regi,ccs2te2(enty,"ico2",te),rlf)$teCCS2rlf(te,rlf)..
        sum(ttot $(ttot.val ge 2005), pm_ts(ttot) * vm_co2CCS(ttot,regi,enty,"ico2",te,rlf))
        =l=
        pm_dataccs(regi,"quan",rlf);

***---------------------------------------------------------------------------
*' Emission constraint on SO2 after 2050:
***---------------------------------------------------------------------------
q_limitSo2(ttot+1,regi) $((pm_ttot_val(ttot+1) ge max(cm_startyear,2055)) AND (cm_emiscen gt 1) AND (ord(ttot) lt card(ttot))) ..
         vm_emiTe(ttot+1,regi,"so2")
         =l=
         vm_emiTe(ttot,regi,"so2");

q_limitCO2(ttot+1,regi) $((pm_ttot_val(ttot+1) ge max(cm_startyear,2055)) AND (ttot.val le 2100) AND (cm_emiscen eq 8)) ..
         vm_emiTe(ttot+1,regi,"co2")
         =l=
         vm_emiTe(ttot,regi,"co2");

q_eqadj(regi,ttot,teAdj(te))$(ttot.val ge max(2010, cm_startyear)) ..
         v_adjFactor(ttot,regi,te)
         =e=
         power(
         (sum(te2rlf(te,rlf),vm_deltaCap(ttot,regi,te,rlf)) - sum(te2rlf(te,rlf),vm_deltaCap(ttot-1,regi,te,rlf)))/(pm_ttot_val(ttot)-pm_ttot_val(ttot-1))
         ,2)
                /( sum(te2rlf(te,rlf),vm_deltaCap(ttot-1,regi,te,rlf)) + p_adj_seed_reg(ttot,regi) * p_adj_seed_te(ttot,regi,te)  
                   + p_adj_deltacapoffset("2010",regi,te)$(ttot.val eq 2010) + p_adj_deltacapoffset("2015",regi,te)$(ttot.val eq 2015)
                   + p_adj_deltacapoffset("2020",regi,te)$(ttot.val eq 2020) + p_adj_deltacapoffset("2025",regi,te)$(ttot.val eq 2025)
                  );

***---------------------------------------------------------------------------
*' The use of early retirement is restricted by the following equations:
***---------------------------------------------------------------------------
q_limitCapEarlyReti(ttot,regi,te)$(ttot.val lt 2109 AND pm_ttot_val(ttot+1) ge max(2010, cm_startyear))..
        vm_capEarlyReti(ttot+1,regi,te)
        =g=
        vm_capEarlyReti(ttot,regi,te);

q_smoothphaseoutCapEarlyReti(ttot,regi,te)$(ttot.val lt 2120 AND pm_ttot_val(ttot+1) gt max(2010, cm_startyear))..
        vm_capEarlyReti(ttot+1,regi,te)
        =l=
        vm_capEarlyReti(ttot,regi,te) + (pm_ttot_val(ttot+1)-pm_ttot_val(ttot)) * 
*** Region- and tech-specific max early retirement rates, e.g. more retirement possible for coal power plants in CHA, EUR, REF and USA to account for relatively old fleet or short historical lifespans
        pm_regiEarlyRetiRate(ttot,regi,te) 
    ;



*JK* Result of split of budget equation. Sum of all energy related costs. 
q_costEnergySys(ttot,regi)$( ttot.val ge cm_startyear ) ..
    vm_costEnergySys(ttot,regi)
  =e=
    ( v_costFu(ttot,regi) 
    + v_costOM(ttot,regi) 
    + v_costInv(ttot,regi)
    ) 
  + sum(emiInd37, vm_IndCCSCost(ttot,regi,emiInd37))
  + pm_CementDemandReductionCost(ttot,regi)
;


***---------------------------------------------------------------------------
*' Investment equation for end-use capital investments (energy service layer):
***---------------------------------------------------------------------------
q_esCapInv(ttot,regi,teEs)$(pm_esCapCost(ttot,regi,teEs) AND ttot.val ge cm_startyear) ..
  vm_esCapInv(ttot,regi,teEs)
  =e=
  sum (fe2es(entyFe,esty,teEs)$entyFeTrans(entyFe), !!edge transport
    vm_transpGDPscale(ttot,regi) * pm_esCapCost(ttot,regi,teEs) * vm_prodEs(ttot,regi,entyFe,esty,teEs)
  ) +
  sum (fe2es(entyFe,esty,teEs)$(not(entyFeTrans(entyFe))), 
    pm_esCapCost(ttot,regi,teEs) * vm_prodEs(ttot,regi,entyFe,esty,teEs)
  )
;

*' Limit electricity use for fehes to 1/4th of total electricity use:
q_limitSeel2fehes(t,regi)..
    1/4 * vm_usableSe(t,regi,"seel")
    =g=
    - vm_prodSe(t,regi,"pegeo","sehe","geohe") * pm_prodCouple(regi,"pegeo","sehe","geohe","seel")
;

*' Requires minimum share of liquids from oil in total fossil liquids of 5%:
q_limitShOil(t,regi)..
    sum(pe2se("peoil",enty2,te)$(sameas(te,"refliq") ), 
       vm_prodSe(t,regi,"peoil",enty2,te) 
    ) 
    =g=
    0.05 * 
    sum(se2fe(enty,enty2,te)$(sameas(te,"tdfoshos") OR sameas(te,"tdfospet") OR sameas(te,"tdfosdie") ), 
       vm_demSe(t,regi,enty,enty2,te)
    ) 
;
 
***---------------------------------------------------------------------------
*' PE Historical Capacity:
*** set the bound at 0.9*historic capacities so that the model still needs to build additional capacity beyond the bound in order to fulfill FE demand, otherwise the calibration routine has problems
***---------------------------------------------------------------------------
q_PE_histCap(t,regi,entyPe,entySe)$(p_PE_histCap(t,regi,entyPe,entySe))..
    sum(te$pe2se(entyPe,entySe,te),
      sum(te2rlf(te,rlf), vm_cap(t,regi,te,rlf))
    )
    =g=
    0.9 * p_PE_histCap(t,regi,entyPe,entySe)
;

q_PE_histCap_NGCC_2020_up(t,regi,entyPe,entySe)$( (p_PE_histCap("2015",regi,entyPe,entySe) gt 0.02) AND sameas(entyPe,"pegas") AND sameas(entySe,"seel") AND sameas(t,"2020") )..
    sum(te$pe2se(entyPe,entySe,te),
      sum(te2rlf(te,rlf), vm_cap(t,regi,te,rlf))
    )
    =l=
    1.5 * p_PE_histCap("2015",regi,entyPe,entySe) + 0.01
;


***---------------------------------------------------------------------------
*' Share of green hydrogen in all hydrogen.
***---------------------------------------------------------------------------
q_shGreenH2(t,regi)..
    sum(se2se("seel","seh2",te), vm_prodSe(t,regi,"seel","seh2",te))
    =e=
    (
	sum(pe2se(entyPe,"seh2",te), vm_prodSe(t,regi,entyPe,"seh2",te))
	+ sum(se2se(entySe,"seh2",te), vm_prodSe(t,regi,entySe,"seh2",te))
    ) * v_shGreenH2(t,regi)
;


***---------------------------------------------------------------------------
*' Share of biofuels in transport liquids
***---------------------------------------------------------------------------
q_shBioTrans(t,regi)..
  sum(se2fe(entySe,entyFeTrans,te)$seAgg2se("all_seliq",entySe), vm_prodFe(t,regi,entySe,entyFeTrans,te) )
  * v_shBioTrans(t,regi)
  =e=
  sum(se2fe("seliqbio",entyFeTrans,te), vm_prodFe(t,regi,"seliqbio",entyFeTrans,te) )
;
 
***---------------------------------------------------------------------------
*' Share of final energy carrier in sector
***---------------------------------------------------------------------------

q_shfe(t,regi,entyFe,sector)$(pm_shfe_up(t,regi,entyFe,sector) OR pm_shfe_lo(t,regi,entyFe,sector))..
  v_shfe(t,regi,entyFe,sector) 
  * sum(emiMkt$sector2emiMkt(sector,emiMkt), 
      sum(se2fe(entySe,entyFe2,te)$(entyFe2Sector(entyFe2,sector)),   
        vm_demFeSector(t,regi,entySe,entyFe2,sector,emiMkt)))
  =e=
  sum(emiMkt$sector2emiMkt(sector,emiMkt), 
      sum(se2fe(entySe,entyFe,te),   
        vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt))) 
;

q_shGasLiq_fe(t,regi,sector)$(pm_shGasLiq_fe_up(t,regi,sector) OR pm_shGasLiq_fe_lo(t,regi,sector))..
  v_shGasLiq_fe(t,regi,sector) 
  * sum(emiMkt$sector2emiMkt(sector,emiMkt), 
      sum(se2fe(entySe,entyFe,te)$(entyFe2Sector(entyFe,sector)),   
        vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)))
  =e=
  sum(emiMkt$sector2emiMkt(sector,emiMkt), 
    sum(se2fe(entySe,entyFe,te)$(SAMEAS(entyFe,"fegas") OR SAMEAS(entyFe,"fehos")),
      vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt))) 
;


*limit secondary energy district heating and heat pumps
$IFTHEN.sehe_upper not "%cm_sehe_upper%" == "off" 
q_heat_limit(t,regi)$(t.val gt 2020)..
    vm_prodFe(t,regi,"sehe","fehes","tdhes")
    =l=
    %cm_sehe_upper%*vm_prodFe("2020",regi,"sehe","fehes","tdhes")
;
$ENDIF.sehe_upper


***---------------------------------------------------------------------------
*' H2 t&d capacities in buildings and industry to avoid switching behavior between both sectors
***---------------------------------------------------------------------------

q_capH2BI(t,regi)$(t.val ge max(2015, cm_startyear))..
  vm_cap(t,regi,"tdh2i","1") + vm_cap(t,regi,"tdh2b","1")
  =e=
  vm_cap(t,regi,"tdh2s","1")
;

q_limitCapFeH2BI(t,regi,sector)$(SAMEAS(sector,"build") OR SAMEAS(sector,"indst") AND t.val ge max(2015, cm_startyear))..
    sum(sector2emiMkt(sector,emiMkt), 
      vm_demFeSector(t,regi,"seh2","feh2s",sector,emiMkt))
    =l=
    sum(te2sectortdH2(te,sector),
      sum(teFe2rlfH2BI(te,rlf), 
        vm_capFac(t,regi,te) * vm_cap(t,regi,te,rlf)))
;

***---------------------------------------------------------------------------
*' Enforce historical data biomass share per carrier in sector final energy for buildings and industry (+- 2%)
***---------------------------------------------------------------------------

q_shbiofe_up(t,regi,entyFe,sector,emiMkt)$((sameas(entyFE,"fegas") or sameas(entyFE,"fehos") or sameas(entyFE,"fesos")) and entyFe2Sector(entyFe,sector) and sector2emiMkt(sector,emiMkt) and (t.val le 2015))..
  (pm_secBioShare(t,regi,entyFe,sector) + 0.02)
  *
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt))
  =g=
  sum((entySeBio,te)$se2fe(entySeBio,entyFe,te), vm_demFeSector(t,regi,entySeBio,entyFe,sector,emiMkt))
;

q_shbiofe_lo(t,regi,entyFe,sector,emiMkt)$((sameas(entyFE,"fegas") or sameas(entyFE,"fehos") or sameas(entyFE,"fesos")) and entyFe2Sector(entyFe,sector) and sector2emiMkt(sector,emiMkt) and (t.val le 2015))..
  (pm_secBioShare(t,regi,entyFe,sector) - 0.02)
  *
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt))
  =l=
  sum((entySeBio,te)$se2fe(entySeBio,entyFe,te), vm_demFeSector(t,regi,entySeBio,entyFe,sector,emiMkt))
;

*** EOF ./core/equations.gms
