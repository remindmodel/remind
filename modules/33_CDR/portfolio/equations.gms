*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/equations.gms


***---------------------------------------------------------------------------
*** Equations concerning two or more options

***---------------------------------------------------------------------------
*'  CDR Final Energy Balance
***---------------------------------------------------------------------------
q33_demFeCDR(t,regi,entyFe)$(entyFe2Sector(entyFe,"cdr"))..
    sum(fe2cdr(entyFe,entyFe2,te_used33),
          v33_FEdemand(t,regi,entyFe,entyFe2,te_used33)
    )
      =e=
      sum((entySe,te)$se2fe(entySe,entyFe,te),
        vm_demFeSector_afterTax(t,regi,entySe,entyFe,"cdr","ETS")
    )
    ;

***---------------------------------------------------------------------------
*'  Sum of all CDR emissions other than BECCS and afforestation, which are calculated in the core.
***---------------------------------------------------------------------------
q33_emiCDR(t,regi)..
    vm_emiCdr(t,regi,"co2")
    =e=
    sum(te_used33, v33_emi(t,regi,te_used33))
    ;

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from capacity.
*'  Negative emissions from enhanced weathering also result from decaying rock
*'  spread in previous timesteps, so emissions do not equal to the capacity
*'  (i.e., how much rock is spread in a given timestep).
***---------------------------------------------------------------------------
q33_capconst(t,regi,te_used33)$(not sameAs(te_used33, "weathering"))..
    v33_emi(t,regi,te_used33)
    =e=
    - sum(teNoTransform2rlf33(te_used33,rlf),
        vm_capFac(t,regi,te_used33) * vm_cap(t,regi,te_used33,rlf)
    )
    ;

***---------------------------------------------------------------------------
*'  Preparation of captured emissions to enter the CCS chain.
*'  The first part of the equation describes emissions captured from the ambient air by DAC,
*'  the second part calculates the CO2 captured from the gas used for heat production
*'  required for all CDR assuming 90% capture rate. The third part is the CCS needed for
*'  limestone decomposition emissions for ocean alkalinity enhancement.
***---------------------------------------------------------------------------
q33_ccsbal(t,regi,ccs2te(ccsCo2(enty),enty2,te))..
    sum(teCCS2rlf(te,rlf), vm_ccs_cdr(t,regi,enty,enty2,te,rlf))
    =e=
    - v33_emi(t,regi,"dac")
    + (1 / pm_eta_conv(t,regi,"gash2c")) * fm_dataemiglob("pegas","seh2","gash2c","cco2") * sum(fe2cdr("fegas",entyFe2,te_used33), v33_FEdemand(t,regi,"fegas", entyFe2,te_used33))
    - s33_CO2_chem_decomposition * v33_emi(t,regi,"oae")
    ;


***---------------------------------------------------------------------------
*'  Limit the amount of H2 from biomass to the demand without CDR.
*'  It's a sustainability bound to prevent a large demand for biomass.
***---------------------------------------------------------------------------
q33_H2bio_lim(t,regi,te)$pe2se("pebiolc","seh2",te)..
    vm_prodSE(t,regi,"pebiolc","seh2",te)
    =l=
    vm_prodFe(t,regi,"seh2","feh2s","tdh2s") - sum(fe2cdr("feh2s",entyFe2,te_used33), v33_FEdemand(t,regi,"feh2s",entyFe2,te_used33))
    ;

***---------------------------------------------------------------------------
*** DAC

***---------------------------------------------------------------------------
*'  Calculation of FE demand for DAC, i.e., electricity demand for ventilation,
*'  and heat demand.
***---------------------------------------------------------------------------
q33_DAC_FEdemand(t,regi,entyFe2)$sum(entyFe, fe2cdr(entyFe,entyFe2,"dac"))..
    sum(fe2cdr(entyFe,entyFe2,"dac"), v33_FEdemand(t,regi,entyFe,entyFe2,"dac"))
    =e=
    p33_fedem("dac", entyFe2) * sm_EJ_2_TWa * (- v33_emi(t,regi,"dac"))
    ;

***---------------------------------------------------------------------------
*** EW

***---------------------------------------------------------------------------
*'  Calculation of the amount of ground rock spread in timestep t.
***---------------------------------------------------------------------------
q33_EW_capconst(t,regi)..
    sum((rlf_cz33, rlf), v33_EW_onfield(t,regi,rlf_cz33,rlf))
    =l=
    sum(teNoTransform2rlf33("weathering",rlf),
        vm_capFac(t,regi,"weathering") * vm_cap(t,regi,"weathering",rlf)
    )
    ;

***---------------------------------------------------------------------------
*'  Calculation of the total amount of ground rock on the fields in timestep t.
*'  The first part of the equation describes the decay of the rocks added until that time,
*'  the rest describes the newly added rocks.
***---------------------------------------------------------------------------
q33_EW_onfield_tot(ttot,regi,rlf_cz33,rlf)$(ttot.val ge max(2025, cm_startyear))..
    v33_EW_onfield_tot(ttot,regi,rlf_cz33,rlf)
    =e=
    v33_EW_onfield_tot(ttot-1,regi,rlf_cz33,rlf) * exp(-p33_co2_rem_rate(rlf_cz33) * pm_ts(ttot))
    + v33_EW_onfield(ttot-1,regi,rlf_cz33,rlf) * (
        sum(tall$(tall.val le (ttot.val - pm_ts(ttot)/2) and tall.val gt (ttot.val - pm_ts(ttot))),
            exp(-p33_co2_rem_rate(rlf_cz33) * (ttot.val - tall.val))
        )
    )
    + v33_EW_onfield(ttot,regi,rlf_cz33,rlf) * (
        sum(tall$(tall.val le ttot.val and tall.val gt (ttot.val - pm_ts(ttot)/2)),
            exp(-p33_co2_rem_rate(rlf_cz33) * (ttot.val-tall.val))
        )
    )
;

***---------------------------------------------------------------------------
*'  Calculation of (negative) CO2 emissions from enhanced weathering.
***---------------------------------------------------------------------------
q33_EW_emi(t,regi)..
    v33_emi(t,regi, "weathering")
    =e=
    sum((rlf_cz33, rlf),
        - v33_EW_onfield_tot(t,regi,rlf_cz33,rlf) * s33_co2_rem_pot * (1 - exp(-p33_co2_rem_rate(rlf_cz33)))
    )
    ;

***---------------------------------------------------------------------------
*'  Calculation of FE demand for enhanced weathering, i.e., electricity demand for grinding,
*'  and the diesel demand for transportation and spreading on crop fields.
***---------------------------------------------------------------------------
q33_EW_FEdemand(t,regi,entyFe2)$sum(entyFe, fe2cdr(entyFe,entyFe2,"weathering"))..
    sum(fe2cdr(entyFe,entyFe2,"weathering"), v33_FEdemand(t,regi,entyFe,entyFe2,"weathering"))
    =e=
    p33_fedem("weathering",entyFe2) * sm_EJ_2_TWa * sum((rlf_cz33, rlf), v33_EW_onfield(t,regi,rlf_cz33,rlf))
    ;

***---------------------------------------------------------------------------
*'  O&M costs of EW, consisting of fix costs for mining, grinding and spreading, and transportation costs.
***---------------------------------------------------------------------------
q33_EW_omcosts(t,regi)..
    vm_omcosts_cdr(t,regi)
    =e=
    sum((rlf_cz33, rlf),
        (s33_costs_fix + p33_transport_costs(regi,rlf_cz33,rlf)) * v33_EW_onfield(t,regi,rlf_cz33,rlf)
    )
    ;

***---------------------------------------------------------------------------
*'  Limit total amount of ground rock on the fields to regional maximum potentials.
***---------------------------------------------------------------------------
q33_EW_potential(t,regi,rlf_cz33)..
    sum(rlf, v33_EW_onfield_tot(t,regi,rlf_cz33,rlf))
    =l=
    f33_maxProdGradeRegiWeathering(regi,rlf_cz33)
    ;

***---------------------------------------------------------------------------
*'  An annual limit for the maximum amount of rocks spred [Gt] can be set via cm_LimRock,
*'  e.g. due to sustainability concerns.
***---------------------------------------------------------------------------
q33_EW_LimEmi(t,regi)..
    sum((rlf_cz33, rlf), v33_EW_onfield(t,regi,rlf_cz33,rlf))
    =l=
    cm_LimRock * p33_LimRock(regi)
    ;

***---------------------------------------------------------------------------
*'  Calculation of FE demand for OAE, i.e., electricity for rock preprocessing,
*'  and heat for calcination.
***---------------------------------------------------------------------------
q33_OAE_FEdemand(t,regi,entyFe2)$sum(entyFe, fe2cdr(entyFe,entyFe2,"oae"))..
    sum(fe2cdr(entyFe,entyFe2,"oae"), v33_FEdemand(t,regi,entyFe,entyFe2,"oae"))
    =e=
    p33_fedem("oae", entyFe2) * sm_EJ_2_TWa * (- v33_emi(t,regi,"oae"))
    ;

*** EOF ./modules/33_CDR/portfolio/equations.gms
