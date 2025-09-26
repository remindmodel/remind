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
    * ( v_macBase(t,regi,"ch4wstl")
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

q_costTeCapital(t,regi,teLearn)$(NOT (pm_data(regi,"tech_stat",teLearn) eq 4 AND t.val le 2020)) ..
  vm_costTeCapital(t,regi,teLearn)
  =e=
*** until 2005: using global estimates better matches historic values
  + ( fm_dataglob("floorcost",teLearn)
      + ( fm_dataglob("learnMult_wFC",teLearn)
          * ( sum(regi2, vm_capCum(t,regi2,teLearn))
              + pm_capCumForeign(t,regi,teLearn)
          ) ** fm_dataglob("learnExp_wFC",teLearn)
      )
  )$( t.val le 2005 )
    
*** 2005 to 2020: linear transition from global 2005 to regional 2020
*** to phase-in the observed 2020 regional variation from input-data
  + ( (2020 - t.val) / (2020-2005)
      * ( fm_dataglob("floorcost",teLearn)
          + fm_dataglob("learnMult_wFC",teLearn)
            * ( sum(regi2, vm_capCum(t,regi2,teLearn))
                + pm_capCumForeign(t,regi,teLearn)
              ) ** fm_dataglob("learnExp_wFC",teLearn)
      )

    + (t.val - 2005) / (2020-2005) 
      * ( pm_data(regi,"floorcost",teLearn) 
          + pm_data(regi,"learnMult_wFC",teLearn)
            * ( sum(regi2, vm_capCum(t,regi2,teLearn))
                + pm_capCumForeign(t,regi,teLearn)
              ) ** pm_data(regi,"learnExp_wFC",teLearn)
      )
  )$( (t.val gt 2005) AND (t.val le 2020) )

$ifthen.floorscen %cm_floorCostScen% == "default"
*** from 2020 to c_LearnTeConvStartYear: use regional values
  + ( pm_data(regi,"floorcost",teLearn) 
        + pm_data(regi,"learnMult_wFC",teLearn)
          * ( sum(regi2, vm_capCum(t,regi2,teLearn))
              + pm_capCumForeign(t,regi,teLearn)
            ) ** pm_data(regi,"learnExp_wFC",teLearn)
  )$( (t.val gt 2020) AND (t.val lt c_LearnTeConvStartYear) )

*** c_LearnTeConvStartYear to c_LearnTeConvEndYear: assuming linear convergence of regional learning curves to global values
  + ( (pm_ttot_val(t) - c_LearnTeConvStartYear) / (c_LearnTeConvEndYear-c_LearnTeConvStartYear)  
      * ( fm_dataglob("floorcost",teLearn) 
          + fm_dataglob("learnMult_wFC",teLearn)
            * ( sum(regi2, vm_capCum(t,regi2,teLearn))
                + pm_capCumForeign(t,regi,teLearn)
              ) ** fm_dataglob("learnExp_wFC",teLearn)
      )

    + (c_LearnTeConvEndYear - pm_ttot_val(t)) / (c_LearnTeConvEndYear-c_LearnTeConvStartYear)  
      * ( pm_data(regi,"floorcost",teLearn) 
          + pm_data(regi,"learnMult_wFC",teLearn)
            * ( sum(regi2, vm_capCum(t,regi2,teLearn))
                + pm_capCumForeign(t,regi,teLearn)
              ) ** pm_data(regi,"learnExp_wFC",teLearn)
      )
  )$( t.val ge c_LearnTeConvStartYear AND t.val le c_LearnTeConvEndYear )
$endif.floorscen

$ifthen.floorscen %cm_floorCostScen% == "pricestruc"
  + ( pm_data(regi,"floorcost",teLearn) 
      + pm_data(regi,"learnMult_wFC",teLearn)
        * ( sum(regi2, vm_capCum(t,regi2,teLearn))
            + pm_capCumForeign(t,regi,teLearn)
          ) ** pm_data(regi,"learnExp_wFC",teLearn)
    )$( t.val ge 2020 AND t.val le 2100 )
$endif.floorscen

$ifthen.floorscen %cm_floorCostScen% == "techtrans"
  + ( pm_data(regi,"floorcost",teLearn) 
      + pm_data(regi,"learnMult_wFC",teLearn)
        * ( sum(regi2, vm_capCum(t,regi2,teLearn))
            + pm_capCumForeign(t,regi,teLearn)
          ) ** pm_data(regi,"learnExp_wFC",teLearn)
    )$( t.val ge 2020 AND t.val le 2100 )
$endif.floorscen

$ifthen.floorscen %cm_floorCostScen% == "default"
*** after c_LearnTeConvEndYear: globally harmonized costs
  + ( fm_dataglob("floorcost",teLearn) 
      + fm_dataglob("learnMult_wFC",teLearn)
        * ( sum(regi2, vm_capCum(t,regi2,teLearn)) 
            + pm_capCumForeign(t,regi,teLearn) 
            ) **(fm_dataglob("learnExp_wFC",teLearn))
  )$(t.val gt c_LearnTeConvEndYear)
$endif.floorscen
;
*' @stop

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
q_emiTeDetailMkt(t,regi,enty,enty2,te,enty3,emiMkt)$(
                           emi2te(enty,enty2,te,enty3)
                        OR (pe2se(enty,enty2,te) AND sameas(enty3,"cco2")) ) ..
  vm_emiTeDetailMkt(t,regi,enty,enty2,te,enty3,emiMkt)
  =e=
  sum(emi2te(enty,enty2,te,enty3),
    ( sum(pe2se(enty,enty2,te),
        pm_emifac(t,regi,enty,enty2,te,enty3)
      * vm_demPe(t,regi,enty,enty2,te)
      )
    + sum((ccs2Leak(enty,enty2,te,enty3),teCCS2rlf(te,rlf)),
        pm_emifac(t,regi,enty,enty2,te,enty3)
      * vm_co2CCS(t,regi,enty,enty2,te,rlf)
      )
    )$( sameas(emiMkt,"ETS") )
  + sum(se2fe(enty,enty2,te),
      pm_emifac(t,regi,enty,enty2,te,enty3)
    * sum(sector$(    entyFe2Sector(enty2,sector)
                  AND sector2emiMkt(sector,emiMkt) ),
        vm_demFeSector(t,regi,enty,enty2,sector,emiMkt)
        !! substract FE used for non-energy purposes (as feedstocks) so it does
        !! not create energy-related emissions
      - sum(entyFE2sector2emiMkt_NonEn(enty2,sector,emiMkt),
          vm_demFeNonEnergySector(t,regi,enty,enty2,sector,emiMkt))
      )
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
		    (pm_cintraw(enty2)
		     * pm_fuExtrOwnCons(regi, enty2, enty3)
		     * vm_fuExtr(t,regi,enty3,rlf2))$(pm_fuExtrOwnCons(regi, enty2, enty3) gt 0))))$(sameas("co2",enty))
;



***--------------------------------------------------
*' Total energy-emissions per emission market, region and timestep
***--------------------------------------------------
q_emiTeMkt(t,regi,emiTe(enty),emiMkt) ..
  vm_emiTeMkt(t,regi,enty,emiMkt)
  =e=
    !! emissions from fuel combustion
    sum(emi2te(enty2,enty3,te,enty),
      vm_emiTeDetailMkt(t,regi,enty2,enty3,te,enty,emiMkt)
    )
    !! energy emissions fuel extraction
  + v_emiEnFuelEx(t,regi,enty)$( sameas(emiMkt,"ETS") )
    !! CO2 captured from Industry sector energy consumption
    !! Needs to be subtracted as vm_emiTeDetailMkt assumes all fuel 
    !! is burned without capture (same for CDR sector, plastics, feedstocks)
  - sum(emiInd37_fuel,
      vm_emiIndCCS(t,regi,emiInd37_fuel)
    )$( sameas(enty,"co2") AND sameas(emiMkt,"ETS") )
    !! CO2 captured from CDR sector energy consumption (OAE and DAC)
  - sm_capture_rate_cdrmodule
  * sum(te_ccs33,
      vm_co2emi_cdrFE_beforeCapture(t, regi, te_ccs33)
  )$( sameas(enty,"co2") AND sameas(emiMkt,"ETS") )
    !! plastic waste incineration; net from positive (fossil non-ccs) and negative (bio/syn w/ CCS)
  + vm_wasteIncinerationEmiBalance(t,regi,enty,emiMkt)
    !! Valve from cco2 capture step, to mangage if capture capacity and CCU/CCS
    !! capacity don't have the same lifetime
  + v_co2capturevalve(t,regi)$( sameas(enty,"co2") AND sameas(emiMkt,"ETS") )
    !! CO2 from short-term CCU (short term CCU co2 is emitted again in a time
    !! period shorter than 5 years)
  + sum(teCCU2rlf(te2,rlf),
      vm_co2CCUshort(t,regi,"cco2","ccuco2short",te2,rlf)
    )$( sameas(enty,"co2") AND sameas(emiMkt,"ETS") )
;

***--------------------------------------------------
*' Total emissions
***--------------------------------------------------
q_emiAllMkt(t,regi,emi,emiMkt) ..
  vm_emiAllMkt(t,regi,emi,emiMkt)
  =e=
    vm_emiTeMkt(t,regi,emi,emiMkt)
    !! Non-energy sector emissions. Note: These are emissions from all MAC
    !! curves.  So, this includes fugitive emissions, which are sometimes also
    !! subsumed under the term energy emissions.
  + sum((emiMacSector2emiMac(emiMacSector,emiMac(emi)),
         macSector2emiMkt(emiMacSector,emiMkt)),
      vm_emiMacSector(t,regi,emiMacSector)
    )
    !! negative emissions from CDR module before re-release from CCU
  + vm_emiCdr(t,regi,emi)$( sameas(emi,"co2") AND sameas(emiMkt,"ETS") )
    !! Exogenous emissions
  + pm_emiExog(t,regi,emi)$( sameas(emiMkt,"other") )
    !! emissions of carbon feedstocks contained in chemicals that are not energy-related,
    !! can be positive (fossil, emitted) or negative (non-fossil, stored in products)
  + vm_emiFeedstockNoEnergy(t,regi,emi,emiMkt)
;


***--------------------------------------------------
*' Sectoral energy-emissions used for taxation markup with cm_CO2TaxSectorMarkup
***--------------------------------------------------

*** CO2 emissions from (fossil) fuel combustion in buildings and transport (excl. bunker fuels)
q_emiCO2Sector(t,regi,sector) $ (   sameAs(sector, "build")
                                 OR sameAs(sector, "trans"))..
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
  v_macBase(t,regi,enty)
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

    ( v_macBase(t,regi,enty)
    * sum(emiMac2mac(enty,enty2),
        1 - (pm_macSwitch(t,regi,enty) * pm_macAbatLev(t,regi,enty2))
      )
    )$( NOT sameas(enty,"co2cement_process") )
***   cement process emissions are accounted for in the industry module
  + ( vm_emiIndBase(t,regi,enty,"cement")
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
  vm_emiCdrAll(t,regi) !! positive value
  =e=
  !! ---- net LUC CDR
  !! net negative emissions from co2luc
  - p_macBaseMagpieNegCo2(t,regi) !! negative value
  
  !! ---- gross non-industry CDR
  !! 1. directly geologically stored gross atmospheric removal from pe2se-BECCS + DACCS
  + ( !! pe2se-BECC 
      sum(emiBECCS2te(enty,enty2,te,enty3),vm_emiTeDetail(t,regi,enty,enty2,te,enty3)) !! positive value
        !! + gross DACC 
      - sum(teCCS2rlf(te,rlf), vm_emiCdrTeDetail(t, regi, "dac"))) !! negative value
      !! scaled by the fraction that gets stored geologically
     *  v_ccsShare(t,regi) 
  !! 2. gross CDR from Enhanced Weathering
  - vm_emiCdrTeDetail(t, regi, "weathering") !! negative value
  !! 3. gross ocean uptake from OAE (also excluding non-avoidable emi from calcination)
  - vm_emiCdrTeDetail(t, regi, "oae_ng")  !! negative value
  - vm_emiCdrTeDetail(t, regi, "oae_el")  !! negative value
  !! 4. energy-related CDR from CDR sector (from burning biogenic or synfuel + capture + storage)
  +  pm_emifac(t,regi,"segafos","fegas","tdfosgas","co2") * sm_capture_rate_cdrmodule
      * (vm_demFeSector_afterTax(t,regi,"segabio","fegas","cdr","ETS") !! FE biogas
          + vm_demFeSector_afterTax(t,regi,"segasyn","fegas","cdr","ETS")) !! FE syngas
      !! multiply with ccs share 
      * v_ccsShare(t,regi) 
  !! 5. biochar CDR 
  -  sum(emiBiochar2te(enty,enty2,te,enty3),vm_emiTeDetail(t,regi,enty,enty2,te,enty3)) !! negative value

  !! ---- gross industry CDR
  !! 1. gross industry CCS-CDR  (from burning biogenic or synfuel + capturing + storing the co2)
  + sum(emiInd37$(not sameas(emiInd37,"co2cement_process")), 
      vm_emiIndCCS(t,regi,emiInd37) !! positive value
    !! multiply with bio/syn share from previous iteration (computationally too expensive to incl. in optimization)
    * pm_NonFos_IndCC_fraction0(t,regi, emiInd37))
    !! multiply with ccs share 
    * v_ccsShare(t,regi) 
  !! 2. Feedstocks
  !! 2a) plastics CDR -- incinerated  waste that is captured + stored from  non-fossil feedstocks
  + sum(emiMkt, 
      vm_nonFosPlastic_incinCC(t,regi,emiMkt)  * v_ccsShare(t,regi)) !! positive value
  !! 2b) plastics CDR -- landfilled waste from non-fossil feedstocks
  - sum((emi,emiMkt), 
      vm_emiNonFosNonIncineratedPlastics(t,regi,emi,emiMkt)) !! negative value
  !! 2c) non-plastics materials CDR -- bound carbon from non-fossil feedstocks 
  + vm_nonFosNonPlasticNonEmitted(t,regi) !! positive value
;


***------------------------------------------------------
*' Total regional emissions are computed as the sum of total emissions over all emission markets.
***------------------------------------------------------
q_emiAll(t,regi,emi)..
  vm_emiAll(t,regi,emi)
  =e=
  sum(emiMkt, vm_emiAllMkt(t,regi,emi,emiMkt))
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
q_balcapture(t,regi,ccs2te(ccsCo2(enty),enty2,te)) ..
  sum(teCCS2rlf(te,rlf), v_co2capture(t,regi,enty,enty2,te,rlf))
  =e=
    !! carbon captured in energy sector
    sum(emi2te(enty3,enty4,te2,enty),
      vm_emiTeDetail(t,regi,enty3,enty4,te2,enty)
    )
    !! carbon captured from CDR technologies in CDR module
  + sum(teCCS2rlf(te,rlf), vm_co2capture_cdr(t,regi,enty,enty2,te,rlf))
    !! carbon captured from industry
  + sum(emiInd37, vm_emiIndCCS(t,regi,emiInd37))
  + sum((sefe(entySe,entyFe),emiMkt)$(
                            entyFE2sector2emiMkt_NonEn(entyFe,"indst",emiMkt) ),
      vm_incinerationCCS(t,regi,entySe,entyFe,emiMkt)
    )
;

***---------------------------------------------------------------------------
*' Definition of splitting of captured CO2 to CCS, CCU and a valve (the valve
*' accounts for different lifetimes of capture, CCS and CCU technologies s.t.
*' extra capture capacities of CO2 capture can release CO2  directly to the
*' atmosphere)
***---------------------------------------------------------------------------
q_balCCUvsCCS(t,regi) ..
  sum(teCCS2rlf(te,rlf), v_co2capture(t,regi,"cco2","ico2",te,rlf))
  =e=
    sum(teCCS2rlf(te,rlf), vm_co2CCS(t,regi,"cco2","ico2",te,rlf))
  + sum(teCCU2rlf(te,rlf), vm_co2CCUshort(t,regi,"cco2","ccuco2short",te,rlf))
  + v_co2capturevalve(t,regi)
;

q_ccsShare(t,regi) ..
  sum(teCCS2rlf(te, rlf), v_co2capture(t, regi, "cco2", "ico2", "ccsinje", rlf))  * 
  v_ccsShare(t,regi) 
  =e=
  sum(teCCS2rlf(te, rlf), vm_co2CCS(t, regi, "cco2", "ico2", te, rlf))
;

***---------------------------------------------------------------------------
*' Definition of the CCS transformation chain:
***---------------------------------------------------------------------------

q_limitCCS(regi,ccs2te2(enty,"ico2",te),rlf)$teCCS2rlf(te,rlf)..
        sum(ttot $(ttot.val ge 2005), pm_ts(ttot) * vm_co2CCS(ttot,regi,enty,"ico2",te,rlf))
        =l=
        pm_dataccs(regi,"quan",rlf);


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

q_shSeFeSector(t,regi,entySe,entyFe,sector,emiMkt)$((entySeBio(entySe) OR entySeSyn(entySe) OR entySeFos(entySe)) AND (sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)))..
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
*' Enforce historical data biomass share per carrier in sector final energy for transport, buildings and industry (+- 2%)
***---------------------------------------------------------------------------

q_shbiofe_up(t,regi,entyFe,sector,emiMkt)$(pm_secBioShare(t,regi,entyFe,sector) and sector2emiMkt(sector,emiMkt))..
  (pm_secBioShare(t,regi,entyFe,sector) + 0.02)
  *
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt))
  =g=
  sum((entySeBio,te)$se2fe(entySeBio,entyFe,te), vm_demFeSector_afterTax(t,regi,entySeBio,entyFe,sector,emiMkt))
;

q_shbiofe_lo(t,regi,entyFe,sector,emiMkt)$(pm_secBioShare(t,regi,entyFe,sector) and sector2emiMkt(sector,emiMkt))..
  (pm_secBioShare(t,regi,entyFe,sector) - 0.02)
  *
  sum((entySe,te)$se2fe(entySe,entyFe,te), vm_demFeSector_afterTax(t,regi,entySe,entyFe,sector,emiMkt))
  =l=
  sum((entySeBio,te)$se2fe(entySeBio,entyFe,te), vm_demFeSector_afterTax(t,regi,entySeBio,entyFe,sector,emiMkt))
;

***---------------------------------------------------------------------------
*' Penalty for secondary energy share deviation in sectors 
***---------------------------------------------------------------------------

$ifthen.seFeSectorShareDev "%cm_seFeSectorShareDevMethod%" == "sqSectorShare"
q_penSeFeSectorShareDev(t,regi,entySe,entyFe,sector,emiMkt)$(
    (t.val ge 2025) AND  !!disable share incentives for historical years in buildings, industry and CDR as this should be handled by historical bounds   
    ( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ) AND !!only create the equation for valid cobinations of entySe, entyFe, sector and emiMkt
    ( (entySeBio(entySe) OR entySeSyn(entySe)) ) AND !!share incentives only need to be applied to n-1 secondary energy carriers
    ( NOT(sameas(sector,"build") AND (sameas(entyFE,"fesos"))) ) !!disable buildings solids share incentives
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
    ( NOT(sameas(sector,"build") AND (sameas(entyFE,"fesos"))) ) !!disable buildings solids share incentives
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
    ( NOT(sameas(sector,"build") AND (sameas(entyFE,"fesos"))) ) !!disable buildings solids share incentives
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
    ( NOT(sameas(sector,"build") AND (sameas(entyFE,"fesos"))) ) !!disable buildings solids share incentives
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
