*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/off/declarations.gms
variables
vm_ccs_cdr(ttot,all_regi,emiAll,all_enty,all_te,rlf)    "CCS emissions from CDR [GtC / a]"
;

positive variables
v33_grindrock_onfield(ttot,all_regi,rlf,rlf)         "amount of ground rock spread on fields in each timestep [Gt]"
v33_grindrock_onfield_tot(ttot,all_regi,rlf,rlf)     "total amount of ground rock on fields [Gt]"
;

*** EOF ./modules/33_CDR/off/declarations.gms
