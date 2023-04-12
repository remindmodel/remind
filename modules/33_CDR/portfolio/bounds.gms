*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/portfolio/bounds.gms

vm_emiCdr.fx(t,regi,emi)$(not sameas(emi,"co2")) = 0.0;
vm_emiCdr.l(t,regi,"co2")$(t.val ge 2025 AND cm_ccapturescen ne 2) = -sm_eps;

*' Bounds if there are no technologies in the portfolio
if(card(te_used33) eq 0,
    vm_emiCdr.fx(t,regi,"co2") = 0;
);

*' Fix CCS from CDR if there're no technologies that require CCS
if(card(te_ccs33) eq 0,
    vm_ccs_cdr.fx(t,regi,enty,enty2,te,rlf)$ccs2te(enty,enty2,te) = 0;
);

*' Fix negative emissions and FE demand to zero for all the technologies that are not used
v33_emi.fx(t,regi,te_all33)$(not te_used33(te_all33)) = 0;
v33_FEdemand.fx(t,regi,entyFe,entyFe2,te_all33)$(not te_used33(te_all33) and fe2cdr(entyFe,entyFe2,te_all33)) = 0;

*' Bounds for DAC (cm_emiscen ne 1 avoids setting the boundary for the business-as-usual scenario)
if (te_used33("dac") and cm_emiscen ne 1,
    vm_cap.lo(t,regi,"dac",rlf)$(teNoTransform2rlf33("dac",rlf) AND (t.val ge max(2025,cm_startyear))) = sm_eps;
);

*' Bounds for enhanced weathering
if(te_used33("weathering"),
    v33_EW_onfield_tot.up(t,regi,rlf_cz33,rlf) = s33_step;
    v33_EW_onfield.fx(t,regi,rlf_cz33,rlf)$(rlf.val gt 10) = 0; !! rlfs that are not used
    v33_EW_onfield_tot.fx(t,regi,rlf_cz33,rlf)$(rlf.val gt 10) = 0; !! rlfs that are not used
    v33_EW_onfield.fx(ttot,regi,rlf_cz33,rlf)$(ttot.val lt max(2025,cm_startyear)) = 0.0;
    v33_EW_onfield_tot.fx(ttot,regi,rlf_cz33,rlf)$(ttot.val lt max(2025,cm_startyear)) = 0.0;
);

*' Bounds if enhanced weathering is not in the portfolio
if(not te_used33("weathering"),
    vm_omcosts_cdr.fx(t,regi) = 0;
    vm_cap.fx(t,regi,"weathering",rlf) = 0;
);

*** EOF ./modules/33_CDR/portfolio/bounds.gms
