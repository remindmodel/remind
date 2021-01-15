*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/off/bounds.gms
vm_otherFEdemand.fx(t,regi,entyFe) = 0;
vm_cap.fx(t,regi,"rockgrind",rlf) = 0;
vm_emiCdr.fx(t,regi,enty) = 0;   
vm_omcosts_cdr.fx(t,regi) = 0;
vm_ccs_cdr.fx(t,regi,enty,enty2,te,rlf)$ccs2te(enty,enty2,te) = 0;
v33_grindrock_onfield.fx(t,regi,rlf,rlf2) = 0;
v33_grindrock_onfield_tot.fx(t,regi,rlf,rlf2) = 0;

*** EOF ./modules/33_CDR/off/bounds.gms
