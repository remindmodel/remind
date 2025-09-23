*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/off/declarations.gms

variables
*** tax revenues of implicit taxes used for quantity and price target implementation
vm_taxrev(ttot,all_regi)                                            "difference between tax volume in current and previous iteration [T$]"
vm_taxrevimplicitQttyTargetTax(ttot,all_regi)        		    "tax revenue of implict tax for quantity target bound [T$]"
vm_taxrevimplicitPriceTax(ttot,all_regi,entySe,all_enty,sector)     "tax revenue of implict tax for final energy price target [T$]"
vm_taxrevimplicitPePriceTax(ttot,all_regi,all_enty)  		    "tax revenue of implict tax forprimary energy price target [T$]"
;
*** EOF ./modules/21_tax/off/declarations.gms
