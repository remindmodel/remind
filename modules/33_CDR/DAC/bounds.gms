*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/DAC/bounds.gms
vm_emiCdr.fx(t,regi,emi)$(not sameas(emi,"co2")) = 0.0;
vm_emiCdr.l(t,regi,"co2")$(t.val gt 2020 AND cm_ccapturescen ne 2) = -sm_eps;
vm_omcosts_cdr.fx(t,regi) = 0.0;
if (cm_emiscen ne 1,
    vm_cap.lo(t,regi,"dac",rlf)$(teNoTransform2rlf_dyn33("dac",rlf) AND (t.val ge max(2025,cm_startyear))) = 1e-7;  
);


vm_emiCdr.up(t,regi,"co2")$(t.val le 2025)=0;

*** EOF ./modules/33_CDR/DAC/bounds.gms
