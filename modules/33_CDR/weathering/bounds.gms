*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/weathering/bounds.gms
vm_emiCdr.fx(t,regi,enty)$(not sameas(enty,"co2")) = 0.0;
v33_grindrock_onfield_tot.up(t,regi,rlf,rlf2) = s33_step;
v33_grindrock_onfield_tot.fx("2005",regi,rlf,rlf2) = 0.0;
v33_grindrock_onfield.fx(t,regi,rlf,rlf2)$(rlf2.val gt 10) = 0;
v33_grindrock_onfield_tot.fx(t,regi,rlf,rlf2)$(rlf2.val gt 10) = 0;
vm_ccs_cdr.fx(t,regi,enty,enty2,te,rlf)$ccs2te(enty,enty2,te) = 0;
v33_emiDAC.fx(t,regi) = 0.0;

*** EOF ./modules/33_CDR/weathering/bounds.gms
