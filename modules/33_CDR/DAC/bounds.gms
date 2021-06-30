*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/DAC/bounds.gms
vm_emiCdr.fx(t,regi,enty)$(not sameas(enty,"co2")) = 0.0;
vm_emiCdr.fx(t,regi,enty)$((t.val le 2005) AND sameas(enty, "co2")) = 0.0;
vm_emiCdr.l(t,regi,"co2")$(t.val gt 2020 AND cm_ccapturescen ne 2) = -sm_eps;
vm_omcosts_cdr.fx(t,regi) = 0.0;
v33_emiEW.fx(t,regi) = 0.0;
v33_grindrock_onfield.fx(t,regi,rlf,rlf2) = 0;
v33_grindrock_onfield_tot.fx(t,regi,rlf,rlf2) = 0;

$ifThen.regiNoDAC not "%cm_regiNoDAC%" == "none"
*** Switch off DAC for selected regions
v33_emiDAC.fx(t,regiNoDAC_33) = 0.0;
$endIf.regiNoDAC

if (cm_emiscen ne 1,
    vm_cap.lo(t,regi,"dac",rlf)$(teNoTransform2rlf_dyn33("dac",rlf) AND (t.val ge max(2025,cm_startyear))) = 1e-7;  
);


vm_emiCdr.up(t,regi,"co2")$(t.val le 2025)=0;

*** EOF ./modules/33_CDR/DAC/bounds.gms
