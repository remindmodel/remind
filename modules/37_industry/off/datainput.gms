*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/off/datainput.gms

*** initialis baseline emissions to zero
vm_macBaseInd.l(ttot,regi,entyFE,secInd37) = 0;

*** Include MAC curve parameters
$include "./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms";

*** cm_CCS_cement in this realisation is used only to toggle the demand 
*** reduction for cement.  There is no CCS applied to process emissions.
if (cm_IndCCSscen eq 1,
  if (cm_CCS_cement eq 1,
    emiMac2mac("co2cement_process","co2cement") = YES;
  );
);

*** EOF ./modules/37_industry/off/datainput.gms

