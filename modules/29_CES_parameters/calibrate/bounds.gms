*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/bounds.gms

vm_cesIO.fx(t0,regi_dyn29(regi),in_industry_dyn37(in))
  = pm_cesdata(t0,regi,in,"quantity");

*** Assure that h2 penetration is not high in calibration so the extra t&d cost can be considered by the model. In case contrary, H2 is competitive against gas in buildings and industry even during calibration.
$ifthen.build_H2_penetration "%buildings%" == "simple"
v36_H2share.up(t,regi) = s36_costDecayStart;
$endif.build_H2_penetration

$ifthen.indst_H2_penetration "%industry%" == "fixed_shares"
v37_H2share.up(t,regi) = s37_costDecayStart;
$endif.indst_H2_penetration

*** EOF ./modules/29_CES_parameters/calibrate/bounds.gms