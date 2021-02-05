*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/bounds.gms

vm_cesIO.fx(t0,regi_dyn29(regi),in_industry_dyn37(in))
  = pm_cesdata(t0,regi,in,"quantity");

*** Assure that h2 penetration is not high in calibration so the extra t&d cost can be considered by the model. 
*** In case contrary, H2 is competitive against gas in buildings and industry even during calibration.
*** check therefore the bounds in realization simple of the module buildings and
*** the relization fixed_shares of the module industry


*** EOF ./modules/29_CES_parameters/calibrate/bounds.gms