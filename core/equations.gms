*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
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
    vm_costInvTeDir(t,regi,te) + vm_costInvTeAdj(t,regi,te)$teAdj(te)
  )
  +
*** investment cost of non-conversion technologies (storage, grid etc.)
  sum(teNoTransform,
    vm_costInvTeDir(t,regi,teNoTransform) + vm_costInvTeAdj(t,regi,teNoTransform)$teAdj(teNoTransform)
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
  vm_costInvTeDir(t,regi,te)
  =e=
  vm_costTeCapital(t,regi,te)
  * sum(te2rlf(te,rlf), vm_deltaCap(t,regi,te,rlf))
  * (1 + 0.02/pm_ies(regi) + pm_prtp(regi) ) ** (pm_ts(t) / 2) !! This increases the investments as if the money was actually borrowed
  !! half a time step earlier, using an interest rate of pm_prtp + 2%, which is close to the model-endogenous interest rate.
  !! We do this to reduce the difference to the previous version where the effect of deltacap on capacity was split
  !! half to the current and half to the next time.
;


*RP* 2011-12-01 remove global adjustment costs to decrease runtime, only keep regional adjustment costs. Maybe change in the future.
v_adjFactorGlob.fx(t,regi,te) = 0;

*RP* 2010-05-10 adjustment costs
q_costInvTeAdj(t,regi,teAdj)..
  vm_costInvTeAdj(t,regi,teAdj)
  =e=
  vm_costTeCapital(t,regi,teAdj) * (
    p_adj_coeff(t,regi,teAdj) * v_adjFactor(t,regi,teAdj)
  )
  * (1 + 0.02/pm_ies(regi) + pm_prtp(regi) ) ** (pm_ts(t) / 2) !! This increases the investments as if the money was actually borrowed
  !! half a time step earlier, using an interest rate of pm_prtp + 2%, which is close to the model-endogenous interest rate.
  !! We do this to reduce the difference to the previous version where the effect of deltacap on capacity was split
  !! half to the current and half to the next time.
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
         + vm_prodFe(t,regi,enty,enty2,te)$entyFe(enty2)
         + sum(tePrc2opmoPrc(tePrc(te),opmoPrc),
               vm_outflowPrc(t,regi,te,opmoPrc)
               )
        )
  )
  +
  sum(teNoTransform(te),
     pm_data(regi,"omf",te)
          * sum(te2rlf(te,rlf),
             vm_costTeCapital(t,regi,te) * vm_cap(t,regi,te,rlf)
            )
  )
  + vm_EW_transport_costs(t,regi)
;

***---------------------------------------------------------------------------
*' Energy balance equations equate the production of and demand for each primary, secondary and final energy.
*' The balance equation for primary energy equals supply of primary energy demand on primary energy.
***---------------------------------------------------------------------------
q_balPe(t,regi,entyPe(enty))..
         vm_prodPe(t,regi,enty) + pm_macPE(t,regi,enty)
         =e=
         sum(pe2se(enty,enty2,te), vm_demPe(t,regi,enty,enty2,te))
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
q_balSe(t,regi,enty2)$( entySe(enty2) AND (NOT (sameas(enty2,"seel"))) )..
    sum(pe2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te))
  + sum(se2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te))
  + sum(pc2te(enty,entySe(enty3),te,enty2),
      pm_prodCouple(regi,enty,enty3,te,enty2)
    * vm_prodSe(t,regi,enty,enty3,te)
         )
  + sum(pc2te(enty4,entyFe(enty5),te,enty2),
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
  + sum(prodSeOth2te(enty2,te), v_prodSeOth(t,regi,enty2,te) ) !! *** RLDC removal
  + vm_Mport(t,regi,enty2)
  =e=
    sum(se2fe(enty2,enty3,te), vm_demSe(t,regi,enty2,enty3,te))
  + sum(se2se(enty2,enty3,te), vm_demSe(t,regi,enty2,enty3,te))
  + sum(demSeOth2te(enty2,te), vm_demSeOth(t,regi,enty2,te) ) !! *** RLDC removal
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
      sum(opTimeYr2te(te,opTimeYr)$(tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val ge 1)),
          pm_ts(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1))
        / pm_dataeta(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te)
        * pm_omeg(regi,opTimeYr+1,te)
        * vm_deltaCap(ttot-(pm_tsu2opTimeYr(ttot,opTimeYr)-1),regi,te,rlf)
      )
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
q_balFe(t,regi,entySe,entyFe,te)$se2fe(entySe,entyFe,te)..
  vm_prodFe(t,regi,entySe,entyFe,te)
  =e=
  sum((sector2emiMkt(sector,emiMkt),entyFe2Sector(entyFe,sector)),
    vm_demFeSector(t,regi,entySe,entyFe,sector,emiMkt)
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
    v_prodEs(t,regi,entyFe,esty,teEs);

*' Hand-over to CES:
q_es2ppfen(t,regi,in)$ppfenFromEs(in)..
    vm_cesIO(t,regi,in) + pm_cesdata(t,regi,in,"offset_quantity")
    =e=
    sum(fe2es(entyFe,esty,teEs)$es2ppfen(esty,in), v_prodEs(t,regi,entyFe,esty,teEs))
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
    vm_capFac(t,regi,te) * pm_dataren(regi,"nur",rlf,te) * vm_cap(t,regi,te,rlf)
  )$(NOT teReNoBio(te))
  +
  sum(teRe2rlfDetail(te,rlf),
    pm_dataren(regi,"nur",rlf,te) * vm_capFac(t,regi,te) * v_capDistr(t,regi,te,rlf)
  )$(teReNoBio(te))
;

***----------------------------------------------------------------------------
*' Definition of capacity constraints for secondary energy to secondary energy transformation:
***---------------------------------------------------------------------------
q_limitCapSe2se(t,regi,se2se(enty,enty2,te))..
  vm_prodSe(t,regi,enty,enty2,te)
  =e=
  sum(teSe2rlf(te,rlf),
    vm_capFac(t,regi,te) * pm_dataren(regi,"nur",rlf,te) * vm_cap(t,regi,te,rlf)
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
  (1 - vm_capEarlyReti(ttot,regi,te)) !! early retirement for some technologies
  *
  sum(opTimeYr2te(te,opTimeYr) $ (tsu2opTimeYr(ttot,opTimeYr) AND (opTimeYr.val ge 1)),
      pm_ts(ttot - (pm_tsu2opTimeYr(ttot,opTimeYr) - 1))
    * pm_omeg(regi,opTimeYr+1,te)
    * vm_deltaCap(ttot - (pm_tsu2opTimeYr(ttot,opTimeYr) - 1),regi,te,rlf)
  )
;

q_capDistr(t,regi,teReNoBio(te))..
  sum(teRe2rlfDetail(te,rlf), v_capDistr(t,regi,te,rlf) )
  =e=
  vm_cap(t,regi,te,"1")
;

*** For some capital-intensive and site-specific technologies like geothermal and hydropower,
*** we assume continued maintenance of capacity once it is built: it is not allowed to decrease over time.
q_capNonDecreasing(ttot,regi,teNonDecreasing(te)) $ (ttot.val >= 2030)..
  vm_cap(ttot,regi,te,"1")
  =g=
  vm_cap(ttot-1,regi,te,"1");


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
*** windoffshore-todo
***---------------------------------------------------------------------------
q_windoff_low(t,regi)$(t.val >= 2030)..
   sum(rlf, vm_deltaCap(t,regi,"windoff",rlf))
   =g=
   pm_shareWindOff(t,regi) * pm_shareWindPotentialOff2On(regi) * 0.5 * sum(rlf, vm_deltaCap(t,regi,"windon",rlf))
;


***---------------------------------------------------------------------------
*' Technological change is an important driver of the evolution of energy systems.
*' For mature technologies, such as coal-fired power plants, the evolution
*' of techno-economic parameters is prescribed exogenously. For less mature
*' technologies with substantial potential for cost decreases via learning-by-doing,
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
        pm_ts(ttot+1)* vm_deltaCap(ttot+1,regi,teLearn,rlf))
  +
  vm_capCum(ttot,regi,teLearn);

***---------------------------------------------------------------------------
*' Initial values for cumulated capacities (learning technologies only):
*' (except for tech_stat 4 technologies that have no standing capacities in 2005 and ccap0 refers to another year)
***---------------------------------------------------------------------------
q_capCumNet(t0,regi,teLearn)$(pm_data(regi,"tech_stat",teLearn) < 4)..
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
  sum(pe2rlf(enty,rlf2), vm_fuExtr(t,regi,enty,rlf2))
  - (vm_Xport(t,regi,enty) - (1-pm_costsPEtradeMp(regi,enty)) * vm_Mport(t,regi,enty))$(tradePe(enty))
  - sum(pe2rlf(enty2,rlf2),
      (pm_fuExtrOwnCons(regi, enty, enty2) * vm_fuExtr(t,regi,enty2,rlf2))$(pm_fuExtrOwnCons(regi, enty, enty2) gt 0)
    )
;
***---------------------------------------------------------------------------
*' Definition of resource constraints for renewable energy types:
***---------------------------------------------------------------------------
*ml* assuming maxprod to be technical potential
q_limitProd(t,regi,teRe2rlfDetail(teReNoBio(te),rlf))..
  pm_dataren(regi,"maxprod",rlf,te)
  =g=
  pm_dataren(regi,"nur",rlf,te) * vm_capFac(t,regi,te) * v_capDistr(t,regi,te,rlf);

***-----------------------------------------------------------------------------
*' Definition of competition for geographical potential for renewable energy types:
***-----------------------------------------------------------------------------
*RP* assuming q_limitGeopot to be geographical potential, whith luse equivalent to the land use parameter
q_limitGeopot(t,regi,peReComp(enty),rlf)..
  p_datapot(regi,"limitGeopot",rlf,enty)
  =g=
  sum(te$teReComp2pe(enty,te,rlf), (v_capDistr(t,regi,te,rlf) / (pm_data(regi,"luse",te)/1000)));

*' @equations
***---------------------------------------------------------------------------
*' Learning curve for investment costs:
*' (deactivate learning for tech_stat 4 technologies before 2025 as they are not built before)
***---------------------------------------------------------------------------

*' Learning technologies follow a “one-factor learning curve”[^1] (or “experience curve”).
*' This widely-used formulation derives from empirical observations across different energy
*' technologies of a log-linear relationship between the unit cost $I$ of the technology and its
*' cumulative production or installed capacity $C$ (see for example empirical paper[^2]).
*' [^1]: Edward S. Rubin, Iness M.L. Azevedo, Paulina Jaramillo, and Sonia Yeh. A review of learning rates for electricity supply technologies. Energy Policy, 86:198-218, 2015.
*' [^2]: Alan McDonald and Leo Schrattenholzer. Learning rates for energy technologies. Energy Policy, 29(4):255–261, 2001.

*' Learning rate $\lambda$ is defined as the fractional reduction in cost associated with a doubling of cumulative capacity.
*' Let $I_0$ be the initial cost when cumulative capacity is $C_0$, and $I_d$ be the cost when cumulative capacity is
*' $C_d=2\times C_0$, then the learning rate is defined as:
*' $$ \lambda = 1 - \frac{I_d}{I_0} \in [0,1] $$
*' Hence \textbf{Wright's law} relating investment cost $I$ and cumulative capacity $C$:
*' $$ \frac{I}{I_0} = \left(1-\lambda \right)^{\log_2\left(\frac{C}{C_0}\right)} = \left(\frac{C}{C_0}\right)^{\log_2(1-\lambda )} $$
*' Defining the learning exponent $b = \log_2(1-\lambda)$ and the cost of the first unit $a = \frac{I_0}{C_0^b}$,
*' the learning equation simplifies into:
*' $$ I = a \times C^{b} $$

*' Now suppose there is a floor cost $F$ such that $I\geq F\geq 0$, irrespective of the capacity.
*' Then the learning only applies to learnable costs $I'=I-F$, and the learning equation becomes
*' $$ I = a'\times C^{b'} + F $$ with $a' = \frac{I_0 - F}{C_0^{b'}}$.
*' By design, REMIND learning equations ensure that the initial slope of learning is independent of the floor cost.
*' Mathematically, the slopes are given by the derivative of $I$ and $I'$ with respect to $C$:
*' $$ \frac{dI}{dC} = a \times b \times C^{b-1} = I_0 \times b \times \left(\frac{C}{C_0}\right)^{b-1} $$ 
*' $$ \frac{dI'}{dC} = a' \times b' \times C^{b'-1} = (I_0-F) \times b' \times \left(\frac{C}{C_0}\right)^{b'-1} $$
*' For the two curves to have the same slope initially, we want the two derivatives to be equal for $C=C_0$. 
*' This means $I_0 \times b = (I_0-F) \times b'$, that we rewrite as:
*' $$ b' = \frac{I_0}{I_0-F}b $$

*' In datainput.gms, `fm_dataglob` external data provides the observed learning rate `learn` ($\lambda$),
*' the initial investment costs `inco0` ($I_0$), the floorcost ($F$) and
*' the cumulative capacity in 2015 `ccap0` ($C_0$).
*' The other learning parameters are computed using the equations described above:
*' `learnExp_wFC` ($b'$), `learnMult_wFC` ($a'$).

*' In equations.gms, the investment costs equation `q_costTeCapital` corresponds to $I = a'\times C^{b'} + F$,
*' with variations depending on time period and floor cost scenarios.


$macro macro_capCumGlob (sum(regi2, vm_capCum(t,regi2,teLearn)) + pm_capCumForeign(t,regi,teLearn))
$macro macro_costRegi   (pm_data(regi,"floorcost",teLearn) + pm_data(regi,"learnMult_wFC",teLearn) * macro_capCumGlob ** pm_data(regi,"learnExp_wFC",teLearn))
$macro macro_costGlob   (fm_dataglob("floorcost",teLearn) + fm_dataglob("learnMult_wFC",teLearn) * macro_capCumGlob ** fm_dataglob("learnExp_wFC",teLearn))

q_costTeCapital(t,regi,teLearn) $ (pm_data(regi,"tech_stat",teLearn) < 4 or t.val > 2020) ..
  vm_costTeCapital(t,regi,teLearn)
  =e=
*** until 2005: using global estimates better matches historic values
  macro_costGlob $ (t.val <= 2005)
    
*** 2005 to 2020: linear transition from global 2005 to regional 2020
*** to phase-in the observed 2020 regional variation from input-data
  + macro_interpolate(t.val, 2005, 2020, macro_costGlob, macro_costRegi) $ (t.val > 2005 and t.val <= 2020)

*** after 2020 for specific cm_floorCostScen: regional capital costs
$if %cm_floorCostScen% == "pricestruc"  + macro_costRegi $ (t.val > 2020)
$if %cm_floorCostScen% == "gdpBased"    + macro_costRegi $ (t.val > 2020)

$ifthen.default %cm_floorCostScen% == "uniform"
*** from 2020 to c_teLearnConvStartYr: regional capital costs
  + macro_costRegi $ (t.val > 2020 and t.val <= c_teLearnConvStartYr)

*** c_teLearnConvStartYr to c_teLearnConvEndYr: linear convergence from regional costs to global costs
  + macro_interpolate(t.val, c_teLearnConvStartYr, c_teLearnConvEndYr, macro_costRegi, macro_costGlob) $ (t.val > c_teLearnConvStartYr and t.val < c_teLearnConvEndYr)

*** after c_teLearnConvEndYr: global capital costs
  + macro_costGlob $ (t.val >= c_teLearnConvEndYr)
$endif.default

;
*' @stop

***-----------------------------------------------------------------------------
*' Emissions result from primary to secondary energy transformation,
*' from secondary to final energy transformation (some air pollutants), or
*' transformations within the chain of CCS steps (Leakage).
***---------------------------------------------------------------------------

q_limitCCS(regi,ccs2te(enty,"ico2",te),rlf)$teCCS2rlf(te,rlf)..
        sum(ttot $(ttot.val ge 2005), pm_ts(ttot) * vm_co2CCS(ttot,regi,enty,"ico2",te,rlf))
        =l=
        pm_dataccs(regi,"quan",te);


***---------------------------------------------------------------------------
*' Adjustment costs - calculation of the relative change to last time step
***---------------------------------------------------------------------------

q_eqadj(regi,ttot,teAdj(te))$(ttot.val ge max(2010, cm_startyear)) ..
  v_adjFactor(ttot,regi,te)
  =e=
  power(
    ( sum(te2rlf(te,rlf), vm_deltaCap(ttot,regi,te,rlf)) - sum(te2rlf(te,rlf), vm_deltaCap(ttot-1,regi,te,rlf)) )
    / ( pm_ttot_val(ttot) - pm_ttot_val(ttot-1) )
  , 2)
  / ( sum(te2rlf(te,rlf), vm_deltaCap(ttot-1,regi,te,rlf)) + p_adj_seed_reg(ttot,regi) * p_adj_seed_te(ttot,regi,te)
      + p_adj_deltacapoffset("2010",regi,te)$(ttot.val eq 2010) + p_adj_deltacapoffset("2015",regi,te)$(ttot.val eq 2015)
      + p_adj_deltacapoffset("2020",regi,te)$(ttot.val eq 2020) + p_adj_deltacapoffset("2025",regi,te)$(ttot.val eq 2025)
    )
;

***---------------------------------------------------------------------------
*' Calculate changes to reference in cm_startyear - needed to limit them via refunded adj costs
***---------------------------------------------------------------------------
*' calculating the absolute change of output with respect to the value in reference for each te (counting SE, FE, UE and CCS)
q_changeProdStartyear(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) )..
  v_changeProdStartyear(t,regi,te)
  =e=
  sum(pe2se(enty,enty2,te),   vm_prodSe(t,regi,enty,enty2,te)  - p_prodSeReference(t,regi,enty,enty2,te) )
  + sum(se2se(enty,enty2,te), vm_prodSe(t,regi,enty,enty2,te)  - p_prodSeReference(t,regi,enty,enty2,te) )
  + sum(se2fe(enty,enty2,te), vm_prodFe(t,regi,enty,enty2,te)  - pm_prodFEReference(t,regi,enty,enty2,te) )
  + sum(fe2ue(enty,enty2,te), v_prodUe (t,regi,enty,enty2,te)  - p_prodUeReference(t,regi,enty,enty2,te) )
  + sum(ccs2te(enty,enty2,te), sum(teCCS2rlf(te,rlf), vm_co2CCS(t,regi,enty,enty2,te,rlf) - p_co2CCSReference(t,regi,enty,enty2,te,rlf) ) )
;

*' calculating the relative change
q_relChangeProdStartYear(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) )..
  v_relChangeProdStartYear(t,regi,te) / 100
  *
  (   p_prodAllReference(t,regi,te)
    + p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te)  !! taking into account the region and technology-specific seed values
  )
  =e=
  ( v_changeProdStartyear(t,regi,te) - v_changeProdStartyearSlack(t,regi,te) ) !! always allow some change (depending on .up / .lo of the slack variable)
;

*' calculating the absolute effect size: (relative change)^2 * value in the reference run * construction time (as proxy for "how easy to change on short notice")
q_changeProdStartyearAdj(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) )..
  v_changeProdStartyearAdj(t,regi,te)
  =e=
  power( v_relChangeProdStartYear(t,regi,te) / 100, 2 )  !! taking the square to a) treat increase and decrease the same; b) to penalize larger changes
  * ( p_prodAllReference(t,regi,te) + p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ) !! tie back to the absolute change
  * ( pm_data(regi,"constrTme",te)$(pm_data(regi,"constrTme",te) gt 0) + 2$(pm_data(regi,"constrTme",te) eq 0)) !! take construction time
;

*' calculating the resulting costs (which are applied as a tax in module 21, so they have no budget effect but only influence REMIND choices)
q_changeProdStartyearCost(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) )  ..
  vm_changeProdStartyearCost(t,regi,te)
  =e=
  c_changeProdCost * sm_DpGJ_2_TDpTWa
  * p_adj_coeff(t,regi,te)
  * v_changeProdStartyearAdj(t,regi,te)
;

***---------------------------------------------------------------------------
*' The use of early retirement is restricted by the following equations:
***---------------------------------------------------------------------------
q_limitCapEarlyReti(ttot,regi,te)$(ttot.val le 2100 AND pm_ttot_val(ttot) ge max(2010, cm_startyear)).. !! 2000 doesn't have capacity, so for cm_startyear = 2005 the equation should not be applied
        vm_capEarlyReti(ttot,regi,te)
        =g=
        vm_capEarlyReti(ttot-1,regi,te);

q_smoothphaseoutCapEarlyReti(ttot,regi,te)$(ttot.val le 2100 AND pm_ttot_val(ttot) ge max(2010, cm_startyear)).. !! 2000 doesn't have capacity, so for cm_startyear = 2005 the equation should not be applied
        vm_capEarlyReti(ttot,regi,te)
        =l=
        vm_capEarlyReti(ttot-1,regi,te) +
*** Region- and tech-specific max early retirement rates, e.g. more retirement possible for coal power plants in CHA, EUR, REF and USA to account for relatively old fleet or short historical lifespans
        ( pm_ttot_val(ttot) - pm_ttot_val(ttot-1) ) *
        ( pm_regiEarlyRetiRate(ttot,regi,te) + 0.2$( (ttot.val eq 2010) AND sameas(te,"pc") ) ) !! for some (currently unclear) reason, pc needs some extra flexibility in 2010
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
;


***---------------------------------------------------------------------------
*' Investment equation for end-use capital investments (energy service layer):
***---------------------------------------------------------------------------
q_esCapInv(ttot,regi,teEs)$(pm_esCapCost(ttot,regi,teEs) AND ttot.val ge cm_startyear) ..
  vm_esCapInv(ttot,regi,teEs)
  =e=
  sum (fe2es(entyFe,esty,teEs)$entyFeTrans(entyFe), !!edge transport
    pm_esCapCost(ttot,regi,teEs) * v_prodEs(ttot,regi,entyFe,esty,teEs)
  ) +
  sum (fe2es(entyFe,esty,teEs)$(not(entyFeTrans(entyFe))),
    pm_esCapCost(ttot,regi,teEs) * v_prodEs(ttot,regi,entyFe,esty,teEs)
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
*' Shares of final energy carrier in sector
***---------------------------------------------------------------------------

q_shfe(t,regi,entyFe,sector)$(pm_shfe_up(t,regi,entyFe,sector) OR pm_shfe_lo(t,regi,entyFe,sector))..
  v_shfe(t,regi,entyFe,sector)
  * sum(emiMkt$sector2emiMkt(sector,emiMkt),
      sum(se2fe(entySe,entyFe2,te)$(entyFe2Sector(entyFe2,sector)),
        vm_demFeSector_afterTax(t,regi,entySe,entyFe2,sector,emiMkt)))
  =e=
  sum(emiMkt$sector2emiMkt(sector,emiMkt),
      sum(se2fe(entySe,entyFe,te),
        vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt)))
;

q_shSeFe(t,regi,entySe)$(entySeBio(entySe) OR entySeSyn(entySe) OR entySeFos(entySe)).. !! share of energy carrier subtype in final energy demand of the aggregated carrier type (eg 'the share of bio-based FE liquids in all FE liquids')
  v_shSeFe(t,regi,entySe) 
  * sum((sector,emiMkt)$sector2emiMkt(sector,emiMkt),
      sum(seAgg$seAgg2se(seAgg,entySe), !! determining the aggregate SE carrier type (liquids, gases, ...)
        sum(entySe2$seAgg2se(seAgg,entySe2), !! summing over the bio/fos/syn variants of the chosen SE carrier"
          sum(entyFe$(sefe(entySe2,entyFe) AND entyFe2Sector(entyFe,sector)),
            vm_demFeSector_afterTax(t,regi,entySe2,entyFe,sector,emiMkt)))))
  =e=
  sum((sector,emiMkt)$sector2emiMkt(sector,emiMkt),
    sum(entyFe$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector)),
      vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt)))
;

q_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt)$(
    (sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)) AND
    (entySeBio(entySe) OR entySeSyn(entySe)) AND
    (NOT (sameas(entyFe,"fesos") AND (sameas(sector,"build") OR sameas(sector,"indst")))) !! exclude build/indst solids (not in share penalty; prevents zero-demand infeasibility)
  )..
  v_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt) 
  * sum(entySe2$sefe(entySe2,entyFe),
      vm_demFeSector_afterTax(t,regi,entySe2,entyFe,sector,emiMkt)*(1+999$(sameas(sector,"CDR"))))
  =e=
  vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt)*(1+999$(sameas(sector,"CDR")))
;

q_shGasLiq_fe(t,regi,sector)$(pm_shGasLiq_fe_up(t,regi,sector) OR pm_shGasLiq_fe_lo(t,regi,sector))..
  v_shGasLiq_fe(t,regi,sector)
  * sum(emiMkt$sector2emiMkt(sector,emiMkt),
      sum(se2fe(entySe,entyFe,te)$(entyFe2Sector(entyFe,sector)),
        vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt)))
  =e=
  sum(emiMkt$sector2emiMkt(sector,emiMkt),
    sum(se2fe(entySe,entyFe,te)$(SAMEAS(entyFe,"fegas") OR SAMEAS(entyFe,"fehos")),
      vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt)))
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
*' Enforce historical data biomass share per carrier in sector final energy for transport and buildings (+- 2%)
*' Exempt industry solids as they are covered below
***---------------------------------------------------------------------------

q_shbiofe_up(t,regi,entyFe,sector,emiMkt)$(pm_secBioShare(t,regi,entyFe,sector) and sector2emiMkt(sector,emiMkt) and NOT (sameas(sector,"indst") and sameas(entyFe,"fesos")))..
  (pm_secBioShare(t,regi,entyFe,sector) + 0.02)
  *
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt))
  =g=
  sum((entySeBio,te)$se2fe(entySeBio,entyFe,te), vm_demFeSector_afterTax(t,regi,entySeBio,entyFe,sector,emiMkt))
;

q_shbiofe_lo(t,regi,entyFe,sector,emiMkt)$(pm_secBioShare(t,regi,entyFe,sector) and sector2emiMkt(sector,emiMkt) and NOT (sameas(sector,"indst") and sameas(entyFe,"fesos")))..
  (pm_secBioShare(t,regi,entyFe,sector) - 0.02)
  *
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt))
  =l=
  sum((entySeBio,te)$se2fe(entySeBio,entyFe,te), vm_demFeSector_afterTax(t,regi,entySeBio,entyFe,sector,emiMkt))
;

***---------------------------------------------------------------------------
*' Enforce historical data biomass share per carrier in sector final energy for industry (+- 2%)
*' Applies to the sum of emiMkt
***---------------------------------------------------------------------------

q_shbiofe_indst_up(t,regi,entyFe,sector)$(pm_secBioShare(t,regi,entyFe,sector) and (sameas(sector,"indst") and sameas(entyFe,"fesos")))..
  (pm_secBioShare(t,regi,entyFe,sector) + 0.02)
  *
  sum(emiMkt$sector2emiMkt(sector,emiMkt),
    sum((entySe,te)$se2fe(entySe,entyFe,te),
      vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt)))
  =g=
  sum(emiMkt$sector2emiMkt(sector,emiMkt),
    sum((entySeBio,te)$se2fe(entySeBio,entyFe,te),
      vm_demFeSector_afterTax(t,regi,entySeBio,entyFe,sector,emiMkt)))
;

q_shbiofe_indst_lo(t,regi,entyFe,sector)$(pm_secBioShare(t,regi,entyFe,sector) and (sameas(sector,"indst") and sameas(entyFe,"fesos")))..
  (pm_secBioShare(t,regi,entyFe,sector) - 0.02)
  *
  sum(emiMkt$sector2emiMkt(sector,emiMkt),
    sum((entySe,te)$se2fe(entySe,entyFe,te),
      vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt)))
  =l=
  sum(emiMkt$sector2emiMkt(sector,emiMkt),
    sum((entySeBio,te)$se2fe(entySeBio,entyFe,te),
      vm_demFeSector_afterTax(t,regi,entySeBio,entyFe,sector,emiMkt)))
;

***---------------------------------------------------------------------------
*' Penalty for secondary energy share deviation in sectors 
***---------------------------------------------------------------------------

$ifthen.seFeSectorShareDev "%cm_seFeSectorShareDevMethod%" == "sqSectorShare"
q_penSeFeSectorShareDev(t,regi,entySe,entyFe,sector,emiMkt)$(
    (t.val ge 2025) AND  !!disable share incentives for historical years in buildings, industry and CDR as this should be handled by historical bounds   
    ( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ) AND !!only create the equation for valid cobinations of entySe, entyFe, sector and emiMkt
    ( (entySeBio(entySe) OR entySeSyn(entySe)) ) AND !!share incentives only need to be applied to n-1 secondary energy carriers
    ( NOT(sameas(sector,"build") AND (sameas(entyFe,"fesos"))) ) AND !!disable buildings solids share incentives
    ( NOT(sameas(sector,"indst") AND (sameas(entyFe,"fesos"))) ) !!disable industry solids share incentives
  )..
  v_penSeFeSectorShare(t,regi,entySe,entyFe,sector,emiMkt)
  =e=
  power(v_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt) ,2)
  * (1$sameas("%c_seFeSectorShareDevUnit%","share") + ( vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt) )$(sameas("%c_seFeSectorShareDevUnit%","energy")) ) !!define deviation in share or energy units 
;
$elseIf.seFeSectorShareDev "%cm_seFeSectorShareDevMethod%" == "sqSectorAvrgShare"
q_penSeFeSectorShareDev(t,regi,entySe,entyFe,sector,emiMkt)$(
    (t.val ge 2025) AND  !!disable share incentives for historical years in buildings, industry and CDR as this should be handled by historical bounds
    ( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ) AND !!only create the equation for valid cobinations of entySe, entyFe, sector and emiMkt
    ( (entySeBio(entySe) OR entySeSyn(entySe)) ) AND !!share incentives only need to be applied to n-1 secondary energy carriers
    ( NOT(sameas(sector,"build") AND (sameas(entyFe,"fesos"))) ) AND !!disable buildings solids share incentives
    ( NOT(sameas(sector,"indst") AND (sameas(entyFe,"fesos"))) ) !!disable industry solids share incentives
  )..
  v_penSeFeSectorShare(t,regi,entySe,entyFe,sector,emiMkt)
  =e=
  power(v_shSeFe(t,regi,entySe) - v_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt) ,2)
  * (1$sameas("%c_seFeSectorShareDevUnit%","share") + ( vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt) )$(sameas("%c_seFeSectorShareDevUnit%","energy")) ) !!define deviation in share or energy units 
;
$elseIf.seFeSectorShareDev "%cm_seFeSectorShareDevMethod%" == "minMaxAvrgShare"
q_penSeFeSectorShareDev(t,regi,entySe,entyFe,sector,emiMkt)$(
    (t.val ge 2025) AND  !!disable share incentives for historical years in buildings, industry and CDR as this should be handled by historical bounds
    ( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ) AND !!only create the equation for valid cobinations of entySe, entyFe, sector and emiMkt
    ( (entySeBio(entySe) OR entySeSyn(entySe)) ) AND !!share incentives only need to be applied to n-1 secondary energy carriers
    ( NOT(sameas(sector,"build") AND (sameas(entyFe,"fesos"))) ) AND !!disable buildings solids share incentives
    ( NOT(sameas(sector,"indst") AND (sameas(entyFe,"fesos"))) ) !!disable industry solids share incentives
  )..
  v_penSeFeSectorShare(t,regi,entySe,entyFe,sector,emiMkt)
  =e=
    v_NegPenSeFeSectorShare(t,regi,entySe,entyFe,sector,emiMkt) 
  + v_PosPenSeFeSectorShare(t,regi,entySe,entyFe,sector,emiMkt)
;

q_minMaxPenSeFeSectorShareDev(t,regi,entySe,entyFe,sector,emiMkt)$(
    (t.val ge 2025) AND  !!disable share incentives for historical years in buildings, industry and CDR as this should be handled by historical bounds
    ( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ) AND !!only create the equation for valid cobinations of entySe, entyFe, sector and emiMkt
    ( (entySeBio(entySe) OR entySeSyn(entySe)) ) AND !!share incentives only need to be applied to n-1 secondary energy carriers
    ( NOT(sameas(sector,"build") AND (sameas(entyFe,"fesos"))) ) AND !!disable buildings solids share incentives
    ( NOT(sameas(sector,"indst") AND (sameas(entyFe,"fesos"))) ) !!disable industry solids share incentives
  )..
  (
    v_shSeFe(t,regi,entySe)
    - v_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt)
    + v_NegPenSeFeSectorShare(t,regi,entySe,entyFe,sector,emiMkt) 
    - v_PosPenSeFeSectorShare(t,regi,entySe,entyFe,sector,emiMkt)
  )
  * !!define deviation in share or energy units 
    ( 1$sameas("%c_seFeSectorShareDevUnit%","share") +
      (sum(seAgg$seAgg2se(seAgg,entySe),
        sum(entyFe2$(seAgg2fe(seAgg,entyFe2) AND entyFe2Sector(entyFe2,sector)),
          sum(entySe2$(seAgg2se(seAgg,entySe2) AND sefe(entySe2,entyFe2) AND entyFe2Sector(entyFe2,sector)),
              vm_demFeSector_afterTax(t,regi,entySe2,entyFe2,sector,emiMkt))))
      )$sameas("%c_seFeSectorShareDevUnit%","energy")
    ) 
  =e=
  0
;
$endif.seFeSectorShareDev

$ifthen.penSeFeSectorShareDevCost not "%cm_seFeSectorShareDevMethod%" == "off"
q_penSeFeSectorShareDevCost(t,regi)..
  vm_penSeFeSectorShareDevCost(t,regi)
  =e=
  sum((entySe,entyFe,sector,emiMkt)$( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ),
    v_penSeFeSectorShare(t,regi,entySe,entyFe,sector,emiMkt)
  ) * c_seFeSectorShareDevScale
;
$endif.penSeFeSectorShareDevCost

***---------------------------------------------------------------------------
*' Limit solids fossil to be lower or equal to previous year values  
***---------------------------------------------------------------------------
$ifthen.limitSolidsFossilRegi not %cm_limitSolidsFossilRegi% == "off"
q_fossilSolidsLimitReg(ttot,regi,entySe,entyFe,sector,emiMkt)$(limitSolidsFossilRegi(regi) and (ttot.val ge max(2020, cm_startyear)) AND sefe(entySe,entyFe) AND sector2emiMkt(sector,emiMkt) AND (sameas(sector,"indst") OR sameas(sector,"build")) AND sameas(entySe,"sesofos"))..
  vm_demFeSector_afterTax(ttot,regi,entySe,entyFe,sector,emiMkt)
  =l=
  vm_demFeSector_afterTax(ttot-1,regi,entySe,entyFe,sector,emiMkt);
$endif.limitSolidsFossilRegi

*** EOF ./core/equations.gms
q_co2eq(ttot,regi)$(0)..
  0 =e= 0;
