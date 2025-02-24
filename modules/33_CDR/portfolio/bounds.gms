*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/bounds.gms

vm_emiCdr.fx(t,regi,emi)$(not sameas(emi,"co2")) = 0.0;
vm_emiCdr.l(t,regi,"co2")$(t.val ge 2025 AND cm_ccapturescen ne 2) = -sm_eps;

*** Bounds if there are no technologies in the portfolio
if(card(te_used33) eq 0,
    vm_emiCdr.fx(t,regi,"co2") = 0;
);

*** Fix CCS from CDR if there're no technologies that require CCS
if(card(te_ccs33) eq 0,
    vm_co2capture_cdr.fx(t,regi,enty,enty2,te,rlf)$ccs2te(enty,enty2,te) = 0;
);

*** Fix negative emissions and FE demand to zero for all the technologies that are not used
vm_emiCdrTeDetail.fx(t,regi,te_all33)$(not te_used33(te_all33)) = 0;
v33_FEdemand.fx(t,regi,entyFe,entyFe2,te_all33)$(not te_used33(te_all33) and fe2cdr(entyFe,entyFe2,te_all33)) = 0;
*** Fix non atmospheric emissions from CDR for all technologies that are not used
v33_co2emi_non_atm_gas.fx(t,regi,te_all33)$(not te_ccs33(te_all33)) = 0;

*** Fix all CDR-related variables to zero for early time steps t< 2025 (no CDR in the real world)
*** to reduce unnecessary freedom (and likelyhood of spontaneous solver infeasibilities)
vm_emiCdrTeDetail.fx(t,regi,te_used33)$(t.val lt 2025) = 0.0;
v33_FEdemand.fx(t,regi,entyFe,entyFe2,te_used33)$(fe2cdr(entyFe,entyFe2,te_used33) AND (t.val lt 2025)) = 0.0;
vm_emiCdr.fx(t,regi,"co2")$(t.val lt 2025) = 0;
vm_omcosts_cdr.fx(t,regi)$((t.val lt 2025)) = 0;
vm_cap.fx(t,regi,"weathering",rlf)$(t.val lt 2025) = 0;
v33_co2emi_non_atm_gas.fx(t,regi,te_used33)$(t.val lt 2025) = 0;
v33_co2emi_non_atm_calcination.fx(t,regi,te_oae33)$(t.val lt 2025) = 0;
*** vm_cap for dac is fixed for t<2025 in core/bounds.gms (tech_stat eq 4)
vm_co2capture_cdr.fx(t,regi,enty,enty2,te,rlf)$(ccs2te(enty,enty2,te) AND t.val lt 2025) = 0;

*** Set minimum DAC capacities (if available) to help the solver find the technology and exclude fegas and feh2s for low-temperature dac
if (te_used33("dac"),
    vm_cap.lo(t,regi,"dac",rlf)$(teNoTransform2rlf33("dac",rlf) AND (t.val ge 2030)) = sm_eps;
    v33_FEdemand.fx(t,regi,"fegas","fehes","dac") = 0;
    v33_FEdemand.fx(t,regi,"feh2s","fehes","dac") = 0;
);

*** Bounds for enhanced weathering
if(te_used33("weathering"),
    v33_EW_onfield_tot.up(t,regi,rlf_cz33,rlf) = s33_step;
    v33_EW_onfield.fx(t,regi,rlf_cz33,rlf)$(rlf.val gt 10) = 0; !! rlfs that are not used
    v33_EW_onfield_tot.fx(t,regi,rlf_cz33,rlf)$(rlf.val gt 10) = 0; !! rlfs that are not used
    !! if cm_startyear > 2025 and input_ref.gdx used EW, this fixing will be overwritten in submit.R
    v33_EW_onfield.fx(ttot,regi,rlf_cz33,rlf)$(ttot.val lt max(2025,cm_startyear)) = 0.0; !! 
    v33_EW_onfield_tot.fx(ttot,regi,rlf_cz33,rlf)$(ttot.val lt max(2025,cm_startyear)) = 0.0; !! 
else
    vm_omcosts_cdr.fx(t,regi) = 0;
    vm_cap.fx(t,regi,"weathering",rlf) = 0;
);

*** Bounds for OAE
if(card(te_oae33) ne 0,
    !! OAE starts in cm_33_OAE_startyear
    vm_cap.fx(t, regi, te_oae33, rlf)$(t.val lt cm_33_OAE_startyr) = 0;
    !! exclude feh2s for oae_el
    v33_FEdemand.fx(t,regi,"feh2s","feels","oae_el") = 0;
    v33_FEdemand.fx(t,regi,"feh2s","fehes","oae_el") = 0;
else
    v33_co2emi_non_atm_calcination.fx(t, regi, "oae_ng") = 0;
    v33_co2emi_non_atm_calcination.fx(t, regi, "oae_el") = 0;
);


*** Set upper bound on the amount of FE available for a sector
v33_FEsector_total.up(t,regi,entyFe,sector)$p33_shfetot_up(t,regi,entyFe,sector) = p33_FE_limit(t,regi,entyFe,sector);

*** EOF ./modules/33_CDR/portfolio/bounds.gms
